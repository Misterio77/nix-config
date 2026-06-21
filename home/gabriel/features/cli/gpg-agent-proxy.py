#!/usr/bin/env python3
"""Tiny gpg-agent/ssh-agent proxy that reports peer PIDs and operations.

Draft wiring model:
  client -> canonical socket -> this proxy -> real socket -> gpg-agent

For GPG/Assuan sockets, this watches client commands like PKDECRYPT/PKSIGN.
For SSH-agent sockets, this watches binary SSH_AGENTC_SIGN_REQUEST messages.
"""

from __future__ import annotations

import argparse
import os
import selectors
import signal
import socket
import struct
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path

SSH_AGENTC_SIGN_REQUEST = 13


@dataclass(frozen=True)
class Peer:
    pid: int
    uid: int
    gid: int


def peercred(conn: socket.socket) -> Peer | None:
    try:
        pid, uid, gid = struct.unpack("3i", conn.getsockopt(socket.SOL_SOCKET, socket.SO_PEERCRED, 12))
        return Peer(pid=pid, uid=uid, gid=gid)
    except OSError:
        return None


def clean_proc_name(name: str) -> str:
    if name.startswith("."):
        name = name[1:]
    return name.removesuffix("-wrapped")


def proc_name(pid: int) -> str:
    try:
        exe = os.readlink(f"/proc/{pid}/exe")
        return clean_proc_name(os.path.basename(exe))
    except OSError:
        try:
            return clean_proc_name(Path(f"/proc/{pid}/comm").read_text().strip())
        except OSError:
            return f"pid {pid}"


def parent_name(pid: int) -> str | None:
    boring = {"bash", "sh", "dash", "fish", "zsh", "nu", "nushell", "env", "systemd"}
    cur = pid
    for _ in range(6):
        try:
            status = Path(f"/proc/{cur}/status").read_text().splitlines()
        except OSError:
            return None
        ppid = None
        for line in status:
            if line.startswith("PPid:"):
                ppid = int(line.split()[1])
                break
        if not ppid or ppid in (0, 1):
            return None
        name = proc_name(ppid)
        if name in boring:
            cur = ppid
            continue
        return name
    return None


def display_file(pid: int, arg: str) -> str:
    path = Path(arg)
    file = path.name
    if path.parent != Path("."):
        parent = path.parent.name
    else:
        try:
            parent = Path(os.readlink(f"/proc/{pid}/cwd")).name
        except OSError:
            parent = ""
    return f"{parent}/{file}" if parent else file


def gpg_files(pid: int, name: str) -> list[str]:
    if name not in {"gpg", "gpg2"}:
        return []
    try:
        raw = Path(f"/proc/{pid}/cmdline").read_bytes()
    except OSError:
        return []
    args = [x.decode(errors="replace") for x in raw.split(b"\0") if x]
    skip_value = {
        "-o",
        "--output",
        "--homedir",
        "--recipient",
        "-r",
        "--local-user",
        "-u",
        "--default-key",
        "--status-fd",
        "--logger-fd",
        "--passphrase-fd",
        "--command-fd",
    }
    out: list[str] = []
    skip = False
    for arg in args[1:]:
        if skip:
            skip = False
            continue
        if arg in skip_value:
            skip = True
            continue
        if arg == "--" or arg.startswith("-"):
            continue
        out.append(display_file(pid, arg))
        if len(out) >= 8:
            break
    return out


def describe(peer: Peer | None) -> str:
    if peer is None:
        return "unknown peer"
    name = proc_name(peer.pid)
    files = gpg_files(peer.pid, name)
    parent = parent_name(peer.pid)
    bits = [f"{peer.pid}: {name}"]
    bits.extend(files)
    if parent:
        bits.append(f"via {parent}")
    return " ".join(bits)


def notify(title: str, body: str, expire_ms: int) -> None:
    try:
        subprocess.run(
            ["notify-send", "--app-name=gpg-agent", f"--expire-time={expire_ms}", title, body],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except OSError:
        print(f"{title}: {body}", file=sys.stderr)


class OperationDetector:
    def __init__(self, mode: str):
        self.mode = mode
        self.assuan_buffer = b""
        self.ssh_buffer = b""

    def feed_client_bytes(self, data: bytes) -> list[str]:
        if self.mode == "assuan":
            return self._feed_assuan(data)
        if self.mode == "ssh":
            return self._feed_ssh(data)
        return []

    def _feed_assuan(self, data: bytes) -> list[str]:
        self.assuan_buffer += data
        ops: list[str] = []
        while b"\n" in self.assuan_buffer:
            line, self.assuan_buffer = self.assuan_buffer.split(b"\n", 1)
            cmd = line.decode(errors="replace").strip()
            if cmd.startswith("PKDECRYPT"):
                ops.append("decrypt")
            elif cmd.startswith("PKSIGN"):
                ops.append("sign")
            elif cmd.startswith("PKAUTH"):
                ops.append("SSH auth")
        if len(self.assuan_buffer) > 8192:
            self.assuan_buffer = self.assuan_buffer[-8192:]
        return ops

    def _feed_ssh(self, data: bytes) -> list[str]:
        self.ssh_buffer += data
        ops: list[str] = []
        while len(self.ssh_buffer) >= 5:
            packet_len = struct.unpack(">I", self.ssh_buffer[:4])[0]
            if packet_len <= 0 or packet_len > 1024 * 1024:
                self.ssh_buffer = b""
                break
            if len(self.ssh_buffer) < 4 + packet_len:
                break
            packet = self.ssh_buffer[4 : 4 + packet_len]
            self.ssh_buffer = self.ssh_buffer[4 + packet_len :]
            if packet and packet[0] == SSH_AGENTC_SIGN_REQUEST:
                ops.append("SSH auth")
        return ops


def pump(client: socket.socket, upstream_path: str, mode: str, expire_ms: int, debounce_ms: int) -> None:
    peer = peercred(client)
    upstream = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    upstream.connect(upstream_path)

    client.setblocking(False)
    upstream.setblocking(False)
    sel = selectors.DefaultSelector()
    sel.register(client, selectors.EVENT_READ, "client")
    sel.register(upstream, selectors.EVENT_READ, "upstream")
    detector = OperationDetector(mode)
    last: dict[str, float] = {}

    try:
        while True:
            events = sel.select()
            for key, _ in events:
                src = key.fileobj
                src_name = key.data
                dst = upstream if src_name == "client" else client
                try:
                    data = src.recv(65536)
                except BlockingIOError:
                    continue
                if not data:
                    return
                if src_name == "client":
                    for op in detector.feed_client_bytes(data):
                        now = time.monotonic() * 1000
                        if now - last.get(op, 0) >= debounce_ms:
                            last[op] = now
                            notify(f"GPG {op}", describe(peer), expire_ms)
                dst.sendall(data)
    finally:
        sel.close()
        client.close()
        upstream.close()


def serve(listen_path: str, upstream_path: str, mode: str, expire_ms: int, debounce_ms: int) -> None:
    signal.signal(signal.SIGCHLD, signal.SIG_IGN)

    path = Path(listen_path)
    path.parent.mkdir(parents=True, exist_ok=True)
    try:
        path.unlink()
    except FileNotFoundError:
        pass

    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server.bind(listen_path)
    os.chmod(listen_path, 0o600)
    server.listen(128)
    print(f"gpg-agent-proxy listening on {listen_path}, upstream {upstream_path}, mode {mode}", file=sys.stderr)

    while True:
        client, _ = server.accept()
        pid = os.fork()
        if pid == 0:
            server.close()
            try:
                pump(client, upstream_path, mode, expire_ms, debounce_ms)
            finally:
                os._exit(0)
        client.close()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--listen", required=True)
    parser.add_argument("--upstream", required=True)
    parser.add_argument("--mode", choices=["assuan", "ssh"], required=True)
    parser.add_argument("--expire-ms", type=int, default=2000)
    parser.add_argument("--debounce-ms", type=int, default=300)
    args = parser.parse_args()
    serve(args.listen, args.upstream, args.mode, args.expire_ms, args.debounce_ms)


if __name__ == "__main__":
    main()

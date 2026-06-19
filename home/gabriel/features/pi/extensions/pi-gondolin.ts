import fs from "node:fs";
import os from "node:os";
import path from "node:path";

import {
  createBashTool,
  createEditTool,
  createReadTool,
  createWriteTool,
  type BashOperations,
  type EditOperations,
  type ExtensionAPI,
  type ExtensionContext,
  type ReadOperations,
  type WriteOperations,
} from "@mariozechner/pi-coding-agent";
import { RealFSProvider, VM } from "@earendil-works/gondolin";

const GUEST = "/workspace";
const STATUS = "gondolin";
const STATE = path.join(
  process.env.XDG_STATE_HOME ?? path.join(os.homedir(), ".local/state"),
  "pi/gondolin.json",
);
const MODES = new Set(["", "toggle", "status", "on", "off"]);

type Store = { workspaces?: Record<string, boolean> };
type Tool = any;

function load(): Store {
  try {
    return JSON.parse(fs.readFileSync(STATE, "utf8")) as Store;
  } catch {
    return {};
  }
}

function save(cwd: string, enabled: boolean) {
  const store = load();
  fs.mkdirSync(path.dirname(STATE), { recursive: true });
  fs.writeFileSync(
    STATE,
    `${JSON.stringify(
      { workspaces: { ...store.workspaces, [cwd]: enabled } },
      null,
      2,
    )}\n`,
  );
}

const quote = (s: string) => `'${s.replace(/'/g, "'\\''")}'`;
const env = (e?: NodeJS.ProcessEnv) =>
  e &&
  Object.fromEntries(
    Object.entries(e).filter(
      (x): x is [string, string] => typeof x[1] === "string",
    ),
  );

function guestPath(cwd: string, p: string) {
  const rel = path.relative(cwd, path.isAbsolute(p) ? p : path.join(cwd, p));
  if (rel === "") return GUEST;
  if (rel.startsWith("..") || path.isAbsolute(rel))
    throw new Error(`path escapes workspace: ${p}`);
  return path.posix.join(GUEST, rel.split(path.sep).join(path.posix.sep));
}

async function checked(vm: VM, args: string[], label: string) {
  const r = await vm.exec(args);
  if (!r.ok) throw new Error(`${label} (${r.exitCode}): ${r.stderr}`);
  return r;
}

function readOps(vm: VM, cwd: string): ReadOperations {
  return {
    readFile: async (p) =>
      (await checked(vm, ["/bin/cat", guestPath(cwd, p)], "cat failed"))
        .stdoutBuffer,
    access: async (p) => {
      if (
        !(
          await vm.exec([
            "/bin/sh",
            "-lc",
            `test -r ${quote(guestPath(cwd, p))}`,
          ])
        ).ok
      ) {
        throw new Error(`not readable: ${p}`);
      }
    },
    detectImageMimeType: async (p) => {
      const r = await vm.exec([
        "/bin/sh",
        "-lc",
        `file --mime-type -b ${quote(guestPath(cwd, p))}`,
      ]);
      const mime = r.ok ? r.stdout.trim() : "";
      return ["image/jpeg", "image/png", "image/gif", "image/webp"].includes(
        mime,
      )
        ? mime
        : null;
    },
  };
}

function writeOps(vm: VM, cwd: string): WriteOperations {
  return {
    writeFile: async (p, content) => {
      const dest = guestPath(cwd, p);
      await checked(
        vm,
        [
          "/bin/sh",
          "-lc",
          [
            "set -eu",
            `mkdir -p ${quote(path.posix.dirname(dest))}`,
            `printf %s ${quote(Buffer.from(content).toString("base64"))} | base64 -d > ${quote(dest)}`,
          ].join("\n"),
        ],
        "write failed",
      );
    },
    mkdir: async (p) =>
      void (await checked(
        vm,
        ["/bin/mkdir", "-p", guestPath(cwd, p)],
        "mkdir failed",
      )),
  };
}

const editOps = (vm: VM, cwd: string): EditOperations => ({
  readFile: readOps(vm, cwd).readFile,
  access: readOps(vm, cwd).access,
  writeFile: writeOps(vm, cwd).writeFile,
});

function bashOps(vm: VM, cwd: string): BashOperations {
  return {
    exec: async (command, dir, { onData, signal, timeout, env: e }) => {
      const ac = new AbortController();
      const abort = () => ac.abort();
      signal?.addEventListener("abort", abort, { once: true });
      let timedOut = false;
      const timer = timeout
        ? setTimeout(() => {
            timedOut = true;
            ac.abort();
          }, timeout * 1000)
        : undefined;

      try {
        const proc = vm.exec(["/bin/bash", "-lc", command], {
          cwd: guestPath(cwd, dir),
          env: env(e),
          signal: ac.signal,
          stderr: "pipe",
          stdout: "pipe",
        });
        for await (const chunk of proc.output()) onData(chunk.data);
        return { exitCode: (await proc).exitCode };
      } catch (err) {
        if (signal?.aborted) throw new Error("aborted");
        if (timedOut) throw new Error(`timeout:${timeout}`);
        throw err;
      } finally {
        if (timer) clearTimeout(timer);
        signal?.removeEventListener("abort", abort);
      }
    },
  };
}

export default function (pi: ExtensionAPI) {
  const cwd = process.cwd();
  const store = load();
  let enabled = store.workspaces?.[cwd] ?? true;
  let vm: VM | null = null;
  let starting: Promise<VM> | null = null;

  const status = (
    ctx: ExtensionContext,
    text: string,
    color: "accent" | "muted" = "accent",
  ) => ctx.ui.setStatus(STATUS, ctx.ui.theme.fg(color, `Gondolin: ${text}`));

  async function start(ctx?: ExtensionContext) {
    if (!enabled) throw new Error("Gondolin is disabled");
    if (vm) return vm;
    if (starting) return starting;

    ctx && status(ctx, `starting (mount ${GUEST})`);
    starting = VM.create({
      vfs: { mounts: { [GUEST]: new RealFSProvider(cwd) } },
    }).then(async (next) => {
      if (!enabled) {
        await next.close();
        throw new Error("Gondolin was disabled while starting");
      }
      vm = next;
      ctx && status(ctx, `running (${cwd} -> ${GUEST})`);
      ctx?.ui.notify(
        `Gondolin VM ready. Host ${cwd} mounted at ${GUEST}`,
        "info",
      );
      return next;
    });

    try {
      return await starting;
    } finally {
      starting = null;
    }
  }

  async function stop(ctx?: ExtensionContext) {
    const old = vm ?? (starting && (await starting.catch(() => null)));
    vm = starting = null;
    if (old) {
      ctx && status(ctx, "stopping", "muted");
      await old.close();
    }
  }

  const persist = () => save(cwd, enabled);
  const setEnabled = (value: boolean) => {
    enabled = value;
    persist();
  };

  const local = {
    read: createReadTool(cwd),
    write: createWriteTool(cwd),
    edit: createEditTool(cwd),
    bash: createBashTool(cwd),
  };

  function tool(base: Tool, make: (vm: VM) => Tool) {
    pi.registerTool({
      ...base,
      async execute(id, params, signal, onUpdate, ctx) {
        return enabled
          ? make(await start(ctx)).execute(id, params, signal, onUpdate)
          : base.execute(id, params, signal, onUpdate);
      },
    });
  }

  pi.on("session_start", async (_event, ctx) => {
    if (!enabled) return status(ctx, "disabled", "muted");
    try {
      await start(ctx);
    } catch (err) {
      if (enabled) throw err;
    }
  });

  pi.on("session_before_fork", persist);
  pi.on("session_shutdown", async (_event, ctx) => {
    persist();
    await stop(ctx);
  });

  pi.registerCommand("gondolin", {
    description: "Toggle Gondolin VM sandboxing (on/off/status)",
    handler: async (args, ctx) => {
      const mode = args.trim().toLowerCase();
      if (!MODES.has(mode))
        return ctx.ui.notify(
          "Usage: /gondolin [on|off|toggle|status]",
          "error",
        );
      if (mode === "status") {
        return ctx.ui.notify(
          enabled
            ? `Gondolin enabled${vm ? " and running" : " but not running"}`
            : "Gondolin disabled",
          "info",
        );
      }

      await ctx.waitForIdle();
      setEnabled(mode === "" || mode === "toggle" ? !enabled : mode === "on");
      if (enabled) {
        await start(ctx);
        return ctx.ui.notify(
          "Gondolin enabled; tools now run in the VM",
          "info",
        );
      }

      await stop(ctx);
      status(ctx, "disabled", "muted");
      ctx.ui.notify("Gondolin disabled; tools now run on the host", "info");
    },
  });

  tool(local.read, (v) => createReadTool(cwd, { operations: readOps(v, cwd) }));
  tool(local.write, (v) =>
    createWriteTool(cwd, { operations: writeOps(v, cwd) }),
  );
  tool(local.edit, (v) => createEditTool(cwd, { operations: editOps(v, cwd) }));
  tool(local.bash, (v) => createBashTool(cwd, { operations: bashOps(v, cwd) }));

  const onUserBash = pi.on as unknown as (
    event: "user_bash",
    handler: (
      event: unknown,
      ctx: ExtensionContext,
    ) => Promise<{ operations: BashOperations } | undefined>,
  ) => void;

  onUserBash("user_bash", async (_event, ctx) => {
    if (!enabled) return;
    return { operations: bashOps(await start(ctx), cwd) };
  });

  pi.on("before_agent_start", async (event, ctx) => {
    if (!enabled) return;
    try {
      await start(ctx);
    } catch (err) {
      if (enabled) throw err;
      return;
    }
    return {
      systemPrompt: event.systemPrompt.replace(
        `Current working directory: ${cwd}`,
        `Current working directory: ${GUEST} (Gondolin VM, mounted from host: ${cwd})`,
      ),
    };
  });
}

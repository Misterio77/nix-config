/**
 * Pi + Gondolin Sandbox Example (pi extension)
 *
 * This extension overrides pi's built-in `read`/`write`/`edit`/`bash` tools so
 * they execute inside a Gondolin micro-VM instead of on the host.
 *
 * The directory you start `pi` in is mounted read-write at `/workspace` inside
 * the VM.
 *
 * How to run:
 *   1. Install dependencies for this repo (so imports resolve):
 *        pnpm install
 *   2. Ensure QEMU is installed (see the gondolin README "Quick Start")
 *   3. Start pi in the project you want to sandbox:
 *        cd /path/to/your/project
 *        pi -e /absolute/path/to/gondolin/host/examples/pi-gondolin.ts
 *
 * Notes:
 *   - The VM is started on `session_start` (and lazily if a tool is used before that)
 *   - User `!` commands are also executed inside the VM
 *   - Module resolution happens relative to this file, so keeping it inside the
 *     gondolin repo (or installing `@earendil-works/gondolin` next to it) is easiest
 */

import fs from "node:fs";
import os from "node:os";
import path from "node:path";

import type {
  ExtensionAPI,
  ExtensionContext,
} from "@mariozechner/pi-coding-agent";
import {
  type BashOperations,
  createBashTool,
  createEditTool,
  createReadTool,
  createWriteTool,
  type EditOperations,
  type ReadOperations,
  type WriteOperations,
} from "@mariozechner/pi-coding-agent";

import { RealFSProvider, VM } from "@earendil-works/gondolin";

const GUEST_WORKSPACE = "/workspace";
const STATE_FILE = path.join(
  process.env.XDG_STATE_HOME ?? path.join(os.homedir(), ".local", "state"),
  "pi",
  "gondolin.json",
);

type GondolinState = {
  enabled: boolean;
  vm: VM | null;
  vmStarting: Promise<VM> | null;
  generation: number;
};

const globalState = globalThis as typeof globalThis & {
  __piGondolinState?: Map<string, GondolinState>;
};

type PersistedState = {
  enabled?: boolean;
  workspaces?: Record<string, boolean>;
};

function readPersistedState(): PersistedState {
  try {
    return JSON.parse(fs.readFileSync(STATE_FILE, "utf8"));
  } catch {
    return {};
  }
}

function persistedEnabled(localCwd: string): boolean | undefined {
  const persisted = readPersistedState();
  const value = persisted.workspaces?.[localCwd] ?? persisted.enabled;
  if (typeof value === "boolean") return value;

  const workspaceValues = Object.values(persisted.workspaces ?? {});
  if (workspaceValues.includes(false)) return false;
  if (workspaceValues.includes(true)) return true;
  return undefined;
}

function persistEnabled(localCwd: string, enabled: boolean) {
  const persisted = readPersistedState();
  persisted.enabled = enabled;
  persisted.workspaces ??= {};
  persisted.workspaces[localCwd] = enabled;

  fs.mkdirSync(path.dirname(STATE_FILE), { recursive: true });
  fs.writeFileSync(STATE_FILE, `${JSON.stringify(persisted, null, 2)}\n`);
}

function getGondolinState(localCwd: string): GondolinState {
  globalState.__piGondolinState ??= new Map();

  let state = globalState.__piGondolinState.get(localCwd);
  if (!state) {
    state = {
      enabled: persistedEnabled(localCwd) ?? true,
      vm: null,
      vmStarting: null,
      generation: 0,
    };
    globalState.__piGondolinState.set(localCwd, state);
  }

  return state;
}

function shQuote(value: string): string {
  // POSIX shell quoting: wraps in single quotes and escapes internal quotes
  return "'" + value.replace(/'/g, "'\\''") + "'";
}

function toGuestPath(localCwd: string, localPath: string): string {
  // pi tools pass absolute local paths; map them into /workspace.
  const rel = path.relative(localCwd, localPath);
  if (rel === "") return GUEST_WORKSPACE;
  if (rel.startsWith("..") || path.isAbsolute(rel)) {
    throw new Error(`path escapes workspace: ${localPath}`);
  }
  // Convert platform separators to POSIX for the Linux guest
  const posixRel = rel.split(path.sep).join(path.posix.sep);
  return path.posix.join(GUEST_WORKSPACE, posixRel);
}

function createGondolinReadOps(vm: VM, localCwd: string): ReadOperations {
  return {
    readFile: async (p) => {
      const guestPath = toGuestPath(localCwd, p);
      const r = await vm.exec(["/bin/cat", guestPath]);
      if (!r.ok) {
        throw new Error(`cat failed (${r.exitCode}): ${r.stderr}`);
      }
      return r.stdoutBuffer;
    },
    access: async (p) => {
      const guestPath = toGuestPath(localCwd, p);
      const r = await vm.exec([
        "/bin/sh",
        "-lc",
        `test -r ${shQuote(guestPath)}`,
      ]);
      if (!r.ok) {
        throw new Error(`not readable: ${p}`);
      }
    },
    detectImageMimeType: async (p) => {
      const guestPath = toGuestPath(localCwd, p);
      try {
        // Run through the shell because `file` might live in `/usr/bin` depending on the image
        const r = await vm.exec([
          "/bin/sh",
          "-lc",
          `file --mime-type -b ${shQuote(guestPath)}`,
        ]);
        if (!r.ok) return null;
        const m = r.stdout.trim();
        return ["image/jpeg", "image/png", "image/gif", "image/webp"].includes(
          m,
        )
          ? m
          : null;
      } catch {
        return null;
      }
    },
  };
}

function createGondolinWriteOps(vm: VM, localCwd: string): WriteOperations {
  return {
    writeFile: async (p, content) => {
      const guestPath = toGuestPath(localCwd, p);
      const dir = path.posix.dirname(guestPath);

      // Base64 roundtrip to avoid quoting issues
      const b64 = Buffer.from(content, "utf8").toString("base64");
      const script = [
        `set -eu`,
        `mkdir -p ${shQuote(dir)}`,
        `echo ${shQuote(b64)} | base64 -d > ${shQuote(guestPath)}`,
      ].join("\n");

      const r = await vm.exec(["/bin/sh", "-lc", script]);
      if (!r.ok) {
        throw new Error(`write failed (${r.exitCode}): ${r.stderr}`);
      }
    },
    mkdir: async (dir) => {
      const guestDir = toGuestPath(localCwd, dir);
      const r = await vm.exec(["/bin/mkdir", "-p", guestDir]);
      if (!r.ok) {
        throw new Error(`mkdir failed (${r.exitCode}): ${r.stderr}`);
      }
    },
  };
}

function createGondolinEditOps(vm: VM, localCwd: string): EditOperations {
  const r = createGondolinReadOps(vm, localCwd);
  const w = createGondolinWriteOps(vm, localCwd);
  return { readFile: r.readFile, access: r.access, writeFile: w.writeFile };
}

function sanitizeEnv(
  env?: NodeJS.ProcessEnv,
): Record<string, string> | undefined {
  if (!env) return undefined;
  const out: Record<string, string> = {};
  for (const [k, v] of Object.entries(env)) {
    if (typeof v === "string") out[k] = v;
  }
  return out;
}

function createGondolinBashOps(vm: VM, localCwd: string): BashOperations {
  return {
    exec: async (command, cwd, { onData, signal, timeout, env }) => {
      const guestCwd = toGuestPath(localCwd, cwd);

      const ac = new AbortController();
      const onAbort = () => ac.abort();
      signal?.addEventListener("abort", onAbort, { once: true });

      let timedOut = false;
      const timer =
        timeout && timeout > 0
          ? setTimeout(() => {
              timedOut = true;
              ac.abort();
            }, timeout * 1000)
          : undefined;

      try {
        // `/bin/bash -lc` for a familiar environment (pipelines, expansions, etc.)
        const proc = vm.exec(["/bin/bash", "-lc", command], {
          cwd: guestCwd,
          signal: ac.signal,
          env: sanitizeEnv(env),
          stdout: "pipe",
          stderr: "pipe",
        });

        for await (const chunk of proc.output()) {
          onData(chunk.data);
        }

        const r = await proc;
        return { exitCode: r.exitCode };
      } catch (err) {
        if (signal?.aborted) throw new Error("aborted");
        if (timedOut) throw new Error(`timeout:${timeout}`);
        throw err;
      } finally {
        if (timer) clearTimeout(timer);
        signal?.removeEventListener("abort", onAbort);
      }
    },
  };
}

export default function (pi: ExtensionAPI) {
  const localCwd = process.cwd();

  const localRead = createReadTool(localCwd);
  const localWrite = createWriteTool(localCwd);
  const localEdit = createEditTool(localCwd);
  const localBash = createBashTool(localCwd);

  const state = getGondolinState(localCwd);

  function setGondolinStatus(
    ctx: ExtensionContext,
    message: string,
    color: "accent" | "muted" = "accent",
  ) {
    ctx.ui.setStatus(
      "gondolin",
      ctx.ui.theme.fg(color, `Gondolin: ${message}`),
    );
  }

  async function stopVm(ctx?: ExtensionContext) {
    state.generation++;
    const activeVm =
      state.vm ??
      (state.vmStarting ? await state.vmStarting.catch(() => null) : null);
    if (!activeVm) return;
    if (ctx) setGondolinStatus(ctx, "stopping", "muted");
    try {
      await activeVm.close();
    } finally {
      state.vm = null;
      state.vmStarting = null;
    }
  }

  async function ensureVm(ctx?: ExtensionContext) {
    if (!state.enabled) throw new Error("Gondolin is disabled");
    if (state.vm) return state.vm;
    if (state.vmStarting) return state.vmStarting;

    const generation = state.generation;
    state.vmStarting = (async () => {
      if (ctx) setGondolinStatus(ctx, `starting (mount ${GUEST_WORKSPACE})`);

      try {
        const created = await VM.create({
          vfs: {
            mounts: {
              [GUEST_WORKSPACE]: new RealFSProvider(localCwd),
            },
          },
        });

        if (!state.enabled || generation !== state.generation) {
          await created.close();
          throw new Error("Gondolin was disabled while starting");
        }

        state.vm = created;
        if (ctx) {
          setGondolinStatus(ctx, `running (${localCwd} -> ${GUEST_WORKSPACE})`);
        }
        ctx?.ui.notify(
          `Gondolin VM ready. Host ${localCwd} mounted at ${GUEST_WORKSPACE}`,
          "info",
        );
        return created;
      } catch (err) {
        state.vmStarting = null;
        throw err;
      }
    })();

    return state.vmStarting;
  }

  pi.on("session_start", async (_event, ctx) => {
    if (!state.enabled) {
      setGondolinStatus(ctx, "disabled", "muted");
      return;
    }

    // Start eagerly so the user sees errors early (missing qemu, etc.)
    try {
      await ensureVm(ctx);
    } catch (err) {
      if (state.enabled) throw err;
    }
  });

  pi.on("session_before_fork", () => {
    persistEnabled(localCwd, state.enabled);
  });

  pi.on("session_shutdown", async (_event, ctx) => {
    persistEnabled(localCwd, state.enabled);
    await stopVm(ctx);
  });

  pi.registerCommand("gondolin", {
    description: "Toggle Gondolin VM sandboxing (on/off/status)",
    handler: async (args, ctx) => {
      const mode = args.trim().toLowerCase();
      const nextEnabled =
        mode === "" || mode === "toggle"
          ? !state.enabled
          : ["on", "enable", "enabled", "start"].includes(mode)
            ? true
            : ["off", "disable", "disabled", "stop"].includes(mode)
              ? false
              : state.enabled;

      const validModes = [
        "",
        "toggle",
        "status",
        "on",
        "enable",
        "enabled",
        "start",
        "off",
        "disable",
        "disabled",
        "stop",
      ];
      if (!validModes.includes(mode)) {
        ctx.ui.notify("Usage: /gondolin [on|off|toggle|status]", "error");
        return;
      }

      if (mode !== "status") await ctx.waitForIdle();

      if (mode === "status") {
        ctx.ui.notify(
          state.enabled
            ? `Gondolin enabled${state.vm ? " and running" : " but not running"}`
            : "Gondolin disabled",
          "info",
        );
        return;
      }

      state.enabled = nextEnabled;
      state.generation++;
      persistEnabled(localCwd, state.enabled);
      if (state.enabled) {
        await ensureVm(ctx);
        ctx.ui.notify("Gondolin enabled; tools now run in the VM", "info");
        return;
      }

      await stopVm(ctx);
      setGondolinStatus(ctx, "disabled", "muted");
      ctx.ui.notify("Gondolin disabled; tools now run on the host", "info");
    },
  });

  pi.registerTool({
    ...localRead,
    async execute(id, params, signal, onUpdate, ctx) {
      if (!state.enabled) return localRead.execute(id, params, signal, onUpdate);
      const activeVm = await ensureVm(ctx);
      const tool = createReadTool(localCwd, {
        operations: createGondolinReadOps(activeVm, localCwd),
      });
      return tool.execute(id, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    ...localWrite,
    async execute(id, params, signal, onUpdate, ctx) {
      if (!state.enabled) return localWrite.execute(id, params, signal, onUpdate);
      const activeVm = await ensureVm(ctx);
      const tool = createWriteTool(localCwd, {
        operations: createGondolinWriteOps(activeVm, localCwd),
      });
      return tool.execute(id, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    ...localEdit,
    async execute(id, params, signal, onUpdate, ctx) {
      if (!state.enabled) return localEdit.execute(id, params, signal, onUpdate);
      const activeVm = await ensureVm(ctx);
      const tool = createEditTool(localCwd, {
        operations: createGondolinEditOps(activeVm, localCwd),
      });
      return tool.execute(id, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    ...localBash,
    async execute(id, params, signal, onUpdate, ctx) {
      if (!state.enabled) return localBash.execute(id, params, signal, onUpdate);
      const activeVm = await ensureVm(ctx);
      const tool = createBashTool(localCwd, {
        operations: createGondolinBashOps(activeVm, localCwd),
      });
      return tool.execute(id, params, signal, onUpdate);
    },
  });

  // Run user `!` commands inside the VM too
  pi.on("user_bash", (_event, ctx) => {
    if (!state.enabled || !state.vm) return;
    return { operations: createGondolinBashOps(state.vm, localCwd) };
  });

  // Replace the CWD line in the system prompt so the model sees /workspace
  pi.on("before_agent_start", async (event, ctx) => {
    if (!state.enabled) return;
    try {
      await ensureVm(ctx);
    } catch (err) {
      if (state.enabled) throw err;
      return;
    }
    if (!state.enabled) return;
    const modified = event.systemPrompt.replace(
      `Current working directory: ${localCwd}`,
      `Current working directory: ${GUEST_WORKSPACE} (Gondolin VM, mounted from host: ${localCwd})`,
    );
    return { systemPrompt: modified };
  });
}

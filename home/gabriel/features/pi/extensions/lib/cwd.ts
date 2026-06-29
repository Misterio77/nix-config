import { writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import process from "node:process";
import type {
  ExtensionAPI,
  ExtensionCommandContext,
} from "@earendil-works/pi-coding-agent";
import {
  createLocalBashOperations,
  SessionManager,
} from "@earendil-works/pi-coding-agent";

let cwdHooksInstalled = false;

// Cross-extension state lives on process-globals so it survives extension
// reloads and is shared across separately-loaded extension modules:
// - __piStartCwd: the directory Pi launched in, where the built-in tools were
//   constructed (re-capturing after a chdir would be wrong).
// - __piGondolinActive: published by pi-gondolin while it runs tools in a VM
//   mounted from a fixed host cwd, so we can refuse to change directory.
const piGlobal = globalThis as {
  __piStartCwd?: string;
  __piGondolinActive?: boolean;
};
const startCwd = (piGlobal.__piStartCwd ??= process.cwd());

// Built-in tools that resolve a `path`/`file_path` argument relative to cwd.
const PATH_TOOLS = new Set(["read", "write", "edit", "ls", "grep", "find"]);

export function expandHome(path: string): string {
  if (path === "~") return process.env.HOME ?? path;
  if (path.startsWith("~/")) {
    return resolve(process.env.HOME ?? ".", path.slice(2));
  }
  return path;
}

function shellQuote(value: string): string {
  return `'${value.replace(/'/g, `'\\''`)}'`;
}

export function gondolinActive(): boolean {
  return piGlobal.__piGondolinActive === true;
}

// Built-in tools capture their cwd at construction, so they keep resolving
// against the directory Pi started in even after we switch sessions and
// `process.chdir()`. Rather than reconstructing the tools (which loses their
// configured options and conflicts across extensions), rewrite their path
// arguments to be absolute against the live `process.cwd()` and prefix bash
// with a matching `cd`. This leaves the built-ins and their settings untouched.
//
// We only intervene once the cwd has actually diverged from where Pi launched.
// While we're still in the start directory the built-ins already resolve
// correctly, so staying out of the way avoids fighting other extensions that
// reroute these tools (e.g. pi-gondolin running them inside a VM).
export function installCwdHooks(pi: ExtensionAPI) {
  if (cwdHooksInstalled) return;
  cwdHooksInstalled = true;

  pi.on("tool_call", (event) => {
    const cwd = process.cwd();
    if (cwd === startCwd) return;

    if (event.toolName === "bash") {
      const input = event.input as { command?: string };
      if (typeof input.command === "string") {
        input.command = `cd -- ${shellQuote(cwd)}\n${input.command}`;
      }
      return;
    }

    if (!PATH_TOOLS.has(event.toolName)) return;

    const input = event.input as { path?: string; file_path?: string };
    let hasPath = false;
    for (const key of ["path", "file_path"] as const) {
      const value = input[key];
      if (typeof value === "string" && value.length > 0) {
        input[key] = resolve(cwd, value);
        hasPath = true;
      }
    }
    // ls/grep/find default to their captured cwd when no path is given; pin
    // them to the live cwd instead.
    if (!hasPath) {
      input.path = cwd;
    }
  });

  // User `!`/`!!` bash runs through executeBash, not the bash tool, so it needs
  // its own redirect to the live cwd.
  pi.on("user_bash", (event) => {
    const cwd = process.cwd();
    if (cwd === startCwd || event.cwd === cwd) return undefined;

    const local = createLocalBashOperations();
    return {
      operations: {
        ...local,
        exec(command, _cwd, options) {
          return local.exec(command, cwd, options);
        },
      },
    };
  });
}

async function createEmptySession(
  targetCwd: string,
): Promise<string | undefined> {
  const emptySession = SessionManager.create(targetCwd);
  const replacementSession = emptySession.getSessionFile();
  const header = emptySession.getHeader();
  if (replacementSession && header) {
    await writeFile(replacementSession, `${JSON.stringify(header)}\n`, "utf8");
  }
  return replacementSession;
}

async function replacementSessionFor(
  sourceSession: string,
  targetCwd: string,
  sourceIsEmpty: boolean,
): Promise<string | undefined> {
  if (sourceIsEmpty) {
    return createEmptySession(targetCwd);
  }

  try {
    return SessionManager.forkFrom(sourceSession, targetCwd).getSessionFile();
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    if (!message.includes("source session file is empty or invalid")) {
      throw err;
    }

    return createEmptySession(targetCwd);
  }
}

export async function switchSessionToCwd(
  ctx: ExtensionCommandContext,
  targetCwd: string,
  options: {
    emptySessionMessage: string;
    cancelledMessage: string;
    notification: string;
  },
): Promise<boolean> {
  if (gondolinActive()) {
    ctx.ui.notify(
      "Gondolin is active; run /gondolin off before changing directory",
      "error",
    );
    return false;
  }

  const sourceSession = ctx.sessionManager.getSessionFile();
  if (!sourceSession) {
    ctx.ui.notify(options.emptySessionMessage, "error");
    return false;
  }

  const replacementSession = await replacementSessionFor(
    sourceSession,
    targetCwd,
    ctx.sessionManager.getEntries().length === 0,
  );
  if (!replacementSession) {
    ctx.ui.notify("Failed to persist replacement session", "error");
    return false;
  }

  const result = await ctx.switchSession(replacementSession, {
    withSession: async (newCtx) => {
      newCtx.ui.notify(options.notification, "info");
    },
  });

  if (result.cancelled) {
    ctx.ui.notify(options.cancelledMessage, "warning");
    return false;
  }

  process.chdir(targetCwd);
  return true;
}

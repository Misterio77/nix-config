import { writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import process from "node:process";
import type {
  ExtensionAPI,
  ExtensionCommandContext,
} from "@earendil-works/pi-coding-agent";
import {
  createLocalBashOperations,
  isToolCallEventType,
  SessionManager,
} from "@earendil-works/pi-coding-agent";

let cwdBashHooksInstalled = false;

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

export function installCwdBashHooks(pi: ExtensionAPI) {
  if (cwdBashHooksInstalled) return;
  cwdBashHooksInstalled = true;

  pi.on("tool_call", (event) => {
    if (!isToolCallEventType("bash", event)) return;

    event.input.command = `cd -- ${shellQuote(process.cwd())}\n${event.input.command}`;
  });

  pi.on("user_bash", (event) => {
    const cwd = process.cwd();
    if (event.cwd === cwd) return undefined;

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

export async function replacementSessionFor(
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

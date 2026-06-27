import { randomUUID } from "node:crypto";
import { existsSync } from "node:fs";
import { mkdir } from "node:fs/promises";
import { tmpdir } from "node:os";
import { basename, join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { installCwdBashHooks, switchSessionToCwd } from "./lib/cwd.js";

const timeoutMs = 30_000;

function slugify(input: string): string {
  return input
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9._-]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 80);
}

function defaultWorkspaceName(): string {
  return `pi-${randomUUID().slice(0, 8)}`;
}

async function run(
  pi: ExtensionAPI,
  command: string,
  args: string[],
  cwd: string,
  errorPrefix: string,
) {
  const result = await pi.exec(command, args, { cwd, timeout: timeoutMs });
  if (result.code !== 0) {
    const output = (result.stderr || result.stdout).trim();
    throw new Error(`${errorPrefix}: ${output || `exit code ${result.code}`}`);
  }
  return result.stdout.trim();
}

function workspaceBase(root: string): string {
  return join(tmpdir(), "pi-jj-workspaces", basename(root));
}

export default function jjWorkspace(pi: ExtensionAPI) {
  installCwdBashHooks(pi);

  pi.registerCommand("workspace", {
    description:
      "Create a jj workspace under /tmp and fork this Pi session into it",
    handler: async (args, ctx) => {
      await ctx.waitForIdle();

      const root = await run(pi, "jj", ["root"], ctx.cwd, "Not in a jj repo");
      const requestedName = args.trim();
      let workspaceName = slugify(requestedName || defaultWorkspaceName());

      if (!workspaceName && ctx.hasUI) {
        const input = await ctx.ui.input("Workspace name", "feature-name");
        workspaceName = slugify(input ?? "");
      }

      if (!workspaceName) {
        ctx.ui.notify("Workspace name is empty", "error");
        return;
      }

      const workspacesDir = workspaceBase(root);
      const workspacePath = join(workspacesDir, workspaceName);
      if (existsSync(workspacePath)) {
        ctx.ui.notify(
          `Workspace path already exists: ${workspacePath}`,
          "error",
        );
        return;
      }

      await mkdir(workspacesDir, { recursive: true });
      await run(
        pi,
        "jj",
        ["workspace", "add", workspacePath, "--name", workspaceName],
        root,
        "Failed to create jj workspace",
      );

      await switchSessionToCwd(ctx, workspacePath, {
        emptySessionMessage: "/workspace needs a persisted session",
        cancelledMessage: `Created jj workspace, but session switch was cancelled: ${workspacePath}`,
        notification: `Workspace ${workspaceName} ready at ${workspacePath}`,
      });
    },
  });
}

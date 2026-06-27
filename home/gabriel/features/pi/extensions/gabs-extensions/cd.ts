import { stat } from "node:fs/promises";
import { resolve } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { expandHome, switchSessionToCwd } from "./lib/cwd.js";

export default function cd(pi: ExtensionAPI) {
  pi.registerCommand("cd", {
    description: "Fork this Pi session into another directory and switch to it",
    handler: async (args, ctx) => {
      await ctx.waitForIdle();

      let target = args.trim();
      if (!target && ctx.hasUI) {
        target = (await ctx.ui.input("Directory", "~/Projects/foo")) ?? "";
      }

      if (!target) {
        ctx.ui.notify("Usage: /cd <directory>", "error");
        return;
      }

      const targetCwd = resolve(ctx.cwd, expandHome(target));
      const targetStat = await stat(targetCwd).catch(() => undefined);
      if (!targetStat?.isDirectory()) {
        ctx.ui.notify(`Not a directory: ${targetCwd}`, "error");
        return;
      }

      await switchSessionToCwd(ctx, targetCwd, {
        emptySessionMessage: "/cd needs a persisted session",
        cancelledMessage: `Session switch was cancelled: ${targetCwd}`,
        notification: `Changed directory to ${targetCwd}`,
      });
    },
  });
}

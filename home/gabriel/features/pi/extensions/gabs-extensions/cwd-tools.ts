import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { installCwdHooks } from "./lib/cwd.js";

// Routes built-in tools and user bash to the live process.cwd() so /cd and
// /workspace actually move the agent. Registered from a single extension to
// avoid duplicate built-in tool overrides across cd.ts and jj-workspace.ts.
export default function cwdTools(pi: ExtensionAPI) {
  installCwdHooks(pi);
}

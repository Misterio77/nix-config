import { execFileSync } from "node:child_process";
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
  type ExtensionCommandContext,
  type ExtensionContext,
  type ReadOperations,
  type WriteOperations,
} from "@mariozechner/pi-coding-agent";
import {
  createHttpHooks,
  RealFSProvider,
  type SecretDefinition,
  VM,
} from "@earendil-works/gondolin";

const GUEST = "/workspace";
const STATUS = "gondolin";
const STATE = path.join(
  process.env.XDG_STATE_HOME ?? path.join(os.homedir(), ".local/state"),
  "pi/gondolin.json",
);
const AGENT_DIR =
  process.env.PI_CODING_AGENT_DIR ?? path.join(os.homedir(), ".pi/agent");
const GLOBAL_SETTINGS = path.join(AGENT_DIR, "settings.json");
const PROJECT_SETTINGS = path.join(process.cwd(), ".pi/settings.json");
const MODES = new Set(["", "toggle", "status", "on", "off"]);

type Store = { workspaces?: Record<string, boolean> };
type Tool = any;
type JsonSecret = Omit<SecretDefinition, "value"> & {
  value?: string;
  env?: string;
  file?: string;
  cmd?: string | string[];
};
type HttpProxyConfig = {
  allowedHosts?: string[];
  allowedInternalHosts?: string[];
  replaceSecretsInQuery?: boolean;
  blockInternalRanges?: boolean;
  secrets?: Record<string, JsonSecret>;
};
type GondolinConfig = {
  httpProxy?: HttpProxyConfig;
  "http-proxy"?: HttpProxyConfig;
};
type PiSettings = {
  gondolin?: GondolinConfig;
};

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

function readJson(file: string) {
  try {
    return JSON.parse(fs.readFileSync(file, "utf8")) as unknown;
  } catch (err) {
    if ((err as NodeJS.ErrnoException).code === "ENOENT") return {};
    throw err;
  }
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return !!value && typeof value === "object" && !Array.isArray(value);
}

function mergeSettings(a: unknown, b: unknown): unknown {
  if (!isRecord(a) || !isRecord(b)) return b;
  return Object.fromEntries(
    [...new Set([...Object.keys(a), ...Object.keys(b)])].map((key) => [
      key,
      key in b ? mergeSettings(a[key], b[key]) : a[key],
    ]),
  );
}

function loadConfig(): GondolinConfig {
  const settings = mergeSettings(
    readJson(GLOBAL_SETTINGS),
    readJson(PROJECT_SETTINGS),
  ) as PiSettings;
  return settings.gondolin ?? {};
}

function requireStringArray(
  value: unknown,
  name: string,
): string[] | undefined {
  if (value === undefined) return undefined;
  if (Array.isArray(value) && value.every((x) => typeof x === "string")) {
    return value;
  }
  throw new Error(`gondolin: ${name} must be an array of strings`);
}

function resolveConfigPath(file: string) {
  if (file.startsWith("~/")) return path.join(os.homedir(), file.slice(2));
  return path.isAbsolute(file) ? file : path.join(AGENT_DIR, file);
}

function stripTrailingNewline(value: string) {
  return value.replace(/\r?\n$/, "");
}

function readSecretFile(file: string) {
  return stripTrailingNewline(fs.readFileSync(resolveConfigPath(file), "utf8"));
}

function readSecretCmd(cmd: string | string[]) {
  const args = typeof cmd === "string" ? ["/bin/sh", "-lc", cmd] : cmd;
  if (!args.length || args.some((x) => typeof x !== "string")) {
    throw new Error(`gondolin: secret cmd must be a string or string array`);
  }
  return stripTrailingNewline(
    execFileSync(args[0], args.slice(1), {
      cwd: AGENT_DIR,
      encoding: "utf8",
      timeout: 30_000,
    }),
  );
}

type LazySecret = JsonSecret & { envName: string };

function readSecret(name: string, secret: LazySecret) {
  const value =
    secret.value ??
    process.env[secret.envName] ??
    (secret.file ? readSecretFile(secret.file) : undefined) ??
    (secret.cmd ? readSecretCmd(secret.cmd) : undefined);
  if (typeof value !== "string") {
    throw new Error(
      `gondolin: httpProxy.secrets.${name} needs value, env ${secret.envName}, file, or cmd`,
    );
  }
  return value;
}

function unresolvedSecretValue(name: string) {
  return `GONDOLIN_UNRESOLVED_SECRET_${name}_${Math.random()}`;
}

function requestContainsSecretPlaceholder(
  request: Request,
  placeholder: string,
  replaceSecretsInQuery = false,
) {
  for (const value of request.headers.values()) {
    if (value.includes(placeholder)) return true;
  }

  if (!replaceSecretsInQuery) return false;
  try {
    for (const values of new URL(request.url).searchParams.values()) {
      if (values.includes(placeholder)) return true;
    }
  } catch {
    return request.url.includes(placeholder);
  }

  return false;
}

function createHttpProxy(config: GondolinConfig) {
  const httpProxy = config.httpProxy ?? config["http-proxy"];
  if (!httpProxy) return { env: {} };

  const secrets: Record<string, SecretDefinition> = {};
  const lazySecrets = new Map<string, LazySecret>();
  for (const [name, secret] of Object.entries(httpProxy.secrets ?? {})) {
    const envName = secret.env ?? name;
    if (
      secret.value === undefined &&
      process.env[envName] === undefined &&
      secret.file === undefined &&
      secret.cmd === undefined
    ) {
      throw new Error(
        `gondolin: httpProxy.secrets.${name} needs value, env ${envName}, file, or cmd`,
      );
    }

    lazySecrets.set(name, { ...secret, envName });
    secrets[name] = {
      hosts:
        requireStringArray(secret.hosts, `httpProxy.secrets.${name}.hosts`) ??
        [],
      value: unresolvedSecretValue(name),
      placeholder: secret.placeholder,
    };
  }

  const proxy = createHttpHooks({
    allowedHosts: requireStringArray(
      httpProxy.allowedHosts,
      "httpProxy.allowedHosts",
    ),
    allowedInternalHosts: requireStringArray(
      httpProxy.allowedInternalHosts,
      "httpProxy.allowedInternalHosts",
    ),
    replaceSecretsInQuery: httpProxy.replaceSecretsInQuery,
    blockInternalRanges: httpProxy.blockInternalRanges,
    secrets,
  });

  const onRequest = proxy.httpHooks.onRequest;
  proxy.httpHooks.onRequest = async (request) => {
    const usedSecrets: string[] = [];
    try {
      for (const entry of proxy.secretManager.listSecrets()) {
        const secret = lazySecrets.get(entry.name);
        if (
          secret &&
          requestContainsSecretPlaceholder(
            request,
            entry.placeholder,
            httpProxy.replaceSecretsInQuery,
          )
        ) {
          proxy.secretManager.updateSecret(entry.name, {
            value: readSecret(entry.name, secret),
          });
          usedSecrets.push(entry.name);
        }
      }

      return await onRequest?.(request);
    } finally {
      for (const name of usedSecrets) {
        proxy.secretManager.updateSecret(name, {
          value: unresolvedSecretValue(name),
        });
      }
    }
  };

  return proxy;
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

function bashOps(
  vm: VM,
  cwd: string,
  defaultEnv: Record<string, string> = {},
): BashOperations {
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
          env: { ...env(e), ...defaultEnv },
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
  const config = loadConfig();
  const httpProxy = createHttpProxy(config);
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
      httpHooks: "httpHooks" in httpProxy ? httpProxy.httpHooks : undefined,
      env: httpProxy.env,
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

  async function setMode(mode: string, ctx: ExtensionContext, wait = false) {
    if (wait && "waitForIdle" in ctx) {
      await (ctx as ExtensionCommandContext).waitForIdle();
    } else if (!ctx.isIdle()) {
      return ctx.ui.notify("Gondolin can only toggle while idle", "error");
    }
    setEnabled(mode === "" || mode === "toggle" ? !enabled : mode === "on");
    if (enabled) {
      await start(ctx);
      return ctx.ui.notify("Gondolin enabled; tools now run in the VM", "info");
    }

    await stop(ctx);
    status(ctx, "disabled", "muted");
    ctx.ui.notify("Gondolin disabled; tools now run on the host", "info");
  }

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

  pi.registerShortcut("ctrl+g", {
    description: "Toggle Gondolin VM sandboxing",
    handler: (ctx) => setMode("toggle", ctx),
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
            ? `Gondolin enabled${vm ? " and running" : " but not running"}; HTTP proxy: ${"httpHooks" in httpProxy ? "configured" : "off"}`
            : "Gondolin disabled",
          "info",
        );
      }

      await setMode(mode, ctx, true);
    },
  });

  tool(local.read, (v) => createReadTool(cwd, { operations: readOps(v, cwd) }));
  tool(local.write, (v) =>
    createWriteTool(cwd, { operations: writeOps(v, cwd) }),
  );
  tool(local.edit, (v) => createEditTool(cwd, { operations: editOps(v, cwd) }));
  tool(local.bash, (v) =>
    createBashTool(cwd, { operations: bashOps(v, cwd, httpProxy.env) }),
  );

  const onUserBash = pi.on as unknown as (
    event: "user_bash",
    handler: (
      event: unknown,
      ctx: ExtensionContext,
    ) => Promise<{ operations: BashOperations } | undefined>,
  ) => void;

  onUserBash("user_bash", async (_event, ctx) => {
    if (!enabled) return;
    return { operations: bashOps(await start(ctx), cwd, httpProxy.env) };
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

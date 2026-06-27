import { execFile } from "node:child_process";
import { promisify } from "node:util";

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const execFileAsync = promisify(execFile);

const browserUserAgent =
  "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/120 Safari/537.36";

// Cap the text we hand back to the model so a single fetch can't blow up the
// context window. Generous enough for an article, small enough to stay sane.
const FETCH_CHAR_LIMIT = 40_000;

type FetchParams = {
  url: string;
  raw?: boolean;
  maxChars?: number;
};

type SearchParams = {
  query: string;
  count?: number;
};

type SearchResult = {
  title: string;
  url: string;
  snippet: string;
};

export default function web(pi: ExtensionAPI) {
  pi.registerTool({
    name: "web_fetch",
    label: "Web Fetch",
    description:
      "Fetch a URL over HTTP(S) and return its content as Markdown text. " +
      "HTML is stripped to readable text/Markdown by default; pass raw=true to " +
      "get the unprocessed body (useful for JSON/APIs). Output is truncated to " +
      "keep the context manageable.",
    promptSnippet:
      "web_fetch: download a URL and read it as Markdown (raw=true for JSON/raw bodies)",
    parameters: {
      type: "object",
      properties: {
        url: {
          type: "string",
          description: "Absolute http(s) URL to fetch.",
        },
        raw: {
          type: "boolean",
          description:
            "Return the raw response body instead of HTML-to-Markdown conversion. Defaults to false.",
        },
        maxChars: {
          type: "number",
          description: `Maximum characters to return. Defaults to ${FETCH_CHAR_LIMIT}.`,
        },
      },
      required: ["url"],
      additionalProperties: false,
    },
    async execute(_toolCallId, params) {
      const p = params as FetchParams;
      const url = normalizeUrl(p.url);
      if (!url) {
        return errorResult(`Not a valid http(s) URL: ${String(p.url)}`);
      }

      const limit =
        typeof p.maxChars === "number" && p.maxChars > 0
          ? p.maxChars
          : FETCH_CHAR_LIMIT;

      try {
        const { status, body, contentType } = await curlGet(url);
        if (status < 200 || status >= 400) {
          return errorResult(`Fetch failed: HTTP ${status} for ${url}`);
        }

        const isHtml = /html/i.test(contentType) || looksLikeHtml(body);
        const text =
          p.raw || !isHtml ? body.trim() : htmlToMarkdown(body).trim();
        const { output, truncated } = clamp(text, limit);

        const header = `# ${url}\n`;
        const note = truncated
          ? `\n\n[...truncated to ${limit} chars; refetch with a higher maxChars for more]`
          : "";

        return {
          content: [{ type: "text", text: `${header}\n${output}${note}` }],
          details: { url, status, contentType, truncated },
        };
      } catch (error) {
        return errorResult(
          `Fetch error for ${url}: ${error instanceof Error ? error.message : String(error)}`,
        );
      }
    },
  });

  pi.registerTool({
    name: "web_search",
    label: "Web Search",
    description:
      "Search the web and return a ranked list of results (title, URL, snippet). " +
      "Use web_fetch afterwards to read a result in full. Requires a configured " +
      "backend (Kagi API key, Kagi session token, or Brave API key).",
    promptSnippet:
      "web_search: query the web for current information; follow up with web_fetch to read a result",
    parameters: {
      type: "object",
      properties: {
        query: { type: "string", description: "Search query." },
        count: {
          type: "number",
          description: "Number of results to return (1-20). Defaults to 8.",
        },
      },
      required: ["query"],
      additionalProperties: false,
    },
    async execute(_toolCallId, params) {
      const p = params as SearchParams;
      const query = (p.query ?? "").trim();
      if (!query) return errorResult("Empty search query.");
      const count = clampCount(p.count, 8);

      const backend = await selectBackend();
      if (!backend) {
        return errorResult(
          "No web_search backend configured. Set one of:\n" +
            "  - KAGI_API_KEY (or `pass api.kagi.com`) — Kagi Search API, billed per query\n" +
            "  - KAGI_SESSION_TOKEN (or `pass kagi.com/session`) — your Kagi session cookie; rides your subscription, no API key needed\n" +
            "  - BRAVE_API_KEY (or `pass api.search.brave.com`) — Brave Search API, free tier 2k/mo",
        );
      }

      try {
        const results = await backend.search(query, count);
        if (results.length === 0) {
          return {
            content: [{ type: "text", text: `No results for "${query}".` }],
            details: { backend: backend.name, query, count: 0 },
          };
        }
        const text = [
          `Search results for "${query}" (via ${backend.name}):`,
          "",
          ...results.map(
            (r, i) =>
              `${i + 1}. ${r.title}\n   ${r.url}${r.snippet ? `\n   ${r.snippet}` : ""}`,
          ),
        ].join("\n");
        return {
          content: [{ type: "text", text }],
          details: { backend: backend.name, query, count: results.length },
        };
      } catch (error) {
        return errorResult(
          `Search failed (${backend.name}): ${error instanceof Error ? error.message : String(error)}`,
        );
      }
    },
  });
}

// --- backends -------------------------------------------------------------

type Backend = {
  name: string;
  search(query: string, count: number): Promise<SearchResult[]>;
};

async function selectBackend(): Promise<Backend | undefined> {
  const kagiKey = await resolveKey("KAGI_API_KEY", "api.kagi.com");
  if (kagiKey) return kagiBackend(kagiKey);
  const kagiToken = await resolveKey("KAGI_SESSION_TOKEN", "kagi.com/session");
  if (kagiToken) return kagiSessionBackend(kagiToken);
  const braveKey = await resolveKey("BRAVE_API_KEY", "api.search.brave.com");
  if (braveKey) return braveBackend(braveKey);
  return undefined;
}

function kagiBackend(key: string): Backend {
  return {
    name: "kagi",
    async search(query, count) {
      const url = `https://kagi.com/api/v0/search?q=${encodeURIComponent(query)}&limit=${count}`;
      const { status, body } = await curlGet(url, [
        "-H",
        `Authorization: Bot ${key}`,
      ]);
      if (status < 200 || status >= 300) {
        throw new Error(`HTTP ${status}: ${body.slice(0, 200)}`);
      }
      const parsed = JSON.parse(body) as {
        data?: Array<{
          t?: number;
          title?: string;
          url?: string;
          snippet?: string;
        }>;
      };
      return (parsed.data ?? [])
        .filter((item) => item.t === 0 && item.url)
        .slice(0, count)
        .map((item) => ({
          title: item.title ?? item.url ?? "",
          url: item.url ?? "",
          snippet: stripTags(item.snippet ?? ""),
        }));
    },
  };
}

// Session-token backend: drives Kagi's lightweight /html/search endpoint with a
// browser `kagi_session` cookie instead of the official (invite-only, metered)
// Search API. Same idea as the kagi-ken project. Keep it to human-scale volume —
// it rides your normal subscription session, so automated bursts are the thing
// most likely to draw attention.
function kagiSessionBackend(token: string): Backend {
  return {
    name: "kagi (session)",
    async search(query, count) {
      const url = `https://kagi.com/html/search?q=${encodeURIComponent(query)}`;
      const { status, body } = await curlGet(url, [
        "-H",
        `Cookie: kagi_session=${token}`,
      ]);
      if (status === 401 || status === 403) {
        throw new Error("invalid or expired session token");
      }
      if (status < 200 || status >= 300) {
        throw new Error(`HTTP ${status}: ${body.slice(0, 200)}`);
      }
      return parseKagiHtml(body, count);
    },
  };
}

function braveBackend(key: string): Backend {
  return {
    name: "brave",
    async search(query, count) {
      const url = `https://api.search.brave.com/res/v1/web/search?q=${encodeURIComponent(query)}&count=${count}`;
      const { status, body } = await curlGet(url, [
        "-H",
        "Accept: application/json",
        "-H",
        `X-Subscription-Token: ${key}`,
      ]);
      if (status < 200 || status >= 300) {
        throw new Error(`HTTP ${status}: ${body.slice(0, 200)}`);
      }
      const parsed = JSON.parse(body) as {
        web?: {
          results?: Array<{
            title?: string;
            url?: string;
            description?: string;
          }>;
        };
      };
      return (parsed.web?.results ?? []).slice(0, count).map((item) => ({
        title: stripTags(item.title ?? item.url ?? ""),
        url: item.url ?? "",
        snippet: stripTags(item.description ?? ""),
      }));
    },
  };
}

async function resolveKey(
  envVar: string,
  passPath: string,
): Promise<string | undefined> {
  const fromEnv = process.env[envVar]?.trim();
  if (fromEnv) return fromEnv;
  try {
    const { stdout } = await execFileAsync("pass", ["show", passPath], {
      encoding: "utf8",
      timeout: 10_000,
    });
    const first = stdout.split("\n")[0]?.trim();
    return first || undefined;
  } catch {
    return undefined;
  }
}

// Parse Kagi's /html/search markup into results. Mirrors the selectors kagi-ken
// relies on (`.search-result` / grouped `.__srgi`, with `.__sri_title_link` /
// `.__srgi-title a` titles and `.__sri-desc` snippets), but with regexes to stay
// dependency-free. Fragile by nature: if Kagi reshuffles its HTML this returns
// fewer/no results rather than crashing.
function parseKagiHtml(html: string, count: number): SearchResult[] {
  const results: SearchResult[] = [];
  const chunks = html.split(
    /<div\b[^>]*class=["'][^"']*(?:search-result|__srgi(?=["'\s]))/i,
  );
  for (const chunk of chunks.slice(1)) {
    if (results.length >= count) break;
    let link = extractAnchor(chunk, /__sri_title_link/i);
    if (!link) {
      const idx = chunk.search(/__srgi-title/i);
      if (idx >= 0) link = extractAnchor(chunk.slice(idx), /href=/i);
    }
    if (!link) continue;
    const snippet = chunk.match(
      /class=["'][^"']*__sri-desc[^"']*["'][^>]*>([\s\S]*?)<\/(?:div|span|p)>/i,
    )?.[1];
    results.push({
      title: link.title,
      url: link.url,
      snippet: snippet ? stripTags(snippet) : "",
    });
  }
  return results;
}

// Find the first <a> whose attributes match `attrRe` and that carries a usable
// href, returning its href + plain-text title.
function extractAnchor(
  html: string,
  attrRe: RegExp,
): { url: string; title: string } | null {
  const re = /<a\b([^>]*)>([\s\S]*?)<\/a>/gi;
  let m: RegExpExecArray | null;
  while ((m = re.exec(html))) {
    const attrs = m[1];
    if (!attrRe.test(attrs)) continue;
    const href = attrs.match(/href=["']([^"']*)["']/i)?.[1];
    if (!href || href.startsWith("#")) continue;
    const title = stripTags(m[2]);
    if (!title) continue;
    return { url: href, title };
  }
  return null;
}

// --- http -----------------------------------------------------------------

async function curlGet(url: string, extraArgs: string[] = []) {
  const args = [
    "-sS",
    "-L",
    "--compressed",
    "--max-time",
    "30",
    "-A",
    browserUserAgent,
    ...extraArgs,
    "-w",
    "\n%{http_code}\t%{content_type}",
    url,
  ];
  const { stdout } = await execFileAsync("curl", args, {
    encoding: "utf8",
    maxBuffer: 16 * 1024 * 1024,
  });
  const marker = stdout.lastIndexOf("\n");
  const body = marker === -1 ? stdout : stdout.slice(0, marker);
  const meta = marker === -1 ? "" : stdout.slice(marker + 1);
  const [statusText, contentType = ""] = meta.split("\t");
  return { status: Number(statusText) || 0, body, contentType };
}

// --- helpers --------------------------------------------------------------

function normalizeUrl(value: string): string | undefined {
  if (typeof value !== "string") return undefined;
  const trimmed = value.trim();
  try {
    const u = new URL(trimmed);
    return u.protocol === "http:" || u.protocol === "https:"
      ? u.toString()
      : undefined;
  } catch {
    return undefined;
  }
}

function clampCount(value: number | undefined, fallback: number): number {
  if (typeof value !== "number" || !Number.isFinite(value)) return fallback;
  return Math.max(1, Math.min(20, Math.round(value)));
}

function clamp(text: string, limit: number) {
  if (text.length <= limit) return { output: text, truncated: false };
  return { output: text.slice(0, limit), truncated: true };
}

function errorResult(message: string) {
  return {
    content: [{ type: "text" as const, text: message }],
    isError: true,
    details: { error: message } as Record<string, unknown>,
  };
}

function looksLikeHtml(body: string) {
  return /<(!doctype html|html|body|div|p|a |h[1-6]|head)\b/i.test(
    body.slice(0, 2000),
  );
}

function stripTags(html: string) {
  return decodeEntities(html.replace(/<[^>]+>/g, ""))
    .replace(/\s+/g, " ")
    .trim();
}

// Dependency-free HTML -> Markdown good enough for the model to read. Not a
// full DOM parser; it drops non-content elements and maps common block/inline
// tags, then normalizes whitespace.
function htmlToMarkdown(html: string): string {
  let s = html;

  // Drop everything we never want as text.
  s = s.replace(/<!--[\s\S]*?-->/g, "");
  s = s.replace(
    /<(script|style|noscript|template|svg|head|nav|footer|form|iframe)\b[^>]*>[\s\S]*?<\/\1>/gi,
    "",
  );

  // Code/pre: preserve content, fence it.
  s = s.replace(/<pre\b[^>]*>([\s\S]*?)<\/pre>/gi, (_m, inner) => {
    return `\n\n\`\`\`\n${decodeEntities(inner.replace(/<[^>]+>/g, "")).trim()}\n\`\`\`\n\n`;
  });
  s = s.replace(/<code\b[^>]*>([\s\S]*?)<\/code>/gi, (_m, inner) => {
    return `\`${decodeEntities(inner.replace(/<[^>]+>/g, "")).trim()}\``;
  });

  // Headings.
  s = s.replace(/<h([1-6])\b[^>]*>([\s\S]*?)<\/h\1>/gi, (_m, level, inner) => {
    return `\n\n${"#".repeat(Number(level))} ${stripTags(inner)}\n\n`;
  });

  // Links: [text](href).
  s = s.replace(
    /<a\b[^>]*?href=["']([^"']*)["'][^>]*>([\s\S]*?)<\/a>/gi,
    (_m, href, inner) => {
      const text = stripTags(inner);
      if (!text) return "";
      return href && !href.startsWith("#") ? `[${text}](${href})` : text;
    },
  );

  // List items.
  s = s.replace(/<li\b[^>]*>([\s\S]*?)<\/li>/gi, (_m, inner) => {
    return `\n- ${stripTags(inner)}`;
  });

  // Emphasis.
  s = s.replace(/<(strong|b)\b[^>]*>([\s\S]*?)<\/\1>/gi, "**$2**");
  s = s.replace(/<(em|i)\b[^>]*>([\s\S]*?)<\/\1>/gi, "*$2*");

  // Block separators.
  s = s.replace(
    /<(p|div|section|article|tr|ul|ol|table|h[1-6])\b[^>]*>/gi,
    "\n\n",
  );
  s = s.replace(/<br\b[^>]*>/gi, "\n");

  // Strip remaining tags, decode entities.
  s = s.replace(/<[^>]+>/g, "");
  s = decodeEntities(s);

  // Normalize whitespace: trim lines, collapse runs of blank lines.
  s = s
    .split("\n")
    .map((line) => line.replace(/[ \t\f\v]+/g, " ").trimEnd())
    .join("\n")
    .replace(/\n{3,}/g, "\n\n");

  return s;
}

function decodeEntities(text: string): string {
  const named: Record<string, string> = {
    amp: "&",
    lt: "<",
    gt: ">",
    quot: '"',
    apos: "'",
    nbsp: " ",
    mdash: "—",
    ndash: "–",
    hellip: "…",
    copy: "©",
    reg: "®",
    trade: "™",
    rsquo: "’",
    lsquo: "‘",
    rdquo: "”",
    ldquo: "“",
  };
  return text
    .replace(/&#x([0-9a-f]+);/gi, (_m, hex) =>
      safeFromCodePoint(parseInt(hex, 16)),
    )
    .replace(/&#(\d+);/g, (_m, dec) => safeFromCodePoint(parseInt(dec, 10)))
    .replace(/&([a-z0-9]+);/gi, (m, name) => named[name.toLowerCase()] ?? m);
}

function safeFromCodePoint(code: number): string {
  try {
    return String.fromCodePoint(code);
  } catch {
    return "";
  }
}

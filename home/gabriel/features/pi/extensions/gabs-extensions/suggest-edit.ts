import fs from "node:fs";
import os from "node:os";
import path from "node:path";

import type {
  ExtensionAPI,
  ExtensionCommandContext,
} from "@earendil-works/pi-coding-agent";

const STATE_DIR = path.join(
  process.env.XDG_STATE_HOME ?? path.join(os.homedir(), ".local/state"),
  "llm-suggest",
);
const SUGGESTIONS_FILE =
  process.env.LLM_SUGGEST_FILE ?? path.join(STATE_DIR, "suggestions.json");

type Suggestion = {
  id: string;
  file: string;
  title?: string;
  message: string;
  replacement: string;
  severity: number;
  wholeLine?: boolean;
  range: {
    start: { line: number; character: number };
    end: { line: number; character: number };
  };
  createdAt: string;
};

type SuggestEditParams = {
  file: string;
  startLine: number;
  startColumn?: number;
  endLine: number;
  endColumn?: number;
  message: string;
  replacement: string;
  title?: string;
  severity?: "error" | "warning" | "info" | "hint";
  wholeLine?: boolean;
};

type ClearParams = {
  file?: string;
};

function readSuggestions(): Suggestion[] {
  try {
    const data = JSON.parse(
      fs.readFileSync(SUGGESTIONS_FILE, "utf8"),
    ) as unknown;
    return Array.isArray(data) ? (data as Suggestion[]) : [];
  } catch (err) {
    if ((err as NodeJS.ErrnoException).code === "ENOENT") return [];
    throw err;
  }
}

function writeSuggestions(suggestions: Suggestion[]) {
  fs.mkdirSync(STATE_DIR, { recursive: true });
  fs.writeFileSync(
    SUGGESTIONS_FILE,
    `${JSON.stringify(suggestions, null, 2)}\n`,
  );
}

function resolveFile(file: string) {
  return path.resolve(process.cwd(), file);
}

function severity(value: SuggestEditParams["severity"]) {
  switch (value) {
    case "error":
      return 1;
    case "warning":
      return 2;
    case "hint":
      return 4;
    case "info":
    default:
      return 3;
  }
}

function lspPosition(line: number, column = 1) {
  return {
    line: Math.max(0, line - 1),
    character: Math.max(0, column - 1),
  };
}

function isWholeLineSuggestion(params: SuggestEditParams) {
  return (
    params.wholeLine === true ||
    (params.startColumn === 0 && (params.endColumn ?? 0) === 0)
  );
}

function lspRange(params: SuggestEditParams) {
  if (isWholeLineSuggestion(params)) {
    return {
      start: { line: Math.max(0, params.startLine - 1), character: 0 },
      end: { line: Math.max(0, params.endLine), character: 0 },
    };
  }

  return {
    start: lspPosition(params.startLine, params.startColumn),
    end: lspPosition(params.endLine, params.endColumn ?? params.startColumn),
  };
}

function normalizeReplacement(params: SuggestEditParams) {
  if (!isWholeLineSuggestion(params) || params.replacement.endsWith("\n")) {
    return params.replacement;
  }
  return `${params.replacement}\n`;
}

function normalizePath(file: string) {
  try {
    return fs.realpathSync(file);
  } catch {
    return path.resolve(file);
  }
}

export default function suggestEdit(pi: ExtensionAPI) {
  pi.registerTool({
    name: "suggest_edit",
    label: "Suggest Edit",
    description:
      "Publish an editor-visible suggested edit. Helix shows it as a LLM diagnostic; code actions apply the replacement.",
    promptSnippet:
      "suggest_edit: propose a non-invasive editor quickfix instead of directly editing a file",
    parameters: {
      type: "object",
      properties: {
        file: {
          type: "string",
          description:
            "File to annotate, absolute or relative to the current working directory.",
        },
        startLine: { type: "number", description: "1-based start line." },
        startColumn: {
          type: "number",
          description:
            "1-based start column; defaults to 1. Use 0 with endColumn 0 for whole-line replacement.",
        },
        endLine: {
          type: "number",
          description:
            "1-based inclusive end line. For whole-line replacement, the edit covers through this entire line.",
        },
        endColumn: {
          type: "number",
          description:
            "1-based end column; defaults to startColumn. Use 0 with startColumn 0 for whole-line replacement.",
        },
        message: {
          type: "string",
          description: "Diagnostic message shown in the editor.",
        },
        replacement: {
          type: "string",
          description: "Replacement text applied by the code action.",
        },
        title: {
          type: "string",
          description: "Optional short code-action title.",
        },
        severity: {
          type: "string",
          enum: ["error", "warning", "info", "hint"],
          description: "Diagnostic severity; defaults to info.",
        },
        wholeLine: {
          type: "boolean",
          description:
            "Replace whole lines from startLine through endLine. Replacement may omit the final newline.",
        },
      },
      required: ["file", "startLine", "endLine", "message", "replacement"],
      additionalProperties: false,
    },
    async execute(_toolCallId, params) {
      const p = params as SuggestEditParams;
      const file = resolveFile(p.file);
      const suggestion: Suggestion = {
        id: `${Date.now()}-${Math.random().toString(36).slice(2)}`,
        file,
        title: p.title,
        message: p.message,
        replacement: normalizeReplacement(p),
        severity: severity(p.severity),
        wholeLine: isWholeLineSuggestion(p),
        range: lspRange(p),
        createdAt: new Date().toISOString(),
      };

      writeSuggestions([...readSuggestions(), suggestion]);

      return {
        content: [
          {
            type: "text",
            text: `Published LLM suggested edit for ${path.relative(process.cwd(), file)}.`,
          },
        ],
        details: { file, id: suggestion.id },
      };
    },
  });

  pi.registerTool({
    name: "clear_suggested_edits",
    label: "Clear Suggested Edits",
    description: "Clear LLM editor suggestions, optionally only for one file.",
    parameters: {
      type: "object",
      properties: {
        file: {
          type: "string",
          description: "Optional file whose suggestions should be cleared.",
        },
      },
      additionalProperties: false,
    },
    async execute(_toolCallId, params) {
      const p = params as ClearParams;
      const before = readSuggestions();
      const after = p.file
        ? before.filter(
            (item) =>
              normalizePath(item.file) !== normalizePath(resolveFile(p.file!)),
          )
        : [];
      writeSuggestions(after);
      return {
        content: [
          {
            type: "text",
            text: `Cleared ${before.length - after.length} LLM suggested edit(s).`,
          },
        ],
        details: { cleared: before.length - after.length },
      };
    },
  });

  pi.registerCommand("suggest-clear", {
    description: "Clear LLM editor suggestions, optionally for a path",
    handler: async (args: string, ctx: ExtensionCommandContext) => {
      const before = readSuggestions();
      const file = args.trim();
      const after = file
        ? before.filter(
            (item) =>
              normalizePath(item.file) !== normalizePath(resolveFile(file)),
          )
        : [];
      writeSuggestions(after);
      ctx.ui.notify(
        `Cleared ${before.length - after.length} LLM suggested edit(s)`,
        "info",
      );
    },
  });
}

---
name: web-fetch
description: Fetch a web page or HTTP(S) URL and read it as text/Markdown. Use when you need the full content of a URL — e.g. a search result from web_search, a changelog, docs, or an API response.
---

# Fetching web pages

There is no `web_fetch` tool on purpose: fetching runs through the `bash` tool so
it inherits the active environment. When the Gondolin sandbox is on, the request
goes through the VM and its HTTP proxy (host allowlist); when it's off, it runs on
the host. A dedicated tool would bypass that, so use `bash` instead.

## HTML pages → Markdown

Pipe `curl` into `trafilatura` to extract the article/body text as Markdown:

```bash
curl -sSL --compressed -A "Mozilla/5.0" 'https://example.com/article' \
  | trafilatura --markdown
```

Notes:

- Quote the URL (single quotes) so query strings with `&`/`?` aren't mangled.
- `-sSL` is silent + show-errors + follow-redirects; `--compressed` handles gzip.
- The `-A` browser user-agent avoids some naive bot blocks.
- Use `trafilatura --markdown --links` when preserving links matters.
- For long pages, pipe through `head -c <bytes>` or `sed -n '1,400p'` rather than
  dumping the whole thing into context.

## Raw bodies (JSON / APIs / plain text)

Skip pandoc — fetch directly and parse as needed:

```bash
curl -sSL 'https://api.example.com/thing' | jq .      # JSON
curl -sSL 'https://example.com/raw.txt'                # plain text
```

## Tips

- If a fetch returns an anti-bot landing page or a `40x`/`429`, don't hammer it —
  report what came back.
- To find a URL in the first place, use the `web_search` tool, then fetch the
  result you want with the commands above.
- trafilatura can target other formats (`--txt`, `--json`, `--html`) if Markdown
  output is noisy for a given page.

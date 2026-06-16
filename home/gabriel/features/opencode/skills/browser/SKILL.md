---
name: browser
description: Automate web browsers — navigate, click, fill forms, extract data, take screenshots.
---

## Script

The helper script lives at `scripts/browser.py` relative to this skill's root
directory (`~/.config/opencode/skills/browser/scripts/browser.py`).

Run directly as an executable, it has the correct shebang.

```
~/.config/opencode/skills/browser/scripts/browser.py <args>
```

---

## Actions (JSON array)

Every call is a JSON array of step objects, executed sequentially in one
browser session. Results are printed as JSON on stdout.

### navigate

```
{"action": "navigate", "url": "https://example.com"}
```

### click

```
{"action": "click", "selector": "#submit-button"}
```

### fill (form input)

```
{"action": "fill", "selector": "#search", "text": "query"}
```

### extract

Get full page HTML (omit selector) or text from a specific element:

```
{"action": "extract"}
{"action": "extract", "selector": "main"}
```

Returns `data` in the result object.

### screenshot

```
{"action": "screenshot", "path": "/tmp/opencode/screenshot.png"}
{"action": "screenshot", "path": "/tmp/opencode/page.png", "full_page": true}
```

### js (execute JavaScript)

```
{"action": "js", "code": "document.title"}
{"action": "js", "code": "document.querySelectorAll('a').length"}
```

Returns `result` in the result object.

### wait

```
{"action": "wait", "selector": ".loaded"}
{"action": "wait", "selector": "#dynamic-content", "timeout": 5000}
```

### sleep

```
{"action": "sleep", "seconds": 2}
```

### Error handling

By default, errors are collected per-step and execution continues. Set
`"fatal": true` on a step to abort the whole session on failure:

```
{"action": "navigate", "url": "...", "fatal": true}
```

---

## Usage patterns

### Single command

```
~/.config/opencode/skills/browser/scripts/browser.py '[{"action":"navigate","url":"https://example.com"},{"action":"extract"}]'
```

### Visible browser (debugging)

Add `--visible` to watch what the browser is doing:

```
browser.py --visible [...]
```

### Persistent sessions

Use `--persist` to keep cookies, localStorage, and other session state across
invocations. State is saved to `/tmp/opencode/browser-session/` by default.

```
browser.py --persist '[{"action":"navigate","url":"https://example.com/login"}, ...]'
browser.py --persist '[{"action":"navigate","url":"https://example.com/dashboard"}, ...]'
```

Pass `--session-dir` to control where session data is stored:

```
browser.py --persist --session-dir /tmp/my-project-session [...]
```

### Screenshot + image analysis

Capture a page and analyze it with the `image-analyzer` agent:

```
# Step 1: take screenshot
browser.py '[{"action":"navigate","url":"https://..."},{"action":"screenshot","path":"/tmp/opencode/shot.png"}]'

# Step 2: analyze with vision
task(description="Analyze page screenshot", prompt="Describe what you see in /tmp/opencode/shot.png", subagent_type="image-analyzer")
```

### Login flow

```
[
  {"action": "navigate", "url": "https://example.com/login"},
  {"action": "fill", "selector": "#username", "text": "user"},
  {"action": "fill", "selector": "#password", "text": "pass"},
  {"action": "click", "selector": "#login-button"},
  {"action": "wait", "selector": ".dashboard"},
  {"action": "extract", "selector": ".dashboard"}
]
```

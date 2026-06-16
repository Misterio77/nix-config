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

### Stealth mode (anti-bot-detection)

Use `--stealth` to bypass Cloudflare and other bot detectors in headless mode.
It overrides the user agent, hides `navigator.webdriver`, adds plugin/mimicry,
and disables automation-controlled blink features.

```
browser.py --stealth [...]
```

Combine with `--persist` for logged-in sessions:

```
browser.py --stealth --persist '[{"action":"navigate","url":"https://reddit.com"}]'
```

### Captcha / bot detection handling

If a site blocks the headless browser even with `--stealth` (Cloudflare,
captcha, etc.), **do not retry headless**. Instead:

1. Take a screenshot and analyze it with `image-analyzer` to confirm the block.
2. Send a `notify-send` telling Gabs what site blocked you.
3. Re-run the **same steps** with `--visible` so Gabs can handle the challenge.

After Gabs completes the challenge and you see the expected page, take another
screenshot to confirm and report back.

### Visible browser (captchas / debugging)

Only use `--visible` when:
- A captcha or bot-blocker was detected (see above), OR
- The user explicitly asks for it

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

**Real-world example — Reddit login with `pass` and stealth:**

Passwords stored in `pass` often span multiple lines (password on line 1,
OTP/username on subsequent lines). Use `splitlines()[0]` to grab just the
password. Wrap in a Python helper to keep the secret out of context:

```python
import subprocess, json, os

browser = os.path.expanduser('~/.config/opencode/skills/browser/scripts/browser.py')
pwd = subprocess.run(['pass', 'site.com/user'], capture_output=True, text=True).stdout.splitlines()[0]

steps = [
    {"action": "navigate", "url": "https://site.com/login"},
    {"action": "fill", "selector": "input[name=username]", "text": "user"},
    {"action": "fill", "selector": "input[name=password]", "text": pwd},
    {"action": "click", "selector": 'button:has-text("Log In")'},
    {"action": "sleep", "seconds": 5},
    {"action": "screenshot", "path": "/tmp/opencode/loggedin.png"},
]

subprocess.run([browser, '--stealth', '--persist', json.dumps(steps)])
```

Notes from the trenches:
- Sites like Reddit use `button:has-text("Log In")` for the submit button, not
  `button[type=submit]` (which often matches invisible elements).
- Always add a `navigate` step before filling — the persisted session doesn't
  carry the page content, only cookies/storage.
- Use `--persist` to keep login sessions across invocations so subsequent calls
  don't need to re-authenticate.

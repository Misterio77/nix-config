#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p "python3.withPackages (ps: with ps; [ playwright ])" -p chromium
"""Browser automation via Playwright + Chromium.

Usage:
    browser.py [options] <steps.json>

Steps is a JSON array of action objects. Each action has an "action" key
and action-specific parameters. Actions execute sequentially in a single
browser session.

Actions:
  {"action": "navigate",  "url": "https://...", "wait_until": "networkidle|load|domcontentloaded"}
                          — default wait_until: "networkidle"
  {"action": "click",     "selector": "css-selector"}
  {"action": "fill",      "selector": "css-selector", "text": "value"}
  {"action": "extract",   "selector": "css-selector"}  — omit selector for full HTML
  {"action": "screenshot","path": "/tmp/shot.png"}      — default: /tmp/opencode/screenshot.png
  {"action": "js",        "code": "document.title"}
  {"action": "wait",      "selector": "css-selector", "timeout": 5000}

Examples:
    browser.py '[{"action":"navigate","url":"https://example.com"},{"action":"extract"}]'
    browser.py --visible '[{"action":"navigate","url":"https://example.com"},{"action":"screenshot","path":"/tmp/shot.png"}]'
    echo '...' | browser.py --stdin
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time


def find_chromium():
    for name in ("chromium", "chromium-browser", "google-chrome", "chrome"):
        path = shutil.which(name)
        if path:
            return path
    return None


def run_steps(steps, headless=True, session_dir=None):
    chromium_path = find_chromium()
    if not chromium_path:
        print(json.dumps({"error": "chromium not found"}))
        sys.exit(1)

    from playwright.sync_api import sync_playwright

    state_file = os.path.join(session_dir, "state.json") if session_dir else None

    results = []
    with sync_playwright() as p:
        launch_kwargs = {"executable_path": chromium_path, "headless": headless}
        browser = p.chromium.launch(**launch_kwargs)

        context_kwargs = {}
        if state_file and os.path.exists(state_file):
            context_kwargs["storage_state"] = state_file
        context = browser.new_context(**context_kwargs)

        page = context.new_page()
        page.set_default_timeout(30000)

        for step in steps:
            action = step.get("action", "")
            try:
                if action == "navigate":
                    page.goto(step["url"], wait_until=step.get("wait_until", "networkidle"))
                    results.append({"action": "navigate", "url": step["url"], "status": "ok"})

                elif action == "click":
                    page.click(step["selector"])
                    results.append({"action": "click", "selector": step["selector"], "status": "ok"})

                elif action == "fill":
                    page.fill(step["selector"], step["text"])
                    results.append({"action": "fill", "selector": step["selector"], "status": "ok"})

                elif action == "extract":
                    if "selector" in step and step["selector"]:
                        el = page.query_selector_all(step["selector"])
                        data = el.inner_text() if el else ""
                        if not data:
                            data = el.get_attribute("outerHTML") if el else ""
                    else:
                        data = page.content()
                    results.append({"action": "extract", "status": "ok", "data": data})

                elif action == "screenshot":
                    path = step.get("path", "/tmp/opencode/screenshot.png")
                    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
                    page.screenshot(path=path, full_page=step.get("full_page", False))
                    results.append({"action": "screenshot", "status": "ok", "path": path})

                elif action == "js":
                    result = page.evaluate(step["code"])
                    results.append({"action": "js", "status": "ok", "result": result})

                elif action == "wait":
                    timeout = step.get("timeout", 10000)
                    page.wait_for_selector(step["selector"], timeout=timeout)
                    results.append({"action": "wait", "selector": step["selector"], "status": "ok"})

                elif action == "sleep":
                    time.sleep(step.get("seconds", 1))
                    results.append({"action": "sleep", "status": "ok"})

                else:
                    results.append({"action": action, "status": "error", "error": f"unknown action: {action}"})

            except Exception as e:
                results.append({"action": action, "status": "error", "error": str(e)})
                if step.get("fatal", False):
                    break

        if state_file:
            os.makedirs(os.path.dirname(state_file) or ".", exist_ok=True)
            context.storage_state(path=state_file)

        context.close()
        browser.close()

    return results


def main():
    parser = argparse.ArgumentParser(description="Browser automation via Playwright")
    parser.add_argument("steps", nargs="?", help="JSON array of steps")
    parser.add_argument("--stdin", action="store_true", help="Read steps from stdin")
    parser.add_argument("--visible", action="store_true", help="Run with visible browser (not headless)")
    parser.add_argument("--persist", action="store_true", help="Persist session (cookies, localStorage) between runs")
    parser.add_argument("--session-dir", help="Session directory (default: /tmp/opencode/browser-session)")
    args = parser.parse_args()

    if args.stdin:
        raw = sys.stdin.read()
    elif args.steps:
        raw = args.steps
    else:
        parser.print_help()
        sys.exit(1)

    try:
        steps = json.loads(raw)
    except json.JSONDecodeError as e:
        print(json.dumps({"error": f"invalid JSON: {e}"}))
        sys.exit(1)

    session_dir = args.session_dir or "/tmp/opencode/browser-session" if args.persist else None
    results = run_steps(steps, headless=not args.visible, session_dir=session_dir)
    print(json.dumps(results, indent=2))


if __name__ == "__main__":
    main()

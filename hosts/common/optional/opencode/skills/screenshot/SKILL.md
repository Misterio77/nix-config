---
name: screenshot
description: Take screenshots in Wayland/Hyprland or X11 environments using grim or ImageMagick.
---

## Screenshotting

### Detection

Check the display server and compositor before choosing a tool:

- **`$XDG_SESSION_TYPE`** — `wayland` or `x11`
- **`$XDG_CURRENT_DESKTOP`** — `Hyprland`, `sway`, etc.

### Tools by environment

| Environment | Full screen | Focused monitor | Region |
|---|---|---|---|
| Wayland + Hyprland | `grim` | `grim -o $(hyprctl monitors -j \| jq -r '.[] \| select(.focused) \| .name')` | `slurp \| grim -g -` |
| Wayland + wlroots | `grim` | `grim -o <output>` | `slurp \| grim -g -` |
| X11 | `import -window root` | `import -window root -crop <geo>` | `import` (click-drag) |

### Recipes

**Full screen (Wayland):**
```bash
nix run nixpkgs#grim -- /tmp/opencode/screenshot.png
```

**Single monitor (Hyprland):**
```bash
monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
nix run nixpkgs#grim -- -o "$monitor" /tmp/opencode/screenshot.png
```

**Region select (Wayland):**
```bash
nix run nixpkgs#slurp -- | nix run nixpkgs#grim -- -g - /tmp/opencode/screenshot.png
```

**Full screen (X11):**
```bash
nix run nixpkgs#imagemagick -- import -window root /tmp/opencode/screenshot.png
```

### Viewing

Open with the default image viewer:
```bash
handlr open /tmp/opencode/screenshot.png
```

### Analysis

After taking a screenshot, use the `image-analyzer` subagent to describe the image:
```
task(description="Analyze screenshot", prompt="...", subagent_type="image-analyzer")
```

Note: the image-analyzer may hallucinate visual details. Treat its descriptions as approximate.

---
name: edit-skills
description: Edit Gabs's opencode skills (.config/opencode/skills/<name>/SKILL.md), agents (.config/opencode/agents/<name>.md) and context (.config/opencode/AGENTS.md). ALWAYS use this when you plan on writting (creating, editing) to any of the files mentioned.
---

## Context (`~/.config/opencode/AGENTS.md`)

Context cannot be directly edited in `~/.config/opencode`.
- Lives at `~/Projects/NixConfig/home/gabriel/features/opencode/context.md`
- Symlinked by home-manager to `~/.config/opencode/AGENTS.md`
- How to edit:
  - Edit file `~/Projects/NixConfig/home/gabriel/features/opencode/context.md`
  - Use the `question` tool to ask Gabs if they want to rebuild
  - Ask Gabs to restart opencode to take effect

## Agents (`~/.config/opencode/agents/<name>.md`)

Sub-agents and specialized agents. They cannot be directly edited in `~/.config/opencode`

- Lives at `~/Projects/NixConfig/home/gabriel/features/opencode/agents/<name>.md`
- Symlinked by home-manager to `~/.config/opencode/agents/<name>.md`
- How to edit:
  - Edit file `~/Projects/NixConfig/home/gabriel/features/opencode/agents/<name>.md`
  - Use the `question` tool to ask Gabs if they want to rebuild
  - Ask Gabs to restart opencode to take effect
- How to create:
  - Create file `~/Projects/NixConfig/home/gabriel/features/opencode/agents/<name>.md`
  - Use the `question` tool to ask Gabs if they want to rebuild
  - Ask Gabs to restart opencode to take effect


## Opencode config (`default.nix`)

The main opencode settings live at `~/Projects/NixConfig/home/gabriel/features/opencode/default.nix` under `programs.opencode.settings`.

Changes require a rebuild and opencode restart to take effect.


## Skills (`~/.config/opencode/skills/<name>/SKILL.md`)

There are two types of skill. None of them can be directly edited in `~/.config/opencode`.

Always check the type with `readlink -f`.

Home-manager symlinks every file separately, not the whole directories.

### Public

If the skill file at `~/.config/opencode` is a symlink to `/nix/store/<path>`, it's public.

- Lives as .md's in `~/Projects/NixConfig/home/gabriel/features/opencode/skills/<name>/SKILL.md`
- Symlinked to `~/.config/opencode/skills/<name>/SKILL.md` via home-manager, requires rebuild.
- How to edit:
  - Edit file `~/Projects/NixConfig/home/gabriel/features/opencode/skills/<name>/SKILL.md`
  - Use the `question` tool to ask Gabs if they want to rebuild
  - Ask Gabs to restart opencode to take effect
- How to create:
  - Create `~/Projects/NixConfig/home/gabriel/features/opencode/skills/<name>/SKILL.md`
  - Extra files (scripts, references, assets):
    - Put in `~/Projects/NixConfig/home/gabriel/features/opencode/skills/<name>/<file>`
    - Is automatically included when the skill is included
  - Add skill directory to `~/Projects/NixConfig/home/gabriel/featues/opencode/default.nix`, under public skills
  - Use the `question` tool to ask Gabs if they want to rebuild
  - Ask Gabs to restart opencode to take effect

### Private

If the skill file at `~/.config/opencode` is a symlink to `/run/secrets/<path>`, it's private.

- Lives encrypted in sops `~/Projects/NixConfig/home/gabriel/features/opencode/private.yaml`
- Decrypted at activation-time, using host SSH keys (sops-nix).
- How to edit:
  - **IMPORTANT: NEVER DECRYPT ANY OTHER SOPS FILE IN THE NIXCONFIG**
  - Sops requires Gabs' GPG key to decrypt. Lives on his Yubikey. If it errors out, ask him to plug him and wait for his OK before continuing.
  - Run `sops decrypt --extract '["skill-<name>"]' ~/Projects/NixConfig/home/gabriel/features/opencode/private.yaml > /tmp/opencode/skill.md`
  - Edit `/tmp/opencode/skill.md`
  - Run `sops set ~/Projects/NixConfig/home/gabriel/features/opencode/private.yaml '["skill-<name>"]' "$(jq -sR < /tmp/opencode/skill.md)"`
  - Extra (public) files (scripts, references, assets):
    - Put in `~/Projects/NixConfig/home/gabriel/features/opencode/skills/<name>/<file>`
    - Link using `xdg.configFile."opencode/skills/<name>/<file>".source = ./skills/<name>/<file>`
  - Use the `question` tool to ask Gabs if they want to rebuild
  - Ask Gabs to restart opencode to take effect
- How to create:
  - Create `/tmp/opencode/skill.md`
  - Run `sops set ~/Projects/NixConfig/home/gabriel/features/opencode/private.yaml '["skill-<name>"]' "$(jq -sR < /tmp/opencode/skill.md)"`
  - Add `skill-<name>` to `~/Projects/NixConfig/hosts/common/users/gabriel/default.nix`, as a sops secret
  - Add skill to to `~/Projects/NixConfig/home/gabriel/featues/opencode/default.nix`, under private skills
  - Use the `question` tool to ask Gabs if they want to rebuild
  - Ask Gabs to restart opencode to take effect

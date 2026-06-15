---
name: edit-skills
description: Edit Gabs' opencode skills (.config/opencode/skills/<name>/SKILL.md), agents (.config/opencode/agents/<name>.md) and context (.config/opencode/AGENTS.md). ALWAYS use this when you plan on writting (creating, editing) to any of the files mentioned.
---

## Context (`~/.config/opencode/AGENTS.md`)

The context file cannot be directly edited in `~/.config/opencode` — it's symlinked by home-manager.

1. Edit the source file at `~/Projects/NixConfig/home/gabriel/features/opencode/context.md`
2. Ask Gabs if they want to rebuild
3. Ask Gabs to restart opencode to take effect

### Instructions (additional context)

Extra context files can be loaded via the `instructions` array in `default.nix`:

```nix
instructions = [osConfig.sops.secrets.<name>.path];
```

These are merged alongside `context.md` and can reference sops-backed files for private info.

## Agents (`~/.config/opencode/agents/<name>.md`)

Agent files cannot be directly edited in `~/.config/opencode` — they're symlinked by home-manager.

### Creating/Editing an agent

1. Create/Edit `~/Projects/NixConfig/home/gabriel/features/opencode/agents/<name>.md`
2. Ask Gabs if they want to rebuild
3. Ask Gabs to restart opencode to take effect

## Opencode config (`~/.config/opencode/opencode.json`)

The main settings live at `~/Projects/NixConfig/home/gabriel/features/opencode/default.nix`
under `programs.opencode.settings`.

Changes require a rebuild and opencode restart to take effect.


## Skills (`~/.config/opencode/skills/<name>/`)

All skills are public in the NixConfig repo. Skills can have opt-in private resource files (backed by sops).

Do not include any sensitive or personal information in a skill; except in `private.md` resource files (see below).

Skills cannot be directly edited in `~/.config/opencode` — they're symlinked by home-manager.

Home-manager symlinks the entire skill directory (not individual files), so extra files
like scripts, references, and resources are included automatically.

### Creating/Editing a skill

1. Create/Edit `~/Projects/NixConfig/home/gabriel/features/opencode/skills/<name>/SKILL.md`
2. Public resources (scripts, references, assets) go in subdirectories under the skill dir
3. Ask Gabs if they want to rebuild
4. Ask Gabs to restart opencode to take effect

### Adding a private resource to a skill

Private resources are individual files encrypted in sops and linked into the skill's
`resources/` directory. Only the specific file is private — the rest of the skill is public.
Requires Gabs' Yubikey (GPG key) for sops operations.

Private resources live at `~/Projects/NixConfig/home/gabriel/features/opencode/private.yaml`, a sops encrypted file.

1. Create the public skill content in NixConfig (SKILL.md + any public resources)
2. Create the private content in `/tmp/opencode/private.md`
3. Add it to sops:
   ```bash
   sops set ~/Projects/NixConfig/home/gabriel/features/opencode/private.yaml \
     '["skill-<name>-private"]' "$(jq -sR < /tmp/opencode/private.md)"
   ```
   If this fails with a GPG error, Gabs needs to plug in their Yubikey.
4. Add the sops secret in `hosts/common/users/gabriel/default.nix`:
   ```nix
   skill-<name>-private = {
     sopsFile = ../../../../home/gabriel/features/opencode/private.yaml;
     owner = "gabriel";
   };
   ```
5. Add `xdg.configFile` in `default.nix`:
   ```nix
   xdg.configFile."opencode/skills/<name>/resources/private.md".source =
     "${config.lib.file.mkOutOfStoreSymlink osConfig.sops.secrets.skill-<name>-private.path}";
   ```
6. Reference `resources/private.md` from SKILL.md so the agent loads it when needed
7. Ask Gabs if they want to rebuild, then restart opencode

### Editing a private resource

Editing them has an extra step, decrypting the current value beforehand. Requires the Gabs' Yubikey (GPG).

1. Decrypt the current content:
   ```bash
   sops decrypt --extract '["skill-<name>-private"]' \
     ~/Projects/NixConfig/home/gabriel/features/opencode/private.yaml > /tmp/opencode/private.md
   ```
   If this fails with a GPG error, Gabs needs to plug in their Yubikey.
2. Edit `/tmp/opencode/private.md`
3. Re-encrypt and save back to sops:
   ```bash
   sops set ~/Projects/NixConfig/home/gabriel/features/opencode/private.yaml \
     '["skill-<name>-private"]' "$(jq -sR < /tmp/opencode/private.md)"
   ```

4. Ask Gabs if they want to rebuild, then restart opencode

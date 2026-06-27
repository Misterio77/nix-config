---
description: Build NixOS host
argument-hint: "<host> [extra args]"
---
Build host `$1`: `nixos-rebuild build --flake .#$1 ${@:2}`. Follow AGENTS.md.

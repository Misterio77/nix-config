{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  packageNames = map (p: p.pname or p.name or null) config.home.packages;
  hasPackage = name: lib.any (x: x == name) packageNames;
  hasRipgrep = hasPackage "ripgrep";
  hasEza = hasPackage "eza";
  hasSpecialisationCli = hasPackage "specialisation";
  hasAwsCli = hasPackage "awscli2";
  hasNeovim = config.programs.neovim.enable;
  hasEmacs = config.programs.emacs.enable;
  hasNeomutt = config.programs.neomutt.enable;
in {
  programs.fish = {
    enable = true;
    shellAbbrs = rec {
      jqless = "jq -C | less -r";

      n = "nix";
      nd = "nix develop -c $SHELL";
      ns = "nix shell";
      nsn = "nix shell nixpkgs#";
      nb = "nix build";
      nbn = "nix build nixpkgs#";
      nf = "nix flake";

      nr = "nixos-rebuild --flake .";
      nrs = "nixos-rebuild --flake . switch";
      snr = "sudo nixos-rebuild --flake .";
      snrs = "sudo nixos-rebuild --flake . switch";
      hm = "home-manager --flake .";
      hms = "home-manager --flake . switch";

      s = mkIf hasSpecialisationCli "specialisation";

      ls = mkIf hasEza "eza";
      exa = ls;

      e = mkIf hasEmacs "emacsclient -t";

      vim = mkIf hasNeovim "nvim";
      vi = vim;
      v = vim;

      mutt = mkIf hasNeomutt "neomutt";
      m = mutt;

      aws-switch = mkIf hasAwsCli "export AWS_PROFILE=(aws configure list-profiles | fzf)";
      awssw = aws-switch;
    };
    shellAliases = {
      # Clear screen and scrollback
      clear = "printf '\\033[2J\\033[3J\\033[1;1H'";
    };
    functions = {
      # Disable greeting
      fish_greeting = "";
      # Grep using ripgrep and pass to nvim
      nvimrg = mkIf (hasNeovim && hasRipgrep) "nvim -q (rg --vimgrep $argv | psub)";
      # Merge history when pressing up
      up-or-search = lib.readFile ./up-or-search.fish;
      # Tide prompt items
      _tide_item_jj = lib.readFile ./tide-item-jj.fish;
    };
    plugins = [
      {
        name = "tide";
        src = pkgs.fetchFromGitHub {
          owner = "IlanCosman";
          repo = "tide";
          rev = "44c521ab292f0eb659a9e2e1b6f83f5f0595fcbd";
          hash = "sha256-85iU1QzcZmZYGhK30/ZaKwJNLTsx+j3w6St8bFiQWxc=";
        };
      }
    ];
    interactiveShellInit = lib.readFile ./interactive-init.fish;
  };
}

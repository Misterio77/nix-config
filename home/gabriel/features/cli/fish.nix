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
  hasExa = hasPackage "eza";
  hasSpecialisationCli = hasPackage "specialisation";
  hasAwsCli = hasPackage "awscli2";
  hasNeovim = config.programs.neovim.enable;
  hasEmacs = config.programs.emacs.enable;
  hasNeomutt = config.programs.neomutt.enable;
  hasShellColor = config.programs.shellcolor.enable;
  hasKitty = config.programs.kitty.enable;
  shellcolor = "${pkgs.shellcolord}/bin/shellcolor";
in {
  programs.fish = {
    enable = true;
    plugins =
      lib.optional hasAwsCli
      {
        name = "aws";
        src = pkgs.applyPatches {
          src = pkgs.fetchFromGitHub {
            owner = "oh-my-fish";
            repo = "plugin-aws";
            rev = "e53a1de3f826916cb83f6ebd34a7356af8f754d1";
            hash = "sha256-l17v/aJ4PkjYM8kJDA0zUo87UTsfFqq+Prei/Qq0DRA=";
          };
          patches = [
            (
              builtins.toFile "fix-complete.diff" /* diff */ ''
                diff --git a/completions/aws.fish b/completions/aws.fish
                index fc75188..1e8d931 100644
                --- a/completions/aws.fish
                +++ b/completions/aws.fish
                @@ -1,7 +1,7 @@
                 function __aws_complete
                   if set -q aws_completer_path
                     set -lx COMP_SHELL fish
                -    set -lx COMP_LINE (commandline -opc)
                +    set -lx COMP_LINE (commandline -pc)

                     if string match -q -- "-*" (commandline -opt)
                       set COMP_LINE $COMP_LINE -
              ''
            )
          ];
        };
      };

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

      ls = mkIf hasExa "eza";
      exa = mkIf hasExa "eza";

      e = mkIf hasEmacs "emacsclient -t";

      vim = mkIf hasNeovim "nvim";
      vi = vim;
      v = vim;

      mutt = mkIf hasNeomutt "neomutt";
      m = mutt;

      cik = mkIf hasKitty "clone-in-kitty --type os-window";
      ck = cik;

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
      # Merge history upon doing up-or-search
      # This lets multiple fish instances share history
      up-or-search =
        /*
        fish
        */
        ''
          if commandline --search-mode
            commandline -f history-search-backward
            return
          end
          if commandline --paging-mode
            commandline -f up-line
            return
          end
          set -l lineno (commandline -L)
          switch $lineno
            case 1
              commandline -f history-search-backward
              history merge
            case '*'
              commandline -f up-line
          end
        '';
      # Integrate ssh with shellcolord
      ssh =
        mkIf hasShellColor # fish
        
        ''
          ${shellcolor} disable $fish_pid
          # Check if kitty is available
          if set -q KITTY_PID && set -q KITTY_WINDOW_ID && type -q -f kitty
            kitty +kitten ssh $argv
          else
            command ssh $argv
          end
          ${shellcolor} enable $fish_pid
          ${shellcolor} apply $fish_pid
        '';
    };
    interactiveShellInit =
      /*
      fish
      */
      ''
        # Open command buffer in vim when alt+e is pressed
        bind \ee edit_command_buffer

        # kitty integration
        set --global KITTY_INSTALLATION_DIR "${pkgs.kitty}/lib/kitty"
        set --global KITTY_SHELL_INTEGRATION enabled
        source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
        set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"

        # Use vim bindings and cursors
        fish_vi_key_bindings
        set fish_cursor_default     block      blink
        set fish_cursor_insert      line       blink
        set fish_cursor_replace_one underscore blink
        set fish_cursor_visual      block

        # Use terminal colors
        set -U fish_color_autosuggestion      brblack
        set -U fish_color_cancel              -r
        set -U fish_color_command             brgreen
        set -U fish_color_comment             brmagenta
        set -U fish_color_cwd                 green
        set -U fish_color_cwd_root            red
        set -U fish_color_end                 brmagenta
        set -U fish_color_error               brred
        set -U fish_color_escape              brcyan
        set -U fish_color_history_current     --bold
        set -U fish_color_host                normal
        set -U fish_color_match               --background=brblue
        set -U fish_color_normal              normal
        set -U fish_color_operator            cyan
        set -U fish_color_param               brblue
        set -U fish_color_quote               yellow
        set -U fish_color_redirection         bryellow
        set -U fish_color_search_match        'bryellow' '--background=brblack'
        set -U fish_color_selection           'white' '--bold' '--background=brblack'
        set -U fish_color_status              red
        set -U fish_color_user                brgreen
        set -U fish_color_valid_path          --underline
        set -U fish_pager_color_completion    normal
        set -U fish_pager_color_description   yellow
        set -U fish_pager_color_prefix        'white' '--bold' '--underline'
        set -U fish_pager_color_progress      'brwhite' '--background=cyan'
      '';
  };
}

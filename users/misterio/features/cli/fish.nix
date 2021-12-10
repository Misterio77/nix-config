{ pkgs, config, lib, ... }:
let
  colors = config.colorscheme.colors;

  get_red = color: builtins.substring 0 2 color;
  get_green = color: builtins.substring 2 2 color;
  get_blue = color: builtins.substring 4 2 color;
  split-colors = lib.mapAttrs (name: color: "${get_red color}/${get_green color}/${get_blue color}") colors;

  base16-shell = pkgs.writeShellScriptBin "base16-shell" ''
    #!/bin/sh
    # base16-shell (https://github.com/chriskempson/base16-shell)
    # Base16 Shell template by Chris Kempson (http://chriskempson.com)
    # {{scheme-name}} scheme by {{scheme-author}}

    color00="${split-colors.base00}" # Base 00 - Black
    color01="${split-colors.base08}" # Base 08 - Red
    color02="${split-colors.base0B}" # Base 0B - Green
    color03="${split-colors.base0A}" # Base 0A - Yellow
    color04="${split-colors.base0D}" # Base 0D - Blue
    color05="${split-colors.base0E}" # Base 0E - Magenta
    color06="${split-colors.base0C}" # Base 0C - Cyan
    color07="${split-colors.base05}" # Base 05 - White
    color08="${split-colors.base03}" # Base 03 - Bright Black
    color09=$color01 # Base 08 - Bright Red
    color10=$color02 # Base 0B - Bright Green
    color11=$color03 # Base 0A - Bright Yellow
    color12=$color04 # Base 0D - Bright Blue
    color13=$color05 # Base 0E - Bright Magenta
    color14=$color06 # Base 0C - Bright Cyan
    color15="${split-colors.base07}" # Base 07 - Bright White
    color16="${split-colors.base09}" # Base 09
    color17="${split-colors.base0F}" # Base 0F
    color18="${split-colors.base01}" # Base 01
    color19="${split-colors.base02}" # Base 02
    color20="${split-colors.base04}" # Base 04
    color21="${split-colors.base06}" # Base 06
    color_foreground="${split-colors.base05}" # Base 05
    color_background="${split-colors.base00}" # Base 00

    if [ -n "$TMUX" ]; then
      # Tell tmux to pass the escape sequences through
      # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
      put_template() { printf '\033Ptmux;\033\033]4;%d;rgb:%s\033\033\\\033\\' $@; }
      put_template_var() { printf '\033Ptmux;\033\033]%d;rgb:%s\033\033\\\033\\' $@; }
      put_template_custom() { printf '\033Ptmux;\033\033]%s%s\033\033\\\033\\' $@; }
    elif [ "''${TERM%%[-.]*}" = "screen" ]; then
      # GNU screen (screen, screen-256color, screen-256color-bce)
      put_template() { printf '\033P\033]4;%d;rgb:%s\007\033\\' $@; }
      put_template_var() { printf '\033P\033]%d;rgb:%s\007\033\\' $@; }
      put_template_custom() { printf '\033P\033]%s%s\007\033\\' $@; }
    elif [ "''${TERM%%-*}" = "linux" ]; then
      put_template() { [ $1 -lt 16 ] && printf "\e]P%x%s" $1 $(echo $2 | sed 's/\///g'); }
      put_template_var() { true; }
      put_template_custom() { true; }
    else
      put_template() { printf '\033]4;%d;rgb:%s\033\\' $@; }
      put_template_var() { printf '\033]%d;rgb:%s\033\\' $@; }
      put_template_custom() { printf '\033]%s%s\033\\' $@; }
    fi

    # 16 color space
    put_template 0  $color00
    put_template 1  $color01
    put_template 2  $color02
    put_template 3  $color03
    put_template 4  $color04
    put_template 5  $color05
    put_template 6  $color06
    put_template 7  $color07
    put_template 8  $color08
    put_template 9  $color09
    put_template 10 $color10
    put_template 11 $color11
    put_template 12 $color12
    put_template 13 $color13
    put_template 14 $color14
    put_template 15 $color15

    # 256 color space
    put_template 16 $color16
    put_template 17 $color17
    put_template 18 $color18
    put_template 19 $color19
    put_template 20 $color20
    put_template 21 $color21

    # foreground / background / cursor color
    put_template_var 10 $color_foreground
    if [ "$BASE16_SHELL_SET_BACKGROUND" != false ]; then
      put_template_var 11 $color_background
      if [ "''${TERM%%-*}" = "rxvt" ]; then
        put_template_var 708 $color_background # internal border (rxvt)
      fi
    fi
    put_template_custom 12 ";7" # cursor (reverse video)
  '';
in
{
  home.packages = [ base16-shell ];
  programs.fish = {
    enable = true;
    shellAbbrs = {
      ls = "exa";
      top = "btm";
      jqless = "jq -C | less -r";
      snrs = "sudo nixos-rebuild switch --flake /dotfiles";
      nrs = "nixos-rebuild switch --flake /dotfiles";
      hms = "home-manager switch --flake /dotfiles";
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
      m = "neomutt";
      mutt = "neomutt";
      s = "base16-shell";
    };
    shellAliases = {
      miningclock = "sudo USER_STATES_PATH=/etc/default/amdgpu-custom-state amdgpu-clocks";
      gamingclock = "sudo USER_STATES_PATH=/etc/default/amdgpu-gaming-state amdgpu-clocks";
      # SSH with kitty terminfo
      kssh = "kitty +kitten ssh";
      # Get ip
      getip = "curl ifconfig.me";
      # Clear screen and scrollbackbuffer
      clear = "clear && printf '\\033[2J\\033[3J\\033[1;1H'";
    };
    functions = {
      fish_greeting = "${pkgs.fortune}/bin/fortune -s";
      wh = "readlink -f (which $argv)";
      ssh = ''
        command ssh $argv
        base16-shell
      '';
    };
    interactiveShellInit =
      # Use vim bindings and cursors
      ''
        fish_vi_key_bindings
        set fish_cursor_default     block      blink
        set fish_cursor_insert      line       blink
        set fish_cursor_replace_one underscore blink
        set fish_cursor_visual      block
      '' +
      # Use terminal colors
      ''
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
      '' +
      # Activate base16-shell if connected via SSH
      ''
        if test -n "$SSH_CONNECTION"
          ${base16-shell}/bin/base16-shell
        end
      '';

  };
}

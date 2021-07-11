{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = false;
    enableSyntaxHighlighting = true;
    loginExtra = ''
      [[ "$(tty)" == /dev/tty1 ]] && exec sway
    '';
    shellAliases = {
      jqless = "jq -C | less -r";
      nr = "nixos-rebuild";
      nrs = "sudo nixos-rebuild switch --fast";
      nre = "nixos-rebuild edit";
      ns = "nix-shell";
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
      m = "m";
      mutt = "neomutt";
    };
    envExtra = ''
      GLOBALIAS_FILTER_VALUES=(ls)
    '';
    history = { size = 1000; };
    initExtra = ''
      export GPG_TTY="$(tty)"
      gpg-connect-agent /bye
      export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"

      bindkey "''${terminfo[kcuu1]}" history-substring-search-up
      bindkey "''${terminfo[kcud1]}" history-substring-search-down

      zstyle ":completion:*" completer _complete
      zstyle ":completion:*" matcher-list "" "m:{[:lower:][:upper:]}={[:upper:][:lower:]}" "+l:|=* r:|=*"
      export PATH="$PATH":$HOME/bin
    '';
    plugins = [
      {
        name = "globalias";
        file = "plugins/globalias/globalias.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "ohmyzsh";
          repo = "ohmyzsh";
          rev = "53cbd658f5ae6874af0d804cee6748dfba69e786";
          sha256 = "07k4bi4dxfg9gfx6pj17iswk71d4pjnbp2fbqwwj797qvxs98mcn";
        };
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";
          sha256 = "1g3pij5qn2j7v7jjac2a63lxd97mcsgw6xq6k5p7835q9fjiid98";
        };
      }
      {
        name = "zsh-completions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-completions";
          rev = "0.33.0";
          sha256 = "0vs14n29wvkai84fvz3dz2kqznwsq2i5fzbwpv8nsfk1126ql13i";
        };
      }
      {
        name = "zsh-history-substring-search";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-history-substring-search";
          rev = "v1.0.2";
          sha256 = "0y8va5kc2ram38hbk2cibkk64ffrabfv1sh4xm7pjspsba9n5p1y";
        };
      }
      {
        name = "zsh-vi-mode";
        src = pkgs.fetchFromGitHub {
          owner = "jeffreytse";
          repo = "zsh-vi-mode";
          rev = "v0.8.4";
          sha256 = "0a1rvc03rl66v8rgzvxpq0vw55hxn5b9dkmhdqghvi2f4dvi8fzx";
        };
      }
      {
        name = "zsh-nix-shell";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.2.0";
          sha256 = "1gfyrgn23zpwv1vj37gf28hf5z0ka0w5qm6286a7qixwv7ijnrx9";
        };
      }
    ];
  };
}
# vim: filetype=nix:

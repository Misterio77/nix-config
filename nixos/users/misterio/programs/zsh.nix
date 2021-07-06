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
      nrs = "sudo nixos-rebuild switch";
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
    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; }
        { name = "zsh-users/zsh-completions"; }
        { name = "zsh-users/zsh-history-substring-search"; }
        { name = "softmoth/zsh-vim-mode"; }
        { name = "chisui/zsh-nix-shell"; }
        {
          name = "plugins/globalias";
          tags = [ "from:oh-my-zsh" ];
        }
      ];
    };
  };
}
# vim: filetype=nix:

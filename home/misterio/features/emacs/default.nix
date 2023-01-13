{ pkgs, config, ... }:
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-gtk;

    overrides = final: _prev: {
      nix-theme = final.callPackage ./theme.nix { inherit config; };
    };
    extraPackages = epkgs: with epkgs; [
      nix-theme

      nix-mode
      magit
      lsp-mode
      which-key
      mmm-mode

      evil
      evil-org
      evil-collection
      evil-surround
    ];

    extraConfig = builtins.readFile ./init.el;
  };
  services.emacs = {
    enable = true;
    client.enable = true;
    defaultEditor = true;
    socketActivation.enable = true;
  };
}

{ inputs, pkgs, config, ... }:
let emacs-overlay = inputs.emacs-overlay.packages.${pkgs.system};
in
{
  programs.emacs = {
    enable = true;
    package = emacs-overlay.emacsPgtkNativeComp;

    overrides = final: _prev: {
      nix-theme = final.callPackage ./theme.nix { inherit config; };
    };
    extraPackages = epkgs: with epkgs; [
      nix-theme
      nix-mode
      magit

      evil
      evil-org
      evil-collection
      evil-surround
    ];

    extraConfig = /* lisp */ ''
      (scroll-bar-mode -1)
      (tool-bar-mode -1)
      (tooltip-mode -1)
      (set-fringe-mode 10)
      (menu-bar-mode -1)
      (set-face-attribute 'default nil :font "FiraCode Nerd Font" :height 120)
      (setq visible-bell t)

      (setq base16-theme-256-color-source "base16-shell")
      (load-theme 'base16-${config.colorscheme.slug} t)

      (require 'nix-mode)
      (add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode))

      (add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
      (global-set-key "\C-cl" 'org-store-link)
      (global-set-key "\C-ca" 'org-agenda)
      (setq org-directory "~/Documents/Org")
      (setq org-agenda-files (directory-files-recursively org-directory "\\.org$"))


      (setq evil-want-keybinding nil)
      (require 'evil)
      (evil-mode 1)
      (setq evil-jumps-across-buffers t)

      (require 'evil-org)
      (add-hook 'org-mode-hook 'evil-org-mode)
      (evil-org-set-key-theme '(navigation insert textobjects additional calendar))
      (require 'evil-org-agenda)
      (evil-org-agenda-set-keys)

      (evil-collection-init)

      (global-evil-surround-mode 1)
    '';
  };
  services.emacs = {
    enable = true;
    client.enable = true;
    defaultEditor = true;
    socketActivation.enable = true;
  };
}

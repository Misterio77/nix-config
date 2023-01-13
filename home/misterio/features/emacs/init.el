(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)
(menu-bar-mode -1)
(set-face-attribute 'default nil :font "FiraCode Nerd Font" :height 120)
(setq visible-bell t)
(global-display-line-numbers-mode)
(setq display-line-numbers-type 'relative)

(setq base16-theme-256-color-source "base16-shell")
(load-theme 'base16-${config.colorscheme.slug} t)

(require 'nix-mode)
(add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode))

(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(setq org-directory "~/Documents/Org")
(setq org-agenda-files (directory-files-recursively org-directory "\\.org$"))

(require 'lsp-mode)
(add-hook 'nix-mode-hook #'lsp)

(require 'which-key)
(which-key-mode)

(require 'mmm-mode)
(setq mmm-global-mode 't)

(mmm-add-classes
'((nix-block
    :front " \/\* \\([a-zA-Z0-9_-]+\\) \*\/ '''[^']"
    :back "''';"
    ;; :save-matches 1
    ;; :delimiter-mode nil
    ;; :match-submode identity
    :submode org
)))
(mmm-add-mode-ext-class 'nix-mode nil 'nix-block)



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

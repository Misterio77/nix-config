{ config, pkgs, ... }:

let
  colors = config.colorscheme.colors;
  alacritty = "${pkgs.alacritty-reload}/bin/alacritty";
  nvim = "${pkgs.neovim}/bin/nvim";
in {
  programs.qutebrowser = {
    enable = true;
    loadAutoconfig = true;
    settings = {
      editor.command = [ "${alacritty}" "-e" "${nvim}" "{file}" ];
      tabs = {
        show = "multiple";
        position = "left";
      };
      fonts = {
        default_family = "Fira Sans";
        default_size = "12pt";
      };
      colors = {
        webpage = {
          preferred_color_scheme = "${config.colorscheme.kind}";
          bg = "#ffffff";
        };
        completion = {
          fg = "#${colors.base05}";
          match.fg = "#${colors.base09}";
          even.bg = "#${colors.base00}";
          odd.bg = "#${colors.base00}";
          scrollbar = {
            bg = "#${colors.base00}";
            fg = "#${colors.base05}";
          };
          category = {
            bg = "#${colors.base00}";
            fg = "#${colors.base0D}";
            border = {
              bottom = "#${colors.base00}";
              top = "#${colors.base00}";
            };
          };
          item.selected = {
            bg = "#${colors.base02}";
            fg = "#${colors.base05}";
            match.fg = "#${colors.base05}";
            border = {
              bottom = "#${colors.base02}";
              top = "#${colors.base02}";
            };
          };
        };
        contextmenu = {
          disabled = {
            bg = "#${colors.base01}";
            fg = "#${colors.base04}";
          };
          menu = {
            bg = "#${colors.base00}";
            fg = "#${colors.base05}";
          };
          selected = {
            bg = "#${colors.base02}";
            fg = "#${colors.base05}";
          };
        };
        downloads = {
          bar.bg = "#${colors.base00}";
          error.fg = "#${colors.base08}";
          start = {
            bg = "#${colors.base0D}";
            fg = "#${colors.base00}";
          };
          stop = {
            bg = "#${colors.base0C}";
            fg = "#${colors.base00}";
          };
        };
        hints = {
          bg = "#${colors.base0A}";
          fg = "#${colors.base00}";
          match.fg = "#${colors.base05}";
        };
        keyhint = {
          bg = "#${colors.base00}";
          fg = "#${colors.base05}";
          suffix.fg = "#${colors.base05}";
        };
        messages.error.bg = "#${colors.base08}";
        messages.error.border = "#${colors.base08}";
        messages.error.fg = "#${colors.base00}";
        messages.info.bg = "#${colors.base00}";
        messages.info.border = "#${colors.base00}";
        messages.info.fg = "#${colors.base05}";
        messages.warning.bg = "#${colors.base0E}";
        messages.warning.border = "#${colors.base0E}";
        messages.warning.fg = "#${colors.base00}";
        prompts.bg = "#${colors.base00}";
        prompts.border = "#${colors.base00}";
        prompts.fg = "#${colors.base05}";
        prompts.selected.bg = "#${colors.base02}";
        statusbar.caret.bg = "#${colors.base00}";
        statusbar.caret.fg = "#${colors.base0D}";
        statusbar.caret.selection.bg = "#${colors.base00}";
        statusbar.caret.selection.fg = "#${colors.base0D}";
        statusbar.command.bg = "#${colors.base01}";
        statusbar.command.fg = "#${colors.base04}";
        statusbar.command.private.bg = "#${colors.base01}";
        statusbar.command.private.fg = "#${colors.base0E}";
        statusbar.insert.bg = "#${colors.base00}";
        statusbar.insert.fg = "#${colors.base0C}";
        statusbar.normal.bg = "#${colors.base00}";
        statusbar.normal.fg = "#${colors.base05}";
        statusbar.passthrough.bg = "#${colors.base00}";
        statusbar.passthrough.fg = "#${colors.base0A}";
        statusbar.private.bg = "#${colors.base00}";
        statusbar.private.fg = "#${colors.base0E}";
        statusbar.progress.bg = "#${colors.base0D}";
        statusbar.url.error.fg = "#${colors.base08}";
        statusbar.url.fg = "#${colors.base05}";
        statusbar.url.hover.fg = "#${colors.base09}";
        statusbar.url.success.http.fg = "#${colors.base0B}";
        statusbar.url.success.https.fg = "#${colors.base0B}";
        statusbar.url.warn.fg = "#${colors.base0E}";
        tabs.bar.bg = "#${colors.base00}";
        tabs.even.bg = "#${colors.base00}";
        tabs.even.fg = "#${colors.base05}";
        tabs.indicator.error = "#${colors.base08}";
        tabs.indicator.start = "#${colors.base0D}";
        tabs.indicator.stop = "#${colors.base0C}";
        tabs.odd.bg = "#${colors.base00}";
        tabs.odd.fg = "#${colors.base05}";
        tabs.pinned.even.bg = "#${colors.base0B}";
        tabs.pinned.even.fg = "#${colors.base00}";
        tabs.pinned.odd.bg = "#${colors.base0B}";
        tabs.pinned.odd.fg = "#${colors.base00}";
        tabs.pinned.selected.even.bg = "#${colors.base02}";
        tabs.pinned.selected.even.fg = "#${colors.base05}";
        tabs.pinned.selected.odd.bg = "#${colors.base02}";
        tabs.pinned.selected.odd.fg = "#${colors.base05}";
        tabs.selected.even.bg = "#${colors.base02}";
        tabs.selected.even.fg = "#${colors.base05}";
        tabs.selected.odd.bg = "#${colors.base02}";
        tabs.selected.odd.fg = "#${colors.base05}";
      };
    };
    extraConfig = ''
      c.tabs.padding = {"bottom": 10, "left": 10, "right": 10, "top": 10}
    '';
  };
}

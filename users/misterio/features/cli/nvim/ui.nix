# Stuff i use to dynamically theme neovim without relying on notermguicolors
{ pkgs, config, ... }:
let
  c = config.colorscheme.colors;
  # Base16 lua colorscheme command
  nvim-scheme = ''
    require("base16-colorscheme").setup({
        base00 = "#${c.base00}"; base01 = "#${c.base01}"; base02 = "#${c.base02}"; base03 = "#${c.base03}";
        base04 = "#${c.base04}"; base05 = "#${c.base05}"; base06 = "#${c.base06}"; base07 = "#${c.base07}";
        base08 = "#${c.base08}"; base09 = "#${c.base09}"; base0A = "#${c.base0A}"; base0B = "#${c.base0B}";
        base0C = "#${c.base0C}"; base0D = "#${c.base0D}"; base0E = "#${c.base0E}"; base0F = "#${c.base0F}";
      })
  '';
  bufferline-theme = ''
  '';
in
{
  # When configuration is written, reapply scheme
  xdg.configFile."nvim/init.vim".onChange =
    let
      nvr = "${pkgs.neovim-remote}/bin/nvr";
    in
    ''
      ${nvr} --serverlist | \
      while read server; do
        ${nvr} --nostart -cc ':lua ${nvim-scheme}' --servername $server & \
      done
    '';

  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = nvim-base16;
      # Write scheme to configuration file
      config = ''
        lua << EOF
          ${nvim-scheme}
        EOF
      '';
    }

    { plugin = nvim-web-devicons; config = "lua require('nvim-web-devicons').setup{}"; }

    { plugin = nvim-colorizer-lua; config = "lua require('colorizer').setup()"; }

    { plugin = gitsigns-nvim; config = "lua require('gitsigns').setup()"; }

    {
      plugin = nvim-tree-lua;
      config = ''
        lua require('nvim-tree').setup{}
        nmap <C-p> :NvimTreeToggle<CR>
      '';
    }

    {
      plugin = feline-nvim;
      config = ''
        lua << EOF
        local components = {
          active = {
            {{
              provider = ' ',
              hl = 'Normal',
            }},
            {{
              provider = 'irineu'
            }},
          },
          inactive = {
            {{
              provider = 'irineu'
            }},
            {{
              provider = 'irineu'
            }},
          },
        }

        require('feline').setup({components = components})
        EOF
      '';
    }

    {
      plugin = bufferline-nvim;
      config = ''
        nmap <C-h> :BufferLineCyclePrev<CR>
        nmap <C-l> :BufferLineCycleNext<CR>

        lua << EOF
        require('bufferline').setup{
          fill = {
              guifg = comment_fg,
              guibg = separator_background_color,
            },
            group_separator = {
              guifg = comment_fg,
              guibg = separator_background_color,
            },
            group_label = {
              guibg = comment_fg,
              guifg = separator_background_color,
            },
            tab = {
              guifg = comment_fg,
              guibg = background_color,
            },
            tab_selected = {
              guifg = tabline_sel_bg,
              guibg = normal_bg,
            },
            tab_close = {
              guifg = comment_fg,
              guibg = background_color,
            },
            close_button = {
              guifg = comment_fg,
              guibg = background_color,
            },
            close_button_visible = {
              guifg = comment_fg,
              guibg = visible_bg,
            },
            close_button_selected = {
              guifg = normal_fg,
              guibg = normal_bg,
            },
            background = {
              guifg = comment_fg,
              guibg = background_color,
            },
            buffer = {
              guifg = comment_fg,
              guibg = background_color,
            },
            buffer_visible = {
              guifg = comment_fg,
              guibg = visible_bg,
            },
            buffer_selected = {
              guifg = normal_fg,
              guibg = normal_bg,
              gui = "bold,italic",
            },
            diagnostic = {
              guifg = comment_diagnostic_fg,
              guibg = background_color,
            },
            diagnostic_visible = {
              guifg = comment_diagnostic_fg,
              guibg = visible_bg,
            },
            diagnostic_selected = {
              guifg = normal_diagnostic_fg,
              guibg = normal_bg,
              gui = "bold,italic",
            },
            info = {
              guifg = comment_fg,
              guisp = info_fg,
              guibg = background_color,
            },
            info_visible = {
              guifg = comment_fg,
              guibg = visible_bg,
            },
            info_selected = {
              guifg = info_fg,
              guibg = normal_bg,
              gui = "bold,italic",
              guisp = info_fg,
            },
            info_diagnostic = {
              guifg = comment_diagnostic_fg,
              guisp = info_diagnostic_fg,
              guibg = background_color,
            },
            info_diagnostic_visible = {
              guifg = comment_diagnostic_fg,
              guibg = visible_bg,
            },
            info_diagnostic_selected = {
              guifg = info_diagnostic_fg,
              guibg = normal_bg,
              gui = "bold,italic",
              guisp = info_diagnostic_fg,
            },
            warning = {
              guifg = comment_fg,
              guisp = warning_fg,
              guibg = background_color,
            },
            warning_visible = {
              guifg = comment_fg,
              guibg = visible_bg,
            },
            warning_selected = {
              guifg = warning_fg,
              guibg = normal_bg,
              gui = "bold,italic",
              guisp = warning_fg,
            },
            warning_diagnostic = {
              guifg = comment_diagnostic_fg,
              guisp = warning_diagnostic_fg,
              guibg = background_color,
            },
            warning_diagnostic_visible = {
              guifg = comment_diagnostic_fg,
              guibg = visible_bg,
            },
            warning_diagnostic_selected = {
              guifg = warning_diagnostic_fg,
              guibg = normal_bg,
              gui = "bold,italic",
              guisp = warning_diagnostic_fg,
            },
            error = {
              guifg = comment_fg,
              guibg = background_color,
              guisp = error_fg,
            },
            error_visible = {
              guifg = comment_fg,
              guibg = visible_bg,
            },
            error_selected = {
              guifg = error_fg,
              guibg = normal_bg,
              gui = "bold,italic",
              guisp = error_fg,
            },
            error_diagnostic = {
              guifg = comment_diagnostic_fg,
              guibg = background_color,
              guisp = error_diagnostic_fg,
            },
            error_diagnostic_visible = {
              guifg = comment_diagnostic_fg,
              guibg = visible_bg,
            },
            error_diagnostic_selected = {
              guifg = error_diagnostic_fg,
              guibg = normal_bg,
              gui = "bold,italic",
              guisp = error_diagnostic_fg,
            },
            modified = {
              guifg = string_fg,
              guibg = background_color,
            },
            modified_visible = {
              guifg = string_fg,
              guibg = visible_bg,
            },
            modified_selected = {
              guifg = string_fg,
              guibg = normal_bg,
            },
            duplicate_selected = {
              guifg = duplicate_color,
              gui = "italic",
              guibg = normal_bg,
            },
            duplicate_visible = {
              guifg = duplicate_color,
              gui = "italic",
              guibg = visible_bg,
            },
            duplicate = {
              guifg = duplicate_color,
              gui = "italic",
              guibg = background_color,
            },
            separator_selected = {
              guifg = separator_background_color,
              guibg = normal_bg,
            },
            separator_visible = {
              guifg = separator_background_color,
              guibg = visible_bg,
            },
            separator = {
              guifg = separator_background_color,
              guibg = background_color,
            },
            indicator_selected = {
              guifg = tabline_sel_bg,
              guibg = normal_bg,
            },
            pick_selected = {
              guifg = error_fg,
              guibg = normal_bg,
              gui = "bold,italic",
            },
            pick_visible = {
              guifg = error_fg,
              guibg = visible_bg,
              gui = "bold,italic",
            },
            pick = {
              guifg = error_fg,
              guibg = background_color,
              gui = "bold,italic",
            },
          }
        }
        EOF
      '';
    }
  ];
}

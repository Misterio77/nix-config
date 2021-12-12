# Stuff i use to dynamically theme neovim without relying on notermguicolors
{ pkgs, config, ... }:
let
  slug = config.colorscheme.slug;
  c = config.colorscheme.colors;

  nvim-scheme = ''
    let g:colors_name = 'nix-${slug}'
    lua << EOF
    require("base16-colorscheme").setup({
        base00 = "#${c.base00}"; base01 = "#${c.base01}"; base02 = "#${c.base02}"; base03 = "#${c.base03}";
        base04 = "#${c.base04}"; base05 = "#${c.base05}"; base06 = "#${c.base06}"; base07 = "#${c.base07}";
        base08 = "#${c.base08}"; base09 = "#${c.base09}"; base0A = "#${c.base0A}"; base0B = "#${c.base0B}";
        base0C = "#${c.base0C}"; base0D = "#${c.base0D}"; base0E = "#${c.base0E}"; base0F = "#${c.base0F}";
      })
    EOF
  '';
in
{
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.nvim-base16;
      config = "colorscheme nix-${slug}";
    }
  ];

  xdg.configFile = {
    "nvim/colors/nix-${slug}.vim".text = nvim-scheme;

    # When configuration is written, reapply scheme
    "nvim/init.vim".onChange =
      let nvr = "${pkgs.neovim-remote}/bin/nvr";
      in
      ''
        path=$(< ~/.config/nvim/init.vim head -1 | cut -d '=' -f2 )
        ${nvr} --serverlist | \
        while read server; do
          ${nvr} --nostart -cc ":set packpath^=$path | :set runtimepath^=$path | :colorscheme nix-${slug}" --servername $server & \
        done
      '';
  };
}

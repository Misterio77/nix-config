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
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.nvim-base16;
      # Write scheme to configuration file
      config = ''
        lua << EOF
          ${nvim-scheme}
        EOF
      '';
    }
  ];
}

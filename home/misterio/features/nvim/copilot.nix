{ pkgs, lib, ... }:
{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = copilot-lua;
      type = "lua";
      config = /* lua */ ''
        local copilot = require('copilot')
        copilot.setup({
          suggestion = { enabled = false },
          panel = { enabled = false },
          copilot_node_command = "${lib.getExe pkgs.nodejs}",
        })
      '';
    }
    {
      plugin = copilot-cmp;
      type = "lua";
      config = /* lua */ ''
        local copilot_cmp = require('copilot_cmp')
        copilot_cmp.setup()
      '';
    }
  ];
}

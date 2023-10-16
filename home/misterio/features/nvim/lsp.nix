{ pkgs, ... }: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    # LSP
    {
      plugin = nvim-lspconfig;
      type = "lua";
      config = /* lua */ ''
        local lspconfig = require('lspconfig')
        function add_lsp(server, options)
          if options["cmd"] ~= nil then
            binary = options["cmd"][1]
          else
            binary = server["document_config"]["default_config"]["cmd"][1]
          end
          if vim.fn.executable(binary) == 1 then
            server.setup(options)
          end
        end

        add_lsp(lspconfig.dockerls, {})
        add_lsp(lspconfig.bashls, {})
        add_lsp(lspconfig.clangd, {})
        add_lsp(lspconfig.nil_ls, {})
        add_lsp(lspconfig.pylsp, {})
        add_lsp(lspconfig.dartls, {})
        add_lsp(lspconfig.hls, {})
        add_lsp(lspconfig.kotlin_language_server, {})
        add_lsp(lspconfig.solargraph, {})
        add_lsp(lspconfig.phpactor, {})
        add_lsp(lspconfig.terraformls, {})
        add_lsp(lspconfig.gopls, {})
        add_lsp(lspconfig.lua_ls, {})
        add_lsp(lspconfig.jdtls, {
          cmd = { "jdt-language-server" }
        })
        add_lsp(lspconfig.tsserver, {
          cmd = { "tsserver", "--stdio" }
        })
        add_lsp(lspconfig.texlab, {
          chktex = { onEdit = true, onOpenAndSave = true }
        })
      '';
    }
    {
      plugin = ltex_extra-nvim;
      type = "lua";
      config = /* lua */ ''
        local ltex_extra = require('ltex_extra')
        add_lsp(lspconfig.ltex, {
          on_attach = function(client, bufnr)
            ltex_extra.setup{
              path = vim.fn.expand("~") .. "/.local/state/ltex"
            }
          end
        })
      '';
    }
    {
      plugin = rust-tools-nvim;
      type = "lua";
      config = /* lua */ ''
        local rust_tools = require('rust-tools')
        add_lsp(rust_tools, {
          cmd = { "rust-analyzer" },
          tools = { autoSetHints = true }
        })
        vim.api.nvim_set_hl(0, '@lsp.type.comment.rust', {})
      '';
    }

    # Completions
    cmp-nvim-lsp
    cmp-buffer
    lspkind-nvim
    {
      plugin = nvim-cmp;
      type = "lua";
      config = /* lua */ ''
        local cmp = require('cmp')

        cmp.setup{
          formatting = {
            format = require('lspkind').cmp_format({
              symbol_map = {
                Copilot = "",
              },
            })
          },
          -- Same keybinds as vim's vanilla completion
          mapping = cmp.mapping.preset.insert({
          }),
          sources = {
            { name='buffer', option = { get_bufnrs = vim.api.nvim_list_bufs } },
            { name='nvim_lsp' },
            { name = 'copilot' },
          },
        }
      '';
    }
  ];
}

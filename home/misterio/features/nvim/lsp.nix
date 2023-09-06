{ pkgs, ... }: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    # LSP
    {
      plugin = nvim-lspconfig;
      type = "lua";
      config = /* lua */ ''
        local lspconfig = require('lspconfig')

        function add_lsp(binary, server, options)
          if not options["cmd"] then options["cmd"] = { binary, unpack(options["cmd_args"] or {}) } end
          if vim.fn.executable(binary) == 1 then server.setup(options) end
        end

        add_lsp("docker-langserver", lspconfig.dockerls, {})
        add_lsp("bash-language-server", lspconfig.bashls, {})
        add_lsp("clangd", lspconfig.clangd, {})
        add_lsp("nil", lspconfig.nil_ls, {})
        add_lsp("pylsp", lspconfig.pylsp, {})
        add_lsp("dart", lspconfig.dartls, {})
        add_lsp("haskell-language-server", lspconfig.hls, {
          cmd_args = { "--lsp" }
        })
        add_lsp("kotlin-language-server", lspconfig.kotlin_language_server, {})
        add_lsp("solargraph", lspconfig.solargraph, {})
        add_lsp("phpactor", lspconfig.phpactor, {})
        add_lsp("terraform-ls", lspconfig.terraformls, {
          cmd_args = { "serve" }
        })
        add_lsp("texlab", lspconfig.texlab, {})
        add_lsp("gopls", lspconfig.gopls, {})
        add_lsp("tsserver", lspconfig.tsserver, {})
        add_lsp("lua-lsp", lspconfig.lua_ls, {})
        add_lsp("jdt-language-server", lspconfig.jdtls, {})
        add_lsp("texlab", lspconfig.texlab, {
          chktex = {
            onEdit = true,
            onOpenAndSave = true
          }
        })
      '';
    }
    {
      plugin = ltex_extra-nvim;
      type = "lua";
      config = /* lua */ ''
        local ltex_extra = require('ltex_extra')
        add_lsp("ltex-ls", lspconfig.ltex, {
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
        add_lsp("rust-analyzer", rust_tools, {
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
          formatting = { format = require('lspkind').cmp_format() },
          -- Same keybinds as vim's vanilla completion
          mapping = {
            ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
            ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
            ['<C-e>'] = cmp.mapping.close(),
            ['<C-y>'] = cmp.mapping.confirm(),
          },
          sources = {
            { name='buffer', option = { get_bufnrs = vim.api.nvim_list_bufs } },
            { name='nvim_lsp' },
          },
        }
      '';
    }
  ];
}

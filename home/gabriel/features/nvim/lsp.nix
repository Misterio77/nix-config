{pkgs, ...}: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    # LSP and completions for injected langs
    otter-nvim

    # LSP
    {
      plugin = nvim-lspconfig;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          local lspconfig = require('lspconfig')
          function add_lsp(server, options)
            if not options["cmd"] then
              options["cmd"] = server["document_config"]["default_config"]["cmd"]
            end
            if not options["capabilities"] then
              options["capabilities"] = require("cmp_nvim_lsp").default_capabilities()
            end

            if vim.fn.executable(options["cmd"][1]) == 1 then
              server.setup(options)
            end
          end

          add_lsp(lspconfig.bashls, {})
          add_lsp(lspconfig.clangd, {})
          add_lsp(lspconfig.dartls, {})
          add_lsp(lspconfig.dockerls, {})
          add_lsp(lspconfig.gopls, {})
          add_lsp(lspconfig.hls, {})
          add_lsp(lspconfig.jdtls, {})
          add_lsp(lspconfig.kotlin_language_server, {})
          add_lsp(lspconfig.lua_ls, {})
          add_lsp(lspconfig.nixd, { settings = { nixd = {
            formatting = { command = { "alejandra" }}
          }}})
          add_lsp(lspconfig.phpactor, {})
          add_lsp(lspconfig.pylsp, {})
          add_lsp(lspconfig.solargraph, {})
          add_lsp(lspconfig.terraformls, {})
          add_lsp(lspconfig.texlab, { chktex = {
            onEdit = true,
            onOpenAndSave = true
          }})
          add_lsp(lspconfig.tsserver, {})
          add_lsp(elixirls, {cmd = {"elixir-ls"}})
        '';
    }
    {
      plugin = ltex_extra-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
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
      config =
        /*
        lua
        */
        ''
          local rust_tools = require('rust-tools')
          add_lsp(rust_tools, {
            cmd = { "rust-analyzer" },
            tools = { autoSetHints = true }
          })
          vim.api.nvim_set_hl(0, '@lsp.type.comment.rust', {})
        '';
    }

    # Snippets
    luasnip

    # Completions
    cmp-nvim-lsp
    cmp_luasnip
    cmp-rg
    cmp-buffer
    cmp-path
    {
      plugin = cmp-git;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require("cmp_git").setup({})
        '';
    }

    lspkind-nvim
    {
      plugin = nvim-cmp;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          local cmp = require('cmp')

          cmp.setup({
            formatting = {
              format = require('lspkind').cmp_format({
                before = function (entry, vim_item)
                  return vim_item
                end,
              }),
            },
            snippet = {
              expand = function(args)
                require("luasnip").lsp_expand(args.body)
              end,
            },
            mapping = cmp.mapping.preset.insert({
            }),
            sources = {
              { name='otter' },
              { name='nvim_lsp' },
              { name='luasnip' },
              { name='git' },
              { name='buffer', option = { get_bufnrs = vim.api.nvim_list_bufs }},
              { name='path' },
              { name='rg' },
            },
          })
        '';
    }
  ];
}

{ pkgs, config, ... }: {
  # LSPs I want to always be available
  home.packages = with pkgs; [ rnix-lsp ];

  programs.neovim = {
    extraConfig = /* lua */ ''
    '';
    plugins = with pkgs.vimPlugins; [
      # LSP
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = /* lua */ ''
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
          vim.keymap.set("n", "<space>f", vim.lsp.buf.formatting, { desc = "Format code" })
          vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })

          function add_sign(name, text)
            vim.fn.sign_define(name, { text = text, texthl = name, numhl = name})
          end

          add_sign("DiagnosticSignError", " ")
          add_sign("DiagnosticSignWarn", " ")
          add_sign("DiagnosticSignHint", " ")
          add_sign("DiagnosticSignInfo", " ")

          local lspconfig = require('lspconfig')

          function add_lsp(binary, server, options)
            if vim.fn.executable(binary) == 1 then server.setup{options} end
          end

          add_lsp("docker-langserver", lspconfig.dockerls, {})
          add_lsp("docker-langserver", lspconfig.dockerls, {})
          add_lsp("bash-language-server", lspconfig.bashls, {})
          add_lsp("clangd", lspconfig.clangd, {})
          add_lsp("rnix-lsp", lspconfig.rnix, {})
          add_lsp("pylsp", lspconfig.pylsp, {})
          add_lsp("dart", lspconfig.pylsp, {})
          add_lsp("haskell-language-server", lspconfig.hls, {})
          add_lsp("kotlin-language-server", lspconfig.kotlin_language_server, {})
          add_lsp("solargraph", lspconfig.solargraph, {})
          add_lsp("phpactor", lspconfig.phpactor, {})
          add_lsp("terraform-ls", lspconfig.terraformls, {})
          add_lsp("lua-language-server", lspconfig.sumneko_lua, {})
          add_lsp("jdtls", lspconfig.jdtls, {})
          add_lsp("texlab", lspconfig.texlab, {})
        '';
      }
      {
        plugin = null-ls-nvim;
        type = "lua";
        config = /* lua */ ''
          local null_ls = require("null-ls")
          local sources = { }

          function add_null_ls(binary, server)
            if vim.fn.executable(binary) == 1 then table.insert(sources, server) end
          end

          add_null_ls("curlylint", null_ls.builtins.diagnostics.curlylint)
          add_null_ls("sqlfluff", null_ls.builtins.diagnostics.sqlfluff)
          add_null_ls("sqlfluff", null_ls.builtins.formatting.sqlfluff)
          add_null_ls("jq", null_ls.builtins.formatting.jq)
          add_null_ls("true", null_ls.builtins.completion.luasnip)

          null_ls.setup({ sources = sources})
        '';
      }
      {
        plugin = rust-tools-nvim;
        type = "lua";
        config = /* lua */ ''
          require('rust-tools').setup{ tools = { autoSetHints = true } }
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
  };
}

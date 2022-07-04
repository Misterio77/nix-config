{ pkgs, ... }: {
  # Add (some) LSP packages here (others are per-project, to avoid big stuff)
  home.packages = with pkgs; [
    editorconfig-checker
    nodePackages.jsonlint
  ];

  programs.neovim.plugins = with pkgs.vimPlugins; [
    # LSP
    {
      plugin = nvim-lspconfig;
      config = /* vim */ ''
        nmap gD       :lua vim.lsp.buf.declaration()<CR>
        nmap gd       :lua vim.lsp.buf.definition()<CR>
        nmap <space>f :lua vim.lsp.buf.formatting()<CR>

        autocmd CursorHold <buf> :lua vim.lsp.buf.hover()<CR>
        nmap K :lua vim.lsp.buf.hover()<CR>

        lua << EOF
          local lspconfig = require('lspconfig')
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          capabilities.textDocument.completion.completionItem.snippetSupport = true

          lspconfig.dockerls.setup{} -- Docker
          lspconfig.bashls.setup{} -- Bash
          lspconfig.clangd.setup{} -- C/C++
          lspconfig.rnix.setup{} -- Nix
          lspconfig.pylsp.setup{} -- Python
          lspconfig.sumneko_lua.setup{cmd = {"lua-language-server"}} -- Lua
          lspconfig.dartls.setup{} -- Dart
          lspconfig.hls.setup{} -- Haskell
          lspconfig.kotlin_language_server.setup{} -- Kotlin
          lspconfig.terraformls.setup{filetypes={"terraform","tf","hcl"}} -- Terraform
          lspconfig.solargraph.setup{} -- Ruby

          lspconfig.rust_analyzer.setup{ -- Rust
            settings = {
              ["rust-analyzer"] = {
                checkOnSave = {
                  command = "clippy",
                }
              }
            }
          }

          local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
          for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
          end
        EOF
      '';
    }
    {
      plugin = null-ls-nvim;
      config = /* vim */ ''
        lua << EOF
          local null_ls = require("null-ls")
          null_ls.setup({
              sources = {
                  -- Make
                  null_ls.builtins.diagnostics.checkmake,
                  -- Latex
                  null_ls.builtins.diagnostics.chktex,
                  -- HTML & templates
                  null_ls.builtins.formatting.prettier,
                  null_ls.builtins.diagnostics.curlylint,
                  -- Markdown
                  null_ls.builtins.diagnostics.markdownlint,
                  null_ls.builtins.formatting.markdownlint,
                  -- SQL
                  null_ls.builtins.diagnostics.sqlfluff,
                  null_ls.builtins.formatting.sqlfluff,
                  -- JSON
                  null_ls.builtins.formatting.jq,
                  null_ls.builtins.diagnostics.jsonlint,

                  -- Nix
                  null_ls.builtins.diagnostics.statix,
                  null_ls.builtins.code_actions.statix,
                  null_ls.builtins.diagnostics.deadnix,

                  -- General
                  null_ls.builtins.diagnostics.editorconfig_checker.with({
                    command = "editorconfig-checker",
                  }),
                  null_ls.builtins.diagnostics.trail_space.with({
                    disabled_filetypes = { "mail" },
                  }),
              },
          })
        EOF
      '';
    }
    {
      plugin = trouble-nvim;
      config = /* vim */ ''
        nnoremap <space>e <cmd>TroubleToggle<cr>
        lua require('trouble').setup{}
      '';
    }
    {
      plugin = rust-tools-nvim;
      config = /* vim */ ''
        lua require('rust-tools').setup{tools={autoSetHints = true}}
      '';
    }

    # Completions
    cmp-nvim-lsp
    cmp-buffer
    lspkind-nvim
    {
      plugin = nvim-cmp;
      config = /* vim */ ''
        lua << EOF
          local cmp = require('cmp')
          local lspkind = require('lspkind')

          cmp.setup{
            formatting = {
              format = lspkind.cmp_format()
            },
            mapping = {
              ['<C-n>'] = cmp.mapping.select_next_item({
                behavior = cmp.SelectBehavior.Insert }
              ),
              ['<C-p>'] = cmp.mapping.select_prev_item({
                behavior = cmp.SelectBehavior.Insert }
              ),
              ['<C-e>'] = cmp.mapping.close(),
              ['<C-Space>'] = cmp.mapping.complete(),
            },
            sources = {
              {
                name='buffer',
                option = {
                get_bufnrs = function()
                  return vim.api.nvim_list_bufs()
                end
                },
              },
              { name='nvim_lsp' },
            },
          }
        EOF
      '';
    }
  ];
}

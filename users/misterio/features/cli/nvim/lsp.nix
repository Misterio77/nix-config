{ pkgs, ... }: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    # LSP
    {
      plugin = nvim-lspconfig;
      config = ''
        lua << EOF
          local lspconfig = require('lspconfig')

          lspconfig.dockerls.setup{} -- Docker

          lspconfig.bashls.setup{} -- Bash

          lspconfig.rust_analyzer.setup{
            settings = {
              ["rust-analyzer"] = {
                checkOnSave = {
                  command = "clippy",
                }
              }
            }
          } -- Rust

          lspconfig.clangd.setup{} -- C/C++

          lspconfig.rnix.setup{} -- Nix

          lspconfig.jsonls.setup{} -- JSON

          lspconfig.sqls.setup{cmd = {"sqls", "-config", "sqls.yml"}} -- SQL

          lspconfig.pylsp.setup{} -- Python

          lspconfig.sumneko_lua.setup{cmd = {"lua-language-server"}} -- Lua

          lspconfig.dartls.setup{} -- Dart

        EOF

        nmap gD       :lua vim.lsp.buf.declaration()<CR>
        nmap gd       :lua vim.lsp.buf.definition()<CR>
        nmap <space>e :lua vim.lsp.diagnostic.show_line_diagnostics()<CR>
        nmap <space>f :lua vim.lsp.buf.formatting()<CR>

        autocmd CursorHold <buf> :lua vim.lsp.buf.hover()<CR>
        nmap K :lua vim.lsp.buf.hover()<CR>
      '';
    }
    {
      plugin = rust-tools-nvim;
      config = "lua require('rust-tools').setup{tools={autoSetHints = true}}";
    }

    # Completions
    cmp-nvim-lsp
    cmp-buffer
    lspkind-nvim
    {
      plugin = nvim-cmp;
      config = ''
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
              ['<C-m>'] = cmp.mapping.select_prev_item({
                behavior = cmp.SelectBehavior.Insert }
              ),
              ['<C-e>'] = cmp.mapping.close(),
            },
            sources = {
              { name='nvim_lsp' },
              { name='buffer' },
            },
          }
        EOF
      '';
    }
  ];
}

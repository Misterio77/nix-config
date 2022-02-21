{ pkgs, ... }: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    # LSP
    {
      plugin = nvim-lspconfig;
      config = /* vim */ ''
        lua << EOF
          local lspconfig = require('lspconfig')
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          capabilities.textDocument.completion.completionItem.snippetSupport = true

          lspconfig.dockerls.setup{} -- Docker
          lspconfig.bashls.setup{} -- Bash
          lspconfig.clangd.setup{} -- C/C++
          lspconfig.rnix.setup{} -- Nix
          lspconfig.jsonls.setup{} -- JSON
          lspconfig.sqls.setup{} -- SQL
          lspconfig.pylsp.setup{} -- Python
          lspconfig.sumneko_lua.setup{cmd = {"lua-language-server"}} -- Lua
          lspconfig.dartls.setup{} -- Dart
          lspconfig.hls.setup{} -- Haskell
          lspconfig.kotlin_language_server.setup{} -- Kotlin
          lspconfig.html.setup{} -- HTML
          lspconfig.cssls.setup{capabilities = capabilities} -- CSS/SASS
          lspconfig.terraformls.setup{filetypes={"terraform","tf","hcl"}} -- Terraform

          lspconfig.rust_analyzer.setup{ -- Rust
            settings = {
              ["rust-analyzer"] = {
                checkOnSave = {
                  command = "clippy",
                }
              }
            }
          }
        EOF

        nmap gD       :lua vim.lsp.buf.declaration()<CR>
        nmap gd       :lua vim.lsp.buf.definition()<CR>
        nmap <space>f :lua vim.lsp.buf.formatting()<CR>
        nmap <space>e :lua vim.diagnostic.get()<CR>

        autocmd CursorHold <buf> :lua vim.lsp.buf.hover()<CR>
        nmap K :lua vim.lsp.buf.hover()<CR>
      '';
    }
    {
      plugin = rust-tools-nvim;
      config = /* lua */ ''
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

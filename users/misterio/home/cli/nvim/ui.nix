{ pkgs, ... }: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    vim-illuminate
    vim-numbertoggle
    {
      plugin = telescope-nvim;
      config = /* vim */ ''
        lua require('telescope').setup{}
        nnoremap <leader>ff <cmd>Telescope find_files<cr>
        nnoremap <leader>fg <cmd>Telescope live_grep<cr>
        nnoremap <leader>fb <cmd>Telescope buffers<cr>
        nnoremap <leader>fh <cmd>Telescope help_tags<cr>
      '';
    }
    {
      plugin = which-key-nvim;
      config = /* lua */ ''
        lua require('which-key').setup{}
      '';
    }
    {
      plugin = range-highlight-nvim;
      config = /* lua */ ''
        lua require('range-highlight').setup{}
      '';
    }
    {
      plugin = indent-blankline-nvim;
      config = /* lua */ ''
        lua require('indent_blankline').setup{char_highlight_list={'IndentBlankLine'}}
      '';
    }
    {
      plugin = nvim-web-devicons;
      config = /* lua */  ''
        lua require('nvim-web-devicons').setup{}
      '';
    }
    {
      plugin = gitsigns-nvim;
      config = /* lua */ ''
        lua require('gitsigns').setup()
      '';
    }
    {
      plugin = nvim-colorizer-lua;
      config = /* vim */ ''
        set termguicolors
        lua require('colorizer').setup()
      '';
    }

    {
      plugin = barbar-nvim;
      config = /* vim */ ''
        let bufferline = get(g:, 'bufferline', {})
        let bufferline.animation = v:true
        nmap <C-h> :BufferPrevious<CR>
        nmap <C-l> :BufferNext<CR>
        nmap <C-q> :BufferClose<CR>
        nmap <C-a> :BufferPick<CR>
      '';
    }

    {
      plugin = nvim-tree-lua;
      config = /* vim */ ''
        lua require('nvim-tree').setup{}
        nmap <C-p> :NvimTreeToggle<CR>
      '';
    }
  ];
}

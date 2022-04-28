{ pkgs, ... }: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    vim-illuminate
    vim-numbertoggle
    {
      plugin = telescope-nvim;
      config = /* vim */ ''
        nnoremap <space>t <cmd>Telescope find_files<cr>
        nnoremap <space>g <cmd>Telescope live_grep<cr>

        lua << EOF
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')
        local telescope_custom_actions = {}

        function telescope_custom_actions._multiopen(prompt_bufnr, open_cmd)
          local picker = action_state.get_current_picker(prompt_bufnr)
          local selected_entry = action_state.get_selected_entry()
          local num_selections = #picker:get_multi_selection()
          if not num_selections or num_selections <= 1 then
              actions.add_selection(prompt_bufnr)
          end
          actions.send_selected_to_qflist(prompt_bufnr)
          vim.cmd("cfdo " .. open_cmd)
        end
        function telescope_custom_actions.multi_selection_open(prompt_bufnr)
          telescope_custom_actions._multiopen(prompt_bufnr, "edit")
        end


        require('telescope').setup {
          defaults = {
            mappings = {
              i = {
                ['<C-j>'] = actions.move_selection_next,
                ['<C-k>'] = actions.move_selection_previous,
                ['<tab>'] = actions.toggle_selection + actions.move_selection_next,
                ['<s-tab>'] = actions.toggle_selection + actions.move_selection_previous,
                ['<cr>'] = telescope_custom_actions.multi_selection_open
              },
              n = {
                ['<tab>'] = actions.toggle_selection + actions.move_selection_next,
                ['<s-tab>'] = actions.toggle_selection + actions.move_selection_previous,
                ['<cr>'] = telescope_custom_actions.multi_selection_open
              }
            },
          }
        }
        EOF
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

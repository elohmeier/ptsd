{ wrapNeovimUnstable
, neovim-unwrapped
, neovimUtils
, vimPlugins
, gopls
, rnix-lsp
, pyright
, go
, nodePackages
, nixpkgs-fmt
, python3Packages
}:

wrapNeovimUnstable neovim-unwrapped (neovimUtils.makeNeovimConfig {
  viAlias = true;
  vimAlias = true;
  withRuby = false;
  withPython3 = false;
  extraPython3Packages = ps: with ps; [ python-language-server ];

  configure.packages.ptsd.start = with vimPlugins; [
    vim-nix
    vim-css-color
    diffview-nvim
    nvim-web-devicons
    neogit
    nvim-treesitter
    nvim-lspconfig
    nvim-tree-lua
    hop-nvim
    nvim-compe
    formatter-nvim
    telescope-nvim
    lualine-nvim
    neorg
  ];

  plugins = with vimPlugins; [
    vim-nix # TODO: rm when tree-sitter-nix works
    #nnn-vim
    vim-css-color
    diffview-nvim
    nvim-web-devicons
    {
      plugin = neogit;
      config = ''
        lua <<EOF
        require'neogit'.setup {
          integrations = {
            diffview = true,
          },
        }
        EOF
      '';
    }
    {
      plugin = (nvim-treesitter.withPlugins (plugins: with plugins; [
        tree-sitter-go
        tree-sitter-nix
        tree-sitter-python
      ]));
      config = ''
        lua <<EOF
          require'nvim-treesitter.configs'.setup {
            highlight = {
              enable = true,
              additional_vim_regex_highlighting = false,
            },
          }
        EOF
      '';
    }
    {
      plugin = nvim-lspconfig;
      config = ''
        lua <<EOF
        require'lspconfig'.gopls.setup{
          cmd = { "${gopls}/bin/gopls" },
        }
        require'lspconfig'.rnix.setup{
          cmd = { "${rnix-lsp}/bin/rnix-lsp" },
        }
        require'lspconfig'.pyright.setup{
          cmd = { "${pyright}/bin/pyright-langserver", "--stdio" },
        }
        EOF'';
    }
    {
      plugin = nvim-tree-lua;
      config = "map <C-n> :NvimTreeToggle<CR>";
    }
    {
      plugin = hop-nvim;
      config = ''
        nnoremap <leader>hl :HopLine<CR>
      '';
    }
    {
      plugin = nvim-compe;
      config = ''
        lua << EOF
        vim.o.completeopt = "menuone,noselect"
        require'compe'.setup({
          enabled = true,
          source = {
            path = true,
            buffer = true,
            nvim_lsp = true,
          },
        })
        EOF

        inoremap <silent><expr> <C-Space> compe#complete()
        inoremap <silent><expr> <CR>      compe#confirm('<CR>')
        inoremap <silent><expr> <C-e>     compe#close('<C-e>')
        inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
        inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })
      '';
    }
    {
      plugin = formatter-nvim;
      config = ''
        lua << EOF
          require('formatter').setup({
            filetype = {
              go = {
                function()
                  return {
                    exe = "${go}/bin/gofmt",
                    stdin = true
                  }
                end
              },
              html = {
                function()
                  return {
                    exe = "${nodePackages.prettier}/bin/prettier",
                    args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0), '--single-quote'},
                    stdin = true,
                  }
                  end
              },
              javascript = {
                function()
                  return {
                    exe = "${nodePackages.prettier}/bin/prettier",
                    args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0), '--single-quote'},
                    stdin = true,
                  }
                  end
              },
              nix = {
                function()
                  return {
                    exe = "${nixpkgs-fmt}/bin/nixpkgs-fmt",
                    stdin = true
                  }
                end
              },
              python = {
                function()
                  return {
                    exe = "${python3Packages.black}/bin/black",
                    args = {"-"},
                    stdin = true
                  }
                end
              }
            }
          })
        EOF
        nnoremap <silent> <leader>i :Format<CR>
      '';
    }
    {
      plugin = telescope-nvim;
      config = ''
        nnoremap <leader>ff <cmd>Telescope find_files<cr>
        nnoremap <leader>fg <cmd>Telescope live_grep<cr>
        nnoremap <leader>fb <cmd>Telescope buffers<cr>
        nnoremap <leader>fh <cmd>Telescope help_tags<cr>
      '';
    }
    {
      plugin = lualine-nvim;
      config = ''
        lua << EOF
          require('lualine').setup()
        EOF
      '';
    }
    neorg
  ];
})

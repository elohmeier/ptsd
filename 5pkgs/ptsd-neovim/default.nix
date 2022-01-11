{ lib
, wrapNeovimUnstable
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
, clang-tools
, shfmt
, enableFormatters ? true
, enableLSP ? true
, sqlfluff
}:
with lib;

let
  treesitter = (vimPlugins.nvim-treesitter.withPlugins (plugins: with plugins; [
    # tree-sitter-beancount # TODO: wait for https://github.com/NixOS/nixpkgs/pull/145057
    tree-sitter-go
    tree-sitter-nix
    tree-sitter-norg
    tree-sitter-python
  ]));
in
wrapNeovimUnstable neovim-unwrapped (neovimUtils.makeNeovimConfig {
  viAlias = true;
  vimAlias = true;
  withRuby = false;
  withPython3 = false;
  extraPython3Packages = ps: with ps; optionals enableLSP [ python-language-server ];

  configure.packages.ptsd.start = with vimPlugins; [
    vim-css-color
    nvim-web-devicons
    treesitter
    nvim-tree-lua
    hop-nvim
    nvim-compe
    telescope-nvim
    lualine-nvim
    neorg
    copilot-vim
  ] ++ (optional enableLSP nvim-lspconfig)
  ++ (optional enableFormatters formatter-nvim);

  plugins = with vimPlugins; [
    copilot-vim
    vim-css-color
    nvim-web-devicons
    {
      plugin = treesitter;
      config = ''
        lua <<EOF
          require'nvim-treesitter.configs'.setup {
            highlight = {
              enable = true,
              additional_vim_regex_highlighting = false,
            },
            indent = {
              enable = false,
            },
          }
          vim.api.nvim_command('autocmd BufRead,BufNewFile *.nix set filetype=nix')
        EOF
      '';
    }
    {
      plugin = nvim-tree-lua;
      config = ''
        lua <<EOF
          require'nvim-tree'.setup()
        EOF
        map <C-n> :NvimTreeToggle<CR>
      '';
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
              neorg = true,
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
    {
      plugin = neorg;
      config = ''
        lua << EOF
          require('neorg').setup {
            load = {
              ["core.defaults"] = {},
              ["core.norg.completion"] = {
                config = {
                  engine = "nvim-compe",
                },
              },
              ["core.norg.concealer"] = {},
              ["core.norg.dirman"] = {
                config = {
                  workspaces = {
                    my_workspace = "~/Pocket",
                  },
                },
              },
              ["core.keybinds"] = {
                config = {
                  default_keybinds = true,
                  neorg_leader = "<Leader>o",
                },
              },
            },
          }
        EOF
      '';
    }
  ]
  ++ (optional enableLSP
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
    }) ++

  (
    optional
      enableFormatters
      {
        plugin = formatter-nvim;
        config = ''
          lua << EOF
            require('formatter').setup({
              filetype = {
                c = {
                  function()
                    return {
                      exe = "${clang-tools}/bin/clang-format",
                      args = {"--assume-filename", vim.api.nvim_buf_get_name(0)},
                      stdin = true,
                      cwd = vim.fn.expand('%:p:h')
                    }
                  end
                },
                cpp = {
                  function()
                    return {
                      exe = "${clang-tools}/bin/clang-format",
                      args = {"--assume-filename", vim.api.nvim_buf_get_name(0)},
                      stdin = true,
                      cwd = vim.fn.expand('%:p:h')
                    }
                  end
                },
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
                json = {
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
                },
                sh = {
                  function()
                    return {
                      exe = "${shfmt}/bin/shfmt",
                      args = {"-"},
                      stdin = true
                    }
                  end
                },
                sql = {
                  function()
                    return {
                      exe = "${sqlfluff}/bin/sqlfluff",
                      args = {"fix", "--force", "--dialect", "postgres", "-"},
                      stdin = true
                    }
                  end
                },
                typescriptreact = {
                  function()
                    return {
                      exe = "${nodePackages.prettier}/bin/prettier",
                      args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0), '--single-quote'},
                      stdin = true,
                    }
                    end
                },
              }
            })
          EOF
          nnoremap <silent> <leader>i :Format<CR>
        '';
      }
  );
})

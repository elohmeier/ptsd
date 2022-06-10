require'hop'.setup()

vim.api.nvim_set_keymap('n', '<leader>hl', '<cmd>lua require"hop".hint_lines()<cr>',
                        {noremap = true, silent = true})

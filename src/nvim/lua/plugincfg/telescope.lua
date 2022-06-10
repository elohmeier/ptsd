vim.api.nvim_set_keymap("n", "<leader>ff", "<cmd>Telescope find_files<CR>",
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>fb", "<cmd>Telescope buffers<CR>",
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>fh", "<cmd>Telescope help_tags<CR>",
                        {noremap = true, silent = true})

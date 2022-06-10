require("nnn").setup()

vim.api.nvim_set_keymap("n", "<leader>n", "<cmd>NnnPicker %:p:h<CR>",
                        {noremap = true, silent = true})

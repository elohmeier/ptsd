vim.g.mapleader = ","

-- global statusline
vim.opt.laststatus = 3

-- thin split lines
vim.cmd [[highlight WinSeparator guibg=None]]

require("plugincfg.formatter");
require("plugincfg.hop");
require("plugincfg.lspconfig");
require("plugincfg.lualine");
require("plugincfg.nnn");
require("plugincfg.telescope");
require("plugincfg.treesitter");

-- open empty buffer
vim.api.nvim_set_keymap("n", "<leader>m", "<cmd>enew<cr>", {noremap = true, silent = true})

-- buffer navigation
vim.api.nvim_set_keymap("n", "<leader>l", "<cmd>bnext<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>h", "<cmd>bprevious<cr>", {noremap = true, silent = true})

-- close current buffer and switch to previous buffer
vim.api.nvim_set_keymap("n", "<leader>bq", "<cmd>bp<bar>bd #<cr>", {noremap = true, silent = true})

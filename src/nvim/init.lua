


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



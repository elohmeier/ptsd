vim.g.mapleader = ","

local o = vim.o
o.expandtab = true
o.smartindent = true
o.tabstop = 2
o.shiftwidth = 2

-- global statusline
vim.opt.laststatus = 3

-- thin split lines
vim.cmd [[highlight WinSeparator guibg=None]]

-- **************
-- * plugin cfg *
-- **************

require("plugincfg.formatter")
require("hop").setup()

require("lspconfig").gopls.setup {cmd = {"gopls"}}
require("lspconfig").rnix.setup {cmd = {"rnix-lsp"}}
require("lspconfig").pyright.setup {cmd = {"pyright-langserver", "--stdio"}}

require("lualine").setup()
require("nnn").setup()

require("nvim-treesitter.configs").setup {
    highlight = {enable = true, additional_vim_regex_highlighting = false},
    indent = {enable = false}
}

-- ***************
-- * Keybindings *
-- ***************

-- open empty buffer
vim.api.nvim_set_keymap("n", "<leader>m", "<cmd>enew<cr>", {noremap = true, silent = true})

-- LSP
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, {buffer = args.buf})
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {buffer = args.buf})
    end
})

-- buffer navigation
vim.api.nvim_set_keymap("n", "<leader>l", "<cmd>bnext<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>h", "<cmd>bprevious<cr>", {noremap = true, silent = true})

-- close current buffer and switch to previous buffer
vim.api.nvim_set_keymap("n", "<leader>bq", "<cmd>bp<bar>bd #<cr>", {noremap = true, silent = true})

-- plugin: formatter
vim.api.nvim_set_keymap("n", "<leader>i", "<cmd>Format<CR>", {noremap = true, silent = true})

-- plugin: hop
vim.api.nvim_set_keymap("n", "<leader>hl", "<cmd>lua require'hop'.hint_lines()<cr>",
                        {noremap = true, silent = true})

-- plugin: nnn
vim.api.nvim_set_keymap("n", "<leader>n", "<cmd>NnnPicker %:p:h<CR>",
                        {noremap = true, silent = true})

vim.api.nvim_set_keymap("n", "<C-n>", "<cmd>NnnExplorer<CR>", {noremap = true, silent = true})

-- plugin: telescope
vim.api.nvim_set_keymap("n", "<leader>ff", "<cmd>Telescope find_files<CR>",
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>fb", "<cmd>Telescope buffers<CR>",
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>fh", "<cmd>Telescope help_tags<CR>",
                        {noremap = true, silent = true})

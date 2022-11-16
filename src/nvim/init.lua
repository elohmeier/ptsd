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

-- ******************************
-- * filetype specific settings *
-- ******************************

vim.api.nvim_create_autocmd("FileType", {
    pattern = "tex,plaintex,context",
    callback = function()
        vim.api.nvim_buf_set_option(0, "formatoptions", "tcqj") -- use "gq" to format paragraphs
        vim.api.nvim_buf_set_option(0, "textwidth", 120)
        vim.api.nvim_win_set_option(0, "colorcolumn", "121")
    end
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "fish",
    callback = function()
        vim.api.nvim_buf_set_option(0, "tabstop", 4)
        vim.api.nvim_buf_set_option(0, "shiftwidth", 4)
    end
})

-- **************
-- * plugin cfg *
-- **************

require("impatient")

require("github-theme").setup({theme_style = "light"})

require("plugincfg.formatter")
require("plugincfg.cmp")
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol
                                                                      .make_client_capabilities())

require("leap").set_default_keymaps()
require("lspconfig").gopls.setup {cmd = {"gopls"}, capabilities = {capabilities}}
require("lspconfig").pyright.setup {
    cmd = {"pyright-langserver", "--stdio"},
    capabilities = {capabilities}
}
require("lspconfig").rnix.setup {cmd = {"rnix-lsp"}, capabilities = {capabilities}}
require("lualine").setup()
require("nnn").setup()

require("nvim-treesitter.configs").setup {
    highlight = {enable = true, additional_vim_regex_highlighting = false},
    indent = {enable = false}
}

require("telescope").setup {
    extenssions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case"
        }
    }
}
require("telescope").load_extension("fzf")

require("luasnip.loaders.from_lua").load({paths = "~/repos/ptsd/src/snippets"})

-- ***************
-- * keybindings *
-- ***************

-- open empty buffer
vim.api.nvim_set_keymap("n", "<leader>m", "<cmd>enew<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>b", "<cmd>make<cr><cr>", {noremap = true, silent = true})

-- LSP, see https://github.com/neovim/nvim-lspconfig
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local bufopts = {noremap = true, silent = true, buffer = args.buf}
        vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
    end
})

-- buffer navigation
vim.api.nvim_set_keymap("n", "<leader>l", "<cmd>bnext<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>h", "<cmd>bprevious<cr>", {noremap = true, silent = true})

-- close current buffer and switch to previous buffer
vim.api.nvim_set_keymap("n", "<leader>bq", "<cmd>bp<bar>bd #<cr>", {noremap = true, silent = true})

-- plugin: formatter
vim.api.nvim_set_keymap("n", "<leader>i", "<cmd>Format<CR>", {noremap = true, silent = true})

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
vim.api.nvim_set_keymap("n", "<leader>fd", "<cmd>Telescope resume<CR>",
                        {noremap = true, silent = true})

vim.api.nvim_set_keymap("i", "<C-j>", 'copilot#Accept("<CR>")',
                        {noremap = true, expr = true, silent = true})
vim.g.copilot_no_tab_map = true

-- plugin: spread
vim.api.nvim_set_keymap("n", "<leader>ss", "<cmd>lua require'spread'.out()<cr>",
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>ssc", "<cmd>lua require'spread'.combine()<cr>",
                        {noremap = true, silent = true})

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
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "fish",
    callback = function()
        vim.api.nvim_buf_set_option(0, "tabstop", 4)
        vim.api.nvim_buf_set_option(0, "shiftwidth", 4)
    end,
})

-- **************
-- * plugin cfg *
-- **************

require("impatient")

require("github-theme").setup({theme_style = "light"})
-- require("github-theme").setup({theme_style = "dark"})

-- require("plugincfg.formatter")
require("plugincfg.coc")

require("leap").set_default_keymaps()
require("lspconfig").gopls.setup {cmd = {"gopls"}, capabilities = {capabilities}}
require("lspconfig").pyright.setup {cmd = {"pyright-langserver", "--stdio"}, capabilities = {capabilities}}
require("lspconfig").nil_ls.setup {cmd = {"nil"}, capabilities = {capabilities}}
require("lspconfig").jsonnet_ls.setup {cmd = {"jsonnet-language-server"}, capabilities = {capabilities}}
require("lspconfig").svelte.setup {
    cmd = {"svelteserver", "--stdio"},
    capabilities = {capabilities},
    on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
    end,
}
require("lspconfig").tsserver.setup {cmd = {"typescript-language-server", "--stdio"}, capabilities = {capabilities}}
require("lspconfig").efm.setup {
    filetypes = {"typescript", "lua", "python", "nix", "svelte", "yaml", "json", "sh", "markdown", "css"},
    init_options = {documentFormatting = true},
    settings = {
        rootMarkers = {".git/"},
        languages = {
            lua = {
                {
                    formatCommand = "lua-format -i --no-keep-simple-function-one-line --no-break-after-operator --extra-sep-at-table-end --column-limit=120",
                    formatStdin = true,
                },
            },
            nix = {{formatCommand = "nixpkgs-fmt", formatStdin = true}},
            python = {{formatCommand = "isort --quiet - | black --quiet -", formatStdin = true}},
            svelte = {{formatCommand = "prettier --stdin-filepath ${INPUT}", formatStdin = true}},
            typescript = {{formatCommand = "prettier --stdin-filepath ${INPUT}", formatStdin = true}},
            yaml = {{formatCommand = "prettier --stdin-filepath ${INPUT}", formatStdin = true}},
            json = {{formatCommand = "prettier --stdin-filepath ${INPUT}", formatStdin = true}},
            sh = {{formatCommand = "shfmt -ci -s -bn", formatStdin = true}},
            markdown = {{formatCommand = "prettier --stdin-filepath ${INPUT}", formatStdin = true}},
            css = {{formatCommand = "prettier --stdin-filepath ${INPUT}", formatStdin = true}},
        },
    },
}
require("lualine").setup()

require("nvim-treesitter.configs").setup {
    highlight = {enable = true, additional_vim_regex_highlighting = false},
    indent = {enable = false},
}

local actions = require("telescope.actions")
require("telescope").setup {
    defaults = {mappings = {i = {["<esc>"] = actions.close}}},
    extenssions = {
        fzf = {fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = "smart_case"},
    },
}
require("telescope").load_extension("fzf")

require("oil").setup()

require("nvim-surround").setup({})

require("gitsigns").setup {
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]c", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(function()
                gs.next_hunk()
            end)
            return "<Ignore>"
        end, {expr = true})

        map("n", "[c", function()
            if vim.wo.diff then return "[c" end
            vim.schedule(function()
                gs.prev_hunk()
            end)
            return "<Ignore>"
        end, {expr = true})

        -- Actions
        map({"n", "v"}, "<leader>hs", ":Gitsigns stage_hunk<CR>")
        map({"n", "v"}, "<leader>hr", ":Gitsigns reset_hunk<CR>")
        map("n", "<leader>hS", gs.stage_buffer)
        map("n", "<leader>hu", gs.undo_stage_hunk)
        map("n", "<leader>hR", gs.reset_buffer)
        map("n", "<leader>hp", gs.preview_hunk)
        map("n", "<leader>hb", function()
            gs.blame_line {full = true}
        end)
        map("n", "<leader>tb", gs.toggle_current_line_blame)
        map("n", "<leader>hd", gs.diffthis)
        map("n", "<leader>hD", function()
            gs.diffthis("~")
        end)
        map("n", "<leader>td", gs.toggle_deleted)

        -- Text object
        map({"o", "x"}, "ih", ":<C-U>Gitsigns select_hunk<CR>")
    end,
}

require("trouble").setup()

require("Comment").setup()

-- require("jdtls").start_or_attach({
--     cmd = {"jdt-language-server"},
--     root_dir = vim.fs.dirname(vim.fs.find({'.gradlew', '.git', 'mvnw'}, {upward = true})[1])
-- })

require("dap-python").setup("python3")
require("dapui").setup()

vim.o.timeout = true
vim.o.timeoutlen = 300

vim.opt.list = true
vim.opt.listchars:append "space:⋅"
vim.opt.listchars:append "eol:↴"

require("indent_blankline").setup {
    space_char_blankline = " ",
    show_current_context = true,
    show_current_context_start = true,
}

require("nvim-treesitter.configs").setup {
    textobjects = {
        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                ["]m"] = "@function.outer",
                ["]]"] = {query = "@class.outer", desc = "Next class start"},
                --
                -- You can use regex matching and/or pass a list in a "query" key to group multiple queires.
                ["]o"] = "@loop.*",
                -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
                --
                -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
                -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
                ["]s"] = {query = "@scope", query_group = "locals", desc = "Next scope"},
                ["]z"] = {query = "@fold", query_group = "folds", desc = "Next fold"},
            },
            goto_next_end = {["]M"] = "@function.outer", ["]["] = "@class.outer"},
            goto_previous_start = {["[m"] = "@function.outer", ["[["] = "@class.outer"},
            goto_previous_end = {["[M"] = "@function.outer", ["[]"] = "@class.outer"},
            -- Below will go to either the start or the end, whichever is closer.
            -- Use if you want more granular movements
            -- Make it even more gradual by adding multiple queries and regex.
            goto_next = {["]d"] = "@conditional.outer"},
            goto_previous = {["[d"] = "@conditional.outer"},
        },
        swap = {
            enable = true,
            swap_next = {["<leader>a"] = "@parameter.inner"},
            swap_previous = {["<leader>A"] = "@parameter.inner"},
        },
    },
}

require('spectre').setup({replace_engine = {['sed'] = {cmd = "sed"}}})

require("notebook")
local api = require("notebook.api")
local settings = require("notebook.settings")

function _G.define_cell(extmark)
    if extmark == nil then
        local line = vim.fn.line(".")
        extmark, _ = api.current_extmark(line)
    end
    local start_line = extmark[1] + 1
    local end_line = extmark[3].end_row
    pcall(function()
        vim.fn.MagmaDefineCell(start_line, end_line)
    end)
end

function _G.define_all_cells()
    local buffer = vim.api.nvim_get_current_buf()
    local extmarks = settings.extmarks[buffer]
    for id, cell in pairs(extmarks) do
        local extmark = vim.api.nvim_buf_get_extmark_by_id(0, settings.plugin_namespace, id, {details = true})
        if cell.cell_type == "code" then define_cell(extmark) end
    end
end

vim.api.nvim_create_autocmd({"BufRead"}, {pattern = {"*.ipynb"}, command = "MagmaInit"})
vim.api.nvim_create_autocmd("User", {pattern = {"MagmaInitPost", "NBPostRender"}, callback = _G.define_all_cells})

-- ***************
-- * keybindings *
-- ***************

vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").open()<CR>', {desc = "Open Spectre"})
vim.keymap.set('n', '<leader>sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
               {desc = "Search current word"})
vim.keymap.set('v', '<leader>sw', '<esc><cmd>lua require("spectre").open_visual()<CR>', {desc = "Search current word"})
vim.keymap.set('n', '<leader>sp', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>',
               {desc = "Search on current file"})

-- Option + Shift + w to insert „ (like in macOS)
vim.api.nvim_set_keymap("i", "<M-S-w>", "„", {noremap = true, silent = true})

-- Option + [ to insert “ (like in macOS)
vim.api.nvim_set_keymap("i", "<M-[>", "“", {noremap = true, silent = true})

-- Option + u followed by a,o,u,A,O,U to insert ä,ö,ü,Ä,Ö,Ü (like in macOS)
vim.api.nvim_set_keymap("i", "<M-u>a", "ä", {noremap = true, silent = true})
vim.api.nvim_set_keymap("i", "<M-u>o", "ö", {noremap = true, silent = true})
vim.api.nvim_set_keymap("i", "<M-u>u", "ü", {noremap = true, silent = true})
vim.api.nvim_set_keymap("i", "<M-u>A", "Ä", {noremap = true, silent = true})
vim.api.nvim_set_keymap("i", "<M-u>O", "Ö", {noremap = true, silent = true})
vim.api.nvim_set_keymap("i", "<M-u>U", "Ü", {noremap = true, silent = true})

-- Option + s insert ß (like in macOS)
vim.api.nvim_set_keymap("i", "<M-s>", "ß", {noremap = true, silent = true})

-- tab navigation
vim.api.nvim_set_keymap("n", "tn", "<cmd>tabnew<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "td", "<cmd>tabclose<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "tt", "<cmd>tabedit<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "th", "<cmd>tabfirst<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "tl", "<cmd>tablast<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "tj", "<cmd>tabnext<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "tk", "<cmd>tabprevious<cr>", {noremap = true, silent = true})

-- LSP, see https://github.com/neovim/nvim-lspconfig
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local bufopts = {noremap = true, silent = true, buffer = args.buf}
        vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
    end,
})

-- buffer navigation
vim.api.nvim_set_keymap("n", "<leader>l", "<cmd>bnext<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>h", "<cmd>bprevious<cr>", {noremap = true, silent = true})

-- close current buffer and switch to previous buffer
vim.api.nvim_set_keymap("n", "<leader>bq", "<cmd>bp<bar>bd #<cr>", {noremap = true, silent = true})

-- plugin: formatter
-- vim.api.nvim_set_keymap("n", "<leader>i", "<cmd>Format<CR>", {noremap = true, silent = true})

-- format using lsp
vim.api.nvim_set_keymap("n", "<leader>i", "<cmd>lua vim.lsp.buf.format()<CR>", {noremap = true, silent = true})

-- plugin: neo-tree
vim.api.nvim_set_keymap("n", "<leader>n", "<cmd>NeoTreeFloat<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>m", "<cmd>Neotree git_status reveal float<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "\\", "<cmd>Neotree filesystem reveal left<CR>", {noremap = true, silent = true})

-- plugin: telescope
vim.api.nvim_set_keymap("n", "<leader>ff", "<cmd>Telescope find_files<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>fg",
                        "<cmd>lua require'telescope.builtin'.live_grep({ additional_args = { '-j1' }})<CR>",
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>fb", "<cmd>Telescope buffers<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>g", "<cmd>Telescope resume<CR>", {noremap = true, silent = true})

vim.api.nvim_set_keymap("i", "<C-j>", 'copilot#Accept("<CR>")', {noremap = true, expr = true, silent = true})
vim.g.copilot_no_tab_map = true

-- plugin: spread
vim.api.nvim_set_keymap("n", "<leader>ss", "<cmd>lua require'spread'.out()<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>ssc", "<cmd>lua require'spread'.combine()<cr>", {noremap = true, silent = true})

-- copy to system clipboard
vim.api.nvim_set_keymap("v", "<leader>y", '"+y', {noremap = true, silent = true})


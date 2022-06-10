vim.api.nvim_set_keymap("n", "<leader>i", "<cmd>Format<CR>", {noremap = true, silent = true})

require('formatter').setup({
    filetype = {
        c = {
            function()
                return {
                    exe = "clang-format",
                    args = {"--assume-filename", vim.api.nvim_buf_get_name(0)},
                    stdin = true,
                    cwd = vim.fn.expand('%:p:h')
                }
            end
        },
        cpp = {
            function()
                return {
                    exe = "clang-format",
                    args = {"--assume-filename", vim.api.nvim_buf_get_name(0)},
                    stdin = true,
                    cwd = vim.fn.expand('%:p:h')
                }
            end
        },
        go = {function() return {exe = "gofmt", stdin = true} end},
        html = {
            function()
                return {
                    exe = "prettier",
                    args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0), '--single-quote'},
                    stdin = true
                }
            end
        },
        javascript = {
            function()
                return {
                    exe = "prettier",
                    args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0), '--single-quote'},
                    stdin = true
                }
            end
        },
        json = {
            function()
                return {
                    exe = "prettier",
                    args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0), '--single-quote'},
                    stdin = true
                }
            end
        },
        lua = {
            function()
                return {exe = "lua-format", args = {"--column-limit=100"}, stdin = true}
            end
        },
        nix = {function() return {exe = "nixpkgs-fmt", stdin = true} end},
        python = {function() return {exe = "black", args = {"-"}, stdin = true} end},
        sh = {function() return {exe = "shfmt", args = {"-"}, stdin = true} end},
        sql = {
            function()
                return {
                    exe = "sqlfluff",
                    args = {"fix", "--force", "--dialect", "postgres", "-"},
                    stdin = true
                }
            end
        },
        typescriptreact = {
            function()
                return {
                    exe = "prettier",
                    args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0), '--single-quote'},
                    stdin = true
                }
            end
        }
    }
})

local prettier = function()
    return {
        exe = "prettier",
        args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0), '--single-quote'},
        stdin = true
    }
end

local clang_format = function()
    return {
        exe = "clang-format",
        args = {"--assume-filename", vim.api.nvim_buf_get_name(0)},
        stdin = true,
        cwd = vim.fn.expand('%:p:h')
    }
end

require('formatter').setup({
    filetype = {
        c = {clang_format},
        cpp = {clang_format},
        fish = {function() return {exe = "fish_indent", stdin = true} end},
        go = {function() return {exe = "gofmt", stdin = true} end},
        html = {prettier},
        javascript = {prettier},
        json = {prettier},
        lua = {
            function()
                return {exe = "lua-format", args = {"--column-limit=100"}, stdin = true}
            end
        },
        nix = {function() return {exe = "nixpkgs-fmt", stdin = true} end},
        python = {
            function()
                return {exe = "isort", args = {"--profile", "black", "-"}, stdin = true}
            end, function() return {exe = "black", args = {"-"}, stdin = true} end
        },
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
        svelte = {
            function()
                return {
                    exe = "prettier",
                    args = {
                        "--stdin-filepath", vim.api.nvim_buf_get_name(0), '--single-quote',
                        '--plugin=prettier-plugin-svelte'
                    },
                    stdin = true
                }
            end
        },
        typescript = {prettier},
        typescriptreact = {prettier}
    }
})

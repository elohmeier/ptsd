require'lspconfig'.gopls.setup {cmd = {"gopls"}}
require'lspconfig'.rnix.setup {cmd = {"rnix-lsp"}}
require'lspconfig'.pyright.setup {cmd = {"pyright-langserver", "--stdio"}}

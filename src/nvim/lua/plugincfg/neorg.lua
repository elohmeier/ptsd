
require('neorg').setup {
  load = {
    ["core.defaults"] = {},
    ["core.norg.completion"] = {
      config = {
        engine = "nvim-compe",
      },
    },
    ["core.norg.concealer"] = {},
    ["core.norg.dirman"] = {
      config = {
        workspaces = {
          my_workspace = "~/Pocket",
        },
      },
    },
    ["core.keybinds"] = {
      config = {
        default_keybinds = true,
        neorg_leader = "<Leader>o",
      },
    },
  },
}

return {
  {
    "xiyaowong/transparent.nvim",
    opts = {
      groups = { -- Add all groups you want to clear
        "Normal",
        "NormalNC",
        "Comment",
        "Constant",
        "Special",
        "Identifier",
        "Statement",
        "PreProc",
        "Type",
        "Underlined",
        "Todo",
        "String",
        "Function",
        "Conditional",
        "Repeat",
        "Operator",
        "Structure",
        "LineNr",
        "NonText",
        "SignColumn",
        "CursorLine",
        "CursorLineNr",
        "StatusLine",
        "StatusLineNC",
        "EndOfBuffer",
      },
      extra_groups = { -- Additional groups (plugins, LSP, etc.)
        "NormalFloat", -- Floating windows
        "NvimTreeNormal", -- File explorer
        "TelescopeNormal", -- Telescope
        "LazyNormal", -- Lazy plugin manager
      },
      exclude_groups = {}, -- Groups to exclude (leave empty)
    },
    config = function(_, opts)
      require("transparent").setup(opts)
    end,
  },
}

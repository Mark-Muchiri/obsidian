local border_type = "rounded"

return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      diagnostics = { float = { border = border_type } },
    },
  },
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@type AstroLSPOpts
    opts = {
      defaults = {
        hover = { border = border_type },
        signature_help = { border = border_type },
      },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    optional = true,
    opts = {
      float_opts = { border = border_type },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    optional = true,
    opts = {
      floating = { border = border_type },
    },
  },
  {
    "Saghen/blink.cmp",
    optional = true,
    opts = {
      completion = {
        menu = { border = border_type },
        documentation = { window = { border = border_type } },
      },
      signature = { window = { border = border_type } },
    },
    {
      "nvim-neo-tree/neo-tree.nvim",
      optional = true,
      opts = {
        popup_border_style = border_type,
        window = { position = "float" },
      },
    },
    {
      "williamboman/mason.nvim",
      opts = {
        ui = {
          border = border_type,
        },
      },
    },
    {
      "folke/lazy.nvim",
      opts = {
        ui = {
          border = "rounded",
          backdrop = 60,
        },
      },
    },
  },
}

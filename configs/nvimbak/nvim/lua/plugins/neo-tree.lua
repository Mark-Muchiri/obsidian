return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    source_selector = {
      winbar = false, -- remove top tabs bar
      statusline = false, -- if you'd also like disable sources in statusline
      -- optionally override layout and content: [...]
    },
  },
  config = function(_, opts)
    require("neo-tree").setup(opts)
    -- override highlight groups
    vim.api.nvim_set_hl(0, "NeoTreeFloatTitle", { bg = "NONE", fg = "#919191" })
  end,
}

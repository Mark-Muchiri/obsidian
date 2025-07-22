return {
  "navarasu/onedark.nvim",
  -- lazy = false,
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    require("onedark").setup {
      style = "deep",
    }
    -- Enable theme
    require("onedark").load()
  end,

  vim.defer_fn(function()
    -- ... existing configuration ...

    -- Use terminal's background color instead of "NONE"
    local transparent_bg = vim.fn.has "gui_running" == 1 and "NONE" or ""

    -- Enhanced Tabline Fixes
    vim.api.nvim_set_hl(0, "BufferLineFill", { bg = transparent_bg }) -- Background of the entire tabline
    vim.api.nvim_set_hl(0, "BufferLineBackground", { bg = transparent_bg }) -- Background of inactive tabs

    -- Fix typos in group names:
    vim.api.nvim_set_hl(0, "BufferLineSeparator", { bg = transparent_bg, fg = "#5c6370" })
    vim.api.nvim_set_hl(0, "BufferLineTabSelected", { bg = transparent_bg })
    vim.api.nvim_set_hl(0, "BufferLineTabClose", { bg = transparent_bg })

    -- Additional groups for full transparency
    vim.api.nvim_set_hl(0, "BufferLineTab", { bg = transparent_bg })
    vim.api.nvim_set_hl(0, "BufferLineOffsetSeparator", { bg = transparent_bg })

    -- ... rest of your configuration ...
  end, 1),
}

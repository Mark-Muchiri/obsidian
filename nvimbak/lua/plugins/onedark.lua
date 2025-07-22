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

  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
      local NONE = "NONE"

      -- core
      vim.api.nvim_set_hl(0, "Normal", { bg = NONE })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = NONE })
      vim.api.nvim_set_hl(0, "NormalNC", { bg = NONE })
      vim.api.nvim_set_hl(0, "MsgArea", { bg = NONE })
      vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = NONE })

      -- winbar (top line)
      vim.api.nvim_set_hl(0, "WinBar", { bg = NONE })
      vim.api.nvim_set_hl(0, "WinBarNC", { bg = NONE })

      -- tabline / bufferline
      vim.api.nvim_set_hl(0, "TabLine", { bg = NONE })
      vim.api.nvim_set_hl(0, "TabLineFill", { bg = NONE })
      vim.api.nvim_set_hl(0, "TabLineSel", { bg = NONE, fg = "#e06c75", bold = true })
      vim.api.nvim_set_hl(0, "BufferLineBackground", { bg = NONE })
      vim.api.nvim_set_hl(0, "BufferLineBufferVisible", { bg = NONE })
      vim.api.nvim_set_hl(0, "BufferLineBufferSelected", { bg = NONE, bold = true })
      vim.api.nvim_set_hl(0, "BufferLineTab", { bg = NONE })
      vim.api.nvim_set_hl(0, "BufferLineTabSelected", { bg = NONE })
      vim.api.nvim_set_hl(0, "BufferLineSeparator", { bg = NONE, fg = "#5c6370" })
      vim.api.nvim_set_hl(0, "BufferLineFill", { bg = NONE })

      -- statusline
      vim.api.nvim_set_hl(0, "StatusLine", { bg = NONE })
      vim.api.nvim_set_hl(0, "StatusLineNC", { bg = NONE })
    end,
  }),
}

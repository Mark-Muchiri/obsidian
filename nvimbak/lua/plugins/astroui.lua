-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "olimorris/onedarkpro.nvim",
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    colorscheme = "onedark_vivid",
    -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
    highlights = {
      init = { -- this table overrides highlights in all themes
        -- Normal = { bg = "NONE" },
      },
      astrodark = { -- a table of overrides/changes when applying the astrotheme theme
        -- Normal = { bg = "#000000" },
      },
    },

    -- Icons can be configured throughout the interface
    icons = {
      -- configure the loading of the lsp in the status line
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
    -- Transparency
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = function()
        -- local NONE = "NONE"
        local dark_purple = "#595959" -- 35% darker version
        local darker_purple = "#333333" -- 20% darker version

        -- Core text areas
        vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "MsgArea", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "Pmenu", { bg = "NONE" })

        -- Line numbers and gutter
        vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE", fg = darker_purple })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "FoldColumn", { bg = "NONE" })

        -- Window borders and separators
        vim.api.nvim_set_hl(0, "VertSplit", { bg = "NONE", fg = "#5c6370" })
        vim.api.nvim_set_hl(0, "WinSeparator", { bg = "NONE", fg = "#5c6370" })
        vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE", fg = "#5c6370" })
        vim.api.nvim_set_hl(0, "WinBar", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "WinBarNC", { bg = "NONE" })

        -- Tabline and buffers
        vim.api.nvim_set_hl(0, "TabLine", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "TabLineSel", {
          bg = "NONE",
          fg = "#5a5a5a",
          bold = true,
          underline = true, -- Add subtle underline
          sp = "#6a6a6a", -- Underline color
          italic = true,
        })
        vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "BufferLineBackground", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "BufferLineBufferVisible", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "BufferLineBufferSelected", { bg = "NONE", bold = true })
        vim.api.nvim_set_hl(0, "BufferLineSeparator", { bg = "NONE", fg = "#5c6370" })
        vim.api.nvim_set_hl(0, "BufferLineFill", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "BufferLineTab", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "BufferLineTabSelected", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "BufferLineTabClose", { bg = "NONE" })

        -- File explorers (NeoTree/NvimTree/Netrw)
        vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "NeoTreeFloatBorder", { bg = "NONE", fg = "#5c6370" })
        vim.api.nvim_set_hl(0, "NeoTreeTitleBar", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "NeoTreeRootName", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "NeoTreeVertSplit", { bg = "NONE", fg = "#5c6370" })
        vim.api.nvim_set_hl(0, "NeoTreeTabInactive", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "NeoTreeTabActive", { bg = "NONE", fg = "#8a8a8a" })
        vim.api.nvim_set_hl(0, "NeoTreeTabSeparatorInactive", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "NeoTreeTabSeparatorActive", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { bg = "NONE", fg = "#5c6370", bold = false })
        vim.api.nvim_set_hl(0, "netrwDir", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "netrwClassify", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "netrwTreeBar", { bg = "NONE" })

        -- Darker NeoTree text colors
        vim.api.nvim_set_hl(0, "NeoTreeDirectoryName", { fg = "#3a56a0" }) -- Darker blue for folders
        vim.api.nvim_set_hl(0, "NeoTreeFileName", { fg = "#5a6c84" }) -- Darker gray for files
        vim.api.nvim_set_hl(0, "NeoTreeRootName", { fg = "#5a67d8", italic = true }) -- Darker purple for root

        -- Optional: Darker icons and special items
        vim.api.nvim_set_hl(0, "NeoTreeGitAdded", { fg = "#38a169" }) -- Darker green
        vim.api.nvim_set_hl(0, "NeoTreeGitModified", { fg = "#d69e2e" }) -- Darker yellow
        vim.api.nvim_set_hl(0, "NeoTreeGitDeleted", { fg = "#e53e3e" }) -- Darker red
        vim.api.nvim_set_hl(0, "NeoTreeFileIcon", { fg = "#5a6c84" }) -- File icons

        -- For a subtle hover effect:
        vim.api.nvim_set_hl(0, "NeoTreeCursorLine", { bg = "#1a202c" })

        -- Status line
        vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })

        -- Telescope
        vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "NONE", fg = "#5c6370" })

        -- WhichKey
        vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "NONE" })

        -- Cursor line highlighting
        vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "NONE", fg = dark_purple, bold = true })
        vim.api.nvim_set_hl(0, "CursorLineSign", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "CursorLineFold", { bg = "NONE" })

        -- Set minimal gutter padding
        vim.opt.numberwidth = 1 -- Minimal width for number column
        vim.opt.signcolumn = "yes" --"no"   -- Disable sign column if not needed
        vim.opt.foldcolumn = "0" -- Disable fold column

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

        -- winbar (top line)
        -- Make WinBar match cursor line colors
        vim.api.nvim_set_hl(0, "WinBar", {
          bg = "NONE",
          fg = "#4d4d4d",
          bold = true,
        })
        vim.api.nvim_set_hl(0, "WinBarNC", { bg = "NONE" })

        -- statusline
        vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })
      end,
    }),
  },
}

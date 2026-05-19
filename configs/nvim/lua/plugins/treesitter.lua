-- lua/plugins/treesitter.lua
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    -- Use pre-built parser binaries (no compiler or tree-sitter CLI needed)
    require("nvim-treesitter.install").prefer_git = true

    require("nvim-treesitter.configs").setup {
      -- Ensure markdown parsers are installed
      ensure_installed = {
        "markdown",
        "markdown_inline",
      },
      -- Basic options; add more as needed
      highlight = { enable = true },
      indent = { enable = true },
    }
  end,
}

return {
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
      require("onedark").setup({
        style = "deep",
        styles = {
          comments = "italic",
          functions = "NONE",
        },
        options = {
          transparency = true,
        },
      })
      -- Enable theme
      require("onedark").load()
    end,
  },
}

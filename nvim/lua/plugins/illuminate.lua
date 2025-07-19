return {
  {
    "RRethy/vim-illuminate",
    opts = {
      delay = 0,
      under_cursor = false, -- Disable highlight under cursor
      min_count_to_highlight = 10000, -- Set impossibly high
    },
    config = function(_, opts)
      require("illuminate").configure(opts)
      vim.cmd("hi! link IlluminatedWordText Normal")
    end,
  },
}

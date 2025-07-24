return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        -- first key is the mode
        n = {
          -- second key is the lefthand side of the map
          -- mappings seen under group name "Buffer"

          -- floating Neotree
          ["\\"] = { desc = "floating neotree", "<cmd>Neotree float toggle<cr>" },

          -- Find files
          ["<Leader><Leader>"] = {
            function()
              require("snacks").picker.files {
                hidden = vim.tbl_get((vim.uv or vim.loop).fs_stat ".git" or {}, "type") == "directory",
              }
            end,
            desc = "find files",
          },

          -- Choose buffer to close
          ["<Leader>bD"] = {
            function()
              require("astroui.status").heirline.buffer_picker(
                function(bufnr) require("astrocore.buffer").close(bufnr) end
              )
            end,
            desc = "Pick to close",
          },

          -- tables with just a `desc` key will be registered with which-key if it's installed
          -- this is useful for naming menus
          ["<Leader>b"] = { desc = "Buffers" },

          -- quik save
          ["<C-s>"] = { desc = "Save File", "<cmd>:w!<cr>" },

          -- Floating terminal
          ["<C-/>"] = { desc = "floating terminal", "<cmd>ToggleTerm direction=float<cr>" },
        },

        t = {
          -- Floating terminal
          ["<C-/>"] = { desc = "floating terminal", "<cmd>ToggleTerm<cr>" },
        },

        i = {
          -- quick save
          ["<C-s>"] = { desc = "Save File", "<cmd>:w!<cr>" },

          -- setting a mapping to false will disable it
          -- ["<esc>"] = false,
        },
      },
    },
  },
}

-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    -- Clear backgrounds for common groups
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
    -- Add more groups as needed
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "onedark",
  callback = function()
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    -- Clear illuminate highlights
    vim.cmd([[
      hi! IlluminatedWordText guibg=NONE gui=NONE
      hi! IlluminatedWordRead guibg=NONE gui=NONE
      hi! IlluminatedWordWrite guibg=NONE gui=NONE
    ]])

    -- Clear LSP document highlight
    vim.cmd("hi! LspReferenceText guibg=NONE gui=NONE")
    vim.cmd("hi! LspReferenceRead guibg=NONE gui=NONE")
    vim.cmd("hi! LspReferenceWrite guibg=NONE gui=NONE")
  end,
})

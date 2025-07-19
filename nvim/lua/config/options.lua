-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.transparent_enabled = true
vim.opt.relativenumber = false -- Disable relative numbers
vim.opt.number = true -- Keep absolute line numbers
vim.opt.wrap = true -- Enable soft word wrapping
vim.opt.linebreak = true -- Wrap at word boundaries
vim.opt.breakindent = true -- Maintain indentation in wrapped lines
-- Optional: Add visual marker for wrapped lines
vim.opt.showbreak = "↳ " -- Customize as desired

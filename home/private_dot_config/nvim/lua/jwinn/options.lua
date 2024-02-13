vim.opt.guicursor = "" -- keep insert cursor "large"

vim.opt.number = true -- print line nubers
vim.opt.relativenumber = true -- use relative line numbers

vim.opt.tabstop = 2 -- number of spaces a tab counts as
vim.opt.softtabstop = 2 -- number of spaces for a tab in insert mode
vim.opt.shiftwidth = 2 -- size of an indent
vim.opt.expandtab = true -- use spaces, instead of tabs
vim.opt.smartindent = true -- smart autoindent on new line
vim.opt.wrap = false -- disable line wrap

-- "optimize" for undotree usage
vim.opt.swapfile = false -- no ~ affixed files
vim.opt.backup = false -- no backup files
vim.opt.undofile = false -- undo file name

vim.opt.hlsearch = false -- do not hightlight search

vim.opt.termguicolors = true -- true color support

-- keep n lines visible, from cursor, horizontally
vim.opt.sidescrolloff = 4
-- keep n lines visible, from cursor, vertically
vim.opt.scrolloff = 4
vim.opt.signcolumn = "yes" -- always show the sign column
vim.opt.isfname:append("@-@") -- file name format

-- save swap file, if nothing typed in ms, and trigger CursorHold
vim.opt.updatetime = 50

-- columns are highlighted with ColorColumn
vim.opt.colorcolumn = { "80", "120" }

vim.g.mapleader = " " -- map the <Leader> to <Space>

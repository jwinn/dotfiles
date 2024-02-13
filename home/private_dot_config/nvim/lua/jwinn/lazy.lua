-- uninstalling: https://github.com/folke/lazy.nvim#-uninstalling

-- bootstrap lazy.nvim: https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration
local lazyconfig = {}

-- https://github.com/folke/lazy.nvim#%EF%B8%8F-importing-specs-config--opts
local lazyspec = {
  spec = {
    { import = "jwinn.plugins" },
    { import = "jwinn.plugins.colors" },
    { import = "jwinn.plugins.lsp" },
    { import = "jwinn.plugins.treesitter" },
  }
}

require("lazy").setup(lazyspec, lazyconfig)

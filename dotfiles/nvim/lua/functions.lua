-- functions.lua

local JW = {}

-- currently, autocommands, in neovim, don't have a Lua interface
-- https://github.com/neovim/neovim/pull/12378
function JW.create_augroup(autocmds, name)
  vim.cmd('augroup ' .. name)
  vim.cmd('autocmd!')
  for _, autocmd in ipairs(autocmds) do
    vim.cmd('autocmd ' .. table.concat(autocmd, ' '))
  end
  vim.cmd('augroup END')
end

return JW

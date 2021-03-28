local fn = require('functions')

local o = vim.o
local wo = vim.wo
local bo = vim.bo

local indent = 2
local width = 80

-- global options
o.encoding = 'utf-8'
-- o.fillchars = 'vert: ,fold:  listchars=tab:⎸ ,nbsp:⎕'
o.hidden = true
-- o.hlsearch = true
-- o.incsearch = true
o.ignorecase = true
-- o.laststatus = 2
o.listchars = 'tab:│ ,nbsp:␣,trail:·,extends:>,precedes:<'
o.mouse = 'a'
o.pastetoggle = '<F2>'
o.scrolloff = 5 -- default 0
o.showbreak = '↪ '
o.smartcase = true
-- o.smarttab = true
o.timeoutlen = 2000 -- default 1000
o.ttimeoutlen = 100 -- default -1
o.title = true
-- o.wildmenu = true

-- local window options
wo.breakindent = true
wo.breakindentopt = 'shift:-' .. width
wo.conceallevel = 2
wo.cursorline = false
wo.foldenable = false
wo.linebreak = true
wo.number = true

-- local buffer options
bo.expandtab = true
bo.formatoptions = 'cqnj' -- default 'tcqj'
bo.shiftwidth = indent
bo.softtabstop = indent
bo.tabstop = indent

-- move selection up (K) or down (J)
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")

-- may be needed if, in insert mode, there's a delay typing a space
-- see: https://neovim.io/doc/user/options.html#%27timeoutlen%27
--vim.keymap.set("n", "<Space>", "<Nop>", { silent = true })

-- <Leader>,p,v to open netrw
vim.keymap.set("n", "<Leader>pv", vim.cmd.Ex)

-- keep cursor in place when joining line(s)
vim.keymap.set("n", "J", "mzJ`z")

-- keep cursor in middle when half-page jumping
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- keep cursor in middle when cycling search matches
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- <Leader>,p to keep original paste buffer when replacing a selection
-- basically deletes the highlighted text into the void register and
-- preserves the current paste register
vim.keymap.set("x", "<Leader>p", [["_dP]])

-- <Leader>,y to yank to the + register, i.e. system clipboard
vim.keymap.set({ "n", "v" }, "<Leader>y", [["+y]])
vim.keymap.set("n", "<Leader>Y", [["+Y]])

-- <Leader>,d to delete to void register
vim.keymap.set({ "n", "v" }, "<Leader>d", [["_d]])

-- <Ctrl>+c to <Esc> when in insert mode
-- in vertical edit mode, <Ctrl>+c does not exit, only <Esc> does
vim.keymap.set("i", "<C-c>", "<Esc>")

-- do not repeat the last recorded resiter n times
vim.keymap.set("n", "Q", "<Nop>")

-- <Ctrl>+F to switch to another tmux session
-- Note: tmux <Ctrl>+a,l to return
vim.keymap.set("n", "<C-F>", "<Cmd>silent !tmux neww tmux-sessionizer<CR>")

-- Quickfix list navigation
vim.keymap.set("n", "<C-k>", "<Cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<Cmd>cprev<CR>zz")
vim.keymap.set("n", "<Leader>k", "<Cmd>lnext<CR>zz")
vim.keymap.set("n", "<Leader>j", "<Cmd>lprev<CR>zz")

-- <Leader>,s to prompt for replacement of word the cursor is on
vim.keymap.set("n", "<Leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- <Leader>,c,x to make the current file executable
vim.keymap.set("n", "<Leader>cx", "<Cmd>!chmod +x %<CR>", { silent = true })

-- <Leader><Leader> to source %
vim.keymap.set("n", "<Leader><Leader>", function() vim.cmd([[so]]) end)

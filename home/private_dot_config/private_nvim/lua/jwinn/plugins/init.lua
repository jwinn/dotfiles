return {
  -- allow lazy to manage itself
  {
     "folke/lazy.nvim",
     cmd = "Lazy",
     version = "*", 
     keys = {
        { "<Leader>l", "<Cmd>Lazy<CR>", desc = "Lazy" }
     },
  },
}

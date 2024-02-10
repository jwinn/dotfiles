return {
  "folke/trouble.nvim",
  --dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    {
      "<Leader>xx",
      "<Cmd>TroubleToggle<CR>",
      desc = "Trouble Toggle",
    },
    {
      "<Leader>xq",
      "<Cmd>TroubleToggle quickfix<CR>",
      desc = "Trouble Toggle QuickFix",
    },
    {
      "gR",
      "<Cmd>TroubleToggle lsp_references<CR>",
      desc = "Trouble Toggle LSP References",
    },
  },
  opts = {
    icons = false,
    fold_open = "v", -- icon used for open folds
    fold_closed = ">", -- icon used for closed folds
    indent_lines = false, -- add an indent guide below the fold icons
    signs = {
      -- icons / text used for a diagnostic
      error = "error",
      warning = "warn",
      hint = "hint",
      information = "info"
    },
    -- enabling this will use the signs defined in your lsp client
    use_diagnostic_signs = false
  },
}

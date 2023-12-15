return {
  "nvim-treesitter/playground",
  version = false, -- no releases
  --cmd = { "TSPlaygroundToggle" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  keys = {
    {
      "<Leader>tsp",
      "<Cmd>TSPlaygroundToggle<CR>",
      desc = "tree-sitter Toggle Playground"
    },
    {
      "<Leader>tshl",
      "<Cmd>TSHighlightCapturesUnderCursor<CR>",
      desc = "tree-sitter Highlight Groups Under Cursor"
    },
    {
      "<Leader>tsn",
      "<Cmd>TSNodeUnderCursor<CR>",
      desc = "tree-sitter Node Info Under Cursor"
    },
  },
  opt = {
    playground = {
      enable = true,
      disable = {},
      updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
      persist_queries = false, -- Whether the query persists across vim sessions
      keybindings = {
        toggle_query_editor = 'o',
        toggle_hl_groups = 'i',
        toggle_injected_languages = 't',
        toggle_anonymous_nodes = 'a',
        toggle_language_display = 'I',
        focus_language = 'f',
        unfocus_language = 'F',
        update = 'R',
        goto_node = '<cr>',
        show_help = '?',
      },
    },
    query_linter = {
      enable = true,
      use_virtual_text = true,
      lint_events = { "BufWrite", "CursorHold" },
    },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}

return {
  "catppuccin/nvim",
  name = "catppuccin.nvim",
  lazy = true,
  opts = {
    background = {
      dark = "mocha",
      light = "latte",
    },
    flavour = "mocha",
    integrations = {
      harpoon = true,
      lsp_trouble = true,
      mason = true,
      native_lsp = {
        enabled = true,
        virtual_text = {
          errors = { "italic" },
          hints = { "italic" },
          warnings = { "italic" },
          information = { "italic" },
        },
        underlines = {
          errors = { "underline" },
          hints = { "underline" },
          warnings = { "underline" },
          information = { "underline" },
        },
        inlay_hints = {
          background = true,
        },
      },
      neotree = true,
      treesitter = true,
      treesitter_context = true,
      which_key = true,
    },
    transparent_background = true,
  },
  ---@param opts TSConfig
  config = function(_, opts)
    require('catppuccin').setup(opts)
  end,
}

return {
  "folke/tokyonight.nvim",
  lazy = true,
  opts = {
    day_brightness = 0.9, -- default: 0.3
    sidebars = { "qf", "vista_kind", "terminal" }, -- default: "qf", "vista_kind"
    --style = "moon", -- default: night
    styles = {
      floats = "transparent", -- default: "dark"
      sidebars = "transparent", -- default: "dark"
    },
    terminal_colors = false, -- default: true
    transparent = true, -- default: false

    ---@param colors ColorScheme
    on_colors = function(colors)
      colors.hint = colors.orange
      colors.error = "#ff0000"
    end,

    ---@param highlights Highlights
    ---@param colors ColorScheme
    on_highlights = function(highlights, colors)
      local prompt = "#2d3149"
      highlights.TelescopeNormal = {
        bg = colors.bg_dark,
        fg = colors.fg_dark,
      }
      highlights.TelescopeBorder = {
        bg = colors.bg_dark,
        fg = colors.bg_dark,
      }
      highlights.TelescopePromptNormal = {
        bg = prompt,
      }
      highlights.TelescopePromptBorder = {
        bg = prompt,
        fg = prompt,
      }
      highlights.TelescopePromptTitle = {
        bg = prompt,
        fg = prompt,
      }
      highlights.TelescopePreviewTitle = {
        bg = colors.bg_dark,
        fg = colors.bg_dark,
      }
      highlights.TelescopeResultsTitle = {
        bg = colors.bg_dark,
        fg = colors.bg_dark,
      }
    end,
  },
}

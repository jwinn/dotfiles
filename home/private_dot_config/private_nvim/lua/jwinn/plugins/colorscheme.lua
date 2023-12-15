-- TODO: move into separate module
---@param color? string: the color scheme to use
function change_color_scheme(color)
  color = color or "tokyonight"

  vim.cmd.colorscheme(color)

  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end
vim.keymap.set("n", "<Leader>cs", change_color_scheme, { desc = "Default Color Scheme" })
vim.keymap.set("n", "<Leader>ccs", function()
  local color = vim.fn.input("Color Scheme: ")
  color = vim.fn.trim(color)
  if (string.len(color) == 0) then
    color = nil
  end
  change_color_scheme(color)
end, { desc = "Change Color Scheme" })

return {
  "folke/tokyonight.nvim",
  -- if this is the main colorscheme, ensure loading during startup
  lazy = false,
  -- load this before all other scripts
  priority = 1000,
  opts = {
    day_brightness = 0.9, -- default: 0.3
    sidebars = { "qf", "vista_kind", "terminal" }, -- default: "qf", "vista_kind"
    style = "moon", -- default: storm
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
  config = function()
    -- load the colorscheme here
    vim.cmd([[colorscheme tokyonight]])
  end,
}

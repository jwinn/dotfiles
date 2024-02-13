---@param color? string: the color scheme to use
local function change_color_scheme(color)
  color = color or "jellybeans-nvim"

  vim.cmd.colorscheme(color)

  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end
vim.keymap.set("n", "<Leader>cs", change_color_scheme,
  { desc = "Default Color Scheme" })
vim.keymap.set("n", "<Leader>ccs", function()
  local color = vim.fn.input({
    prompt = "Color Scheme: ",
    completion = "color",
  })

  color = vim.fn.trim(color)

  if (string.len(color) == 0) then
    color = nil
  end

  change_color_scheme(color)
end, { desc = "Change Color Scheme" })

return {
  {
    "rktjmp/lush.nvim",
    lazy = true,
    keys = {
      { "<Leader>clt", "<Cmd>LushRunTutorial<CR>",
        desc = "Run Lush Tutorial" },
    },
  },
  {
    --"nanotech/jellybeans.vim",
    "metalelf0/jellybeans-nvim",
    -- this is the main colorscheme--ensure loading during startup
    lazy = false,
    -- load this before all other scripts
    priority = 1000,
    dependencies = {
      { "rktjmp/lush.nvim" },
    },
    config = function()
      -- load the colorscheme here
      change_color_scheme()
    end,
  },
}

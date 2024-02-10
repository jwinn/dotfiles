return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  branch = "0.1.x",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<Leader>pf", "<Cmd>Telescope find_files<CR>", desc = "Find Files" },
    { "<Leader>pg", "<Cmd>Telescope live_grep<CR>", desc = "Search in Files" },
    { "<Leader>pb", "<Cmd>Telescope buffers<CR>", desc = "Find Buffers" },
    { "<Leader>pc", "<Cmd>Telescope commands<CR>", desc = "Find Commands" },
    { "<Leader>pk", "<Cmd>Telescope keymaps<CR>", desc = "Find Keymaps" },
    { "<C-p>", "<Cmd>Telescope git_files<CR>", desc = "Find Git Files" },
    {
      "<Leader>ps",
      function()
        require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") })
      end,
      desc = "Search Files"
    },
    { "<Leader>vh", "<Cmd>Telescope help_tags<CR>", desc = "Find HelpTags" },
  },
  opts = {

    defaults = {
      -- Default configuration for telescope goes here:
      -- config_key = value,
      mappings = {
        i = {
          -- map actions.which_key to <C-h> (default: <C-/>)
          -- actions.which_key shows the mappings for your picker,
          -- e.g. git_{create, delete, ...}_branch for the git_branches picker
          ["<C-h>"] = "which_key",
        },
      }
    },
    pickers = {
      -- Default configuration for builtin pickers goes here:
      -- picker_name = {
      --   picker_config_key = value,
      --   ...
      -- }
      -- Now the picker_config_key will be applied every time you call this
      -- builtin picker
    },
    extensions = {
      -- Your extension configuration goes here:
      -- extension_name = {
      --   extension_config_key = value,
      -- }
      -- please take a look at the readme of the extension you want to configure
    }
  },
}

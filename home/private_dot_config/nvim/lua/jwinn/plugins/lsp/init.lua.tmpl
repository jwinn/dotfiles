return {
  -- Zero
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v2.x",
    lazy = true,
    keys = {
      { "<Leader>f", vim.lsp.buf.format, desc = "LSP Format Current Buffer" }
    },
    config = function()

      -- This is where you modify the settings for lsp-zero
      -- Note: autocompletion settings will not take effect

      require("lsp-zero.settings").preset("recommended")
    end
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      { "VonHeikemen/lsp-zero.nvim" },
      { "L3MON4D3/LuaSnip" },
    },
    config = function()
      -- Here is where you configure the autocompletion settings.
      -- The arguments for .extend() have the same shape as `manage_nvim_cmp`: 
      -- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#manage_nvim_cmp

      require("lsp-zero.cmp").extend()

      -- And you can configure cmp even more, if you want to.
      local cmp = require("cmp")
      local cmp_action = require("lsp-zero.cmp").action() 

      cmp.setup({
        mapping = {
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-f>"] = cmp_action.luasnip_jump_forward(),
          ["<C-b>"] = cmp_action.luasnip_jump_backward(),
        }
      })
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    cmd = "LspInfo",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = lsp_config_deps,
    dependencies = {
      { "VonHeikemen/lsp-zero.nvim" },
      { "hrsh7th/cmp-nvim-lsp"},
      { "williamboman/mason-lspconfig.nvim" },
      { "williamboman/mason.nvim" },
    },
    config = function()
      -- This is where all the LSP shenanigans will live

      local lsp = require("lsp-zero")

      -- function(client, bufnr)
      lsp.on_attach(function(_, bufnr)
        -- see :help lsp-zero-keybindings
        -- to learn the available actions
        lsp.default_keymaps({ buffer = bufnr })

        local opts = { buffer = bufnr, remap = false }
        vim.keymap.set("n", "<Leader>vca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<Leader>vrr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<Leader>vrn", vim.lsp.buf.rename, opts)
        vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
      end)

      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "rust_analyzer",
          -- TODO: check from $(command -v npm)
          --"tsserver",
        },
      })

      -- (Optional) Configure lua language server for neovim
      require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())

      lsp.setup()
    end
  },
}

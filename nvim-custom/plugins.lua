local overrides = require("custom.configs.overrides")

return {
  {
    "rmagatti/goto-preview",
    config = function()
      require("goto-preview").setup({})
    end,
  },

  { "wakatime/vim-wakatime",   lazy = false },

  {
    "hrsh7th/nvim-cmp",
    opts = {
      sources = {
        -- trigger_characters is for unocss lsp
        { name = "nvim_lsp", trigger_characters = { "-" } },
        -- { name = "luasnip" },
        { name = "buffer" },
        { name = "nvim_lua" },
        { name = "path" },
      },
    },
  },

  {
    "zbirenbaum/copilot.lua",
    event = { "InsertEnter" },
    cmd = { "Copilot" },
    opts = {
      suggestion = {
        auto_trigger = true,
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require("plugins.configs.lspconfig")
      require("custom.configs.lspconfig")
    end,
  },

  {
    "stevearc/conform.nvim",
    --  for users those who want auto-save conform + lazyloading!
    event = "BufWritePre",
    config = function()
      require("custom.configs.conform")
    end,
  },

  -- override default configs
  { "nvim-tree/nvim-tree.lua", opts = overrides.nvimtree },
  { "williamboman/mason.nvim", opts = overrides.mason },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,

    config = function(_, opts)
      dofile(vim.g.base46_cache .. "syntax")
      require("nvim-treesitter.configs").setup(opts)

      -- register mdx ft
      vim.filetype.add({
        extension = { mdx = "mdx" },
      })

      vim.treesitter.language.register("markdown", "mdx")
    end,
  },

  --------------------------------------------- custom plugins ----------------------------------------------

  -- autoclose tags in html, jsx only
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },

  -- get highlight group under cursor
  {
    "nvim-treesitter/playground",
    cmd = "TSCaptureUnderCursor",
    config = function()
      require("nvim-treesitter.configs").setup()
    end,
  },

  -- dim inactive windows
  {
    "andreadev-it/shade.nvim",
    keys = "<Bslash>",
    config = function()
      require("shade").setup({
        exclude_filetypes = { "NvimTree" },
      })
    end,
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    config = function()
      require("trouble").setup()
    end,
  },

  -- distraction free mode
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    config = function()
      require("custom.configs.zenmode")
    end,
  },
}

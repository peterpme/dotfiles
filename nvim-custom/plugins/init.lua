return {
   ["jose-elias-alvarez/null-ls.nvim"] = {
      after = "nvim-lspconfig",
      config = function()
         require("custom.plugins.null-ls").setup()
      end,
   },
   ["windwp/nvim-ts-autotag"] = {
      ft = { "html", "javascriptreact" },
      after = "nvim-treesitter",
      config = function()
         require("nvim-ts-autotag").setup()
      end,
   },
   ["goolord/alpha-nvim"] = {
      disable = false,
   },
   -- ["github/copilot.vim"] = {},
   ["nathom/filetype.nvim"] = {},
   ["nkrkv/nvim-treesitter-rescript"] = {},
   ["rescript-lang/vim-rescript"] = { ft = "rescript" },
}

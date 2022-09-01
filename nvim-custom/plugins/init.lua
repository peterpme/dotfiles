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

   ["williamboman/mason.nvim"] = {
      ensure_installed = {
        -- lua stuff
        "lua-language-server",
        "stylua",

        -- web dev
        "css-lsp",
        "deno",
        "eslint_d",
        "graphql-language-service-cli",
        "html-lsp",
        "json-lsp",
        "markdownlint",
        "prettierd",
        "reason-language-server",
        "tailwindcss-language-server",
        "typescript-language-server",
        "yaml-language-server",

        -- shell
        "shfmt",
        "shellcheck",
      },
    },
}

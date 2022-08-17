local M = {}

local override = require "custom.plugins.override"
local userPlugins = require "custom.plugins"

M.plugins = {
   options = {
      lspconfig = {
         setup_lspconf = "custom.plugins.lspconfig",
      },

      statusline = {
         separator_style = "round",
      },
   },

   status = {
      colorizer = true,
   },

   override = {
      ["kyazdani42/nvim-tree.lua"] = override.nvimtree,
      ["nvim-treesitter/nvim-treesitter"] = override.treesitter,
      ["goolord/alpha-nvim"] = override.alpha,
   },

   user = userPlugins,
}

M.ui = {
   theme = "nightowl",
}

return M

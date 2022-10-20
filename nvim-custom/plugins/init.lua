local overrides = require("custom.plugins.overrides")

return {
  -- https://github.com/folke/which-key.nvim
	["folke/which-key.nvim"] = {
		disable = false,
	},

	-- Dashboard. If not working, run :PackerSync
	["goolord/alpha-nvim"] = {
		disable = false,
		cmd = "Alpha",
		override_options = overrides.alpha,
	},

	["nvim-treesitter/nvim-treesitter"] = {
		override_options = overrides.treesitter,
	},

	["williamboman/mason.nvim"] = {
		override_options = overrides.mason,
	},

	["kyazdani42/nvim-tree.lua"] = {
		override_options = overrides.nvimtree,
	},

	-- Indent Guides
	-- https://github.com/lukas-reineke/indent-blankline.nvim
	["lukas-reineke/indent-blankline.nvim"] = {
		override_options = overrides.blankline,
	},

	["neovim/nvim-lspconfig"] = {
		config = function()
			require("plugins.configs.lspconfig")
			require("custom.plugins.lspconfig")
		end,
	},

	-- Format & Lint
	-- https://github.com/jose-elias-alvarez/null-ls.nvim
	["jose-elias-alvarez/null-ls.nvim"] = {
		after = "nvim-lspconfig",
		config = function()
			require("custom.plugins.null-ls")
		end,
	},

	-- autoclose tags in html, jsx only
	["windwp/nvim-ts-autotag"] = {
		ft = { "html", "javascriptreact" },
		after = "nvim-treesitter",
		config = function()
			local present, autotag = pcall(require, "nvim-ts-autotag")

			if present then
				autotag.setup()
			end
		end,
	},

	-- ["github/copilot.vim"] = {},
	-- ["nkrkv/nvim-treesitter-rescript"] = {},
	-- ["rescript-lang/vim-rescript"] = { ft = "rescript" },
}

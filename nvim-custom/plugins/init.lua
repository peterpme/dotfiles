local overrides = require("custom.plugins.overrides")

return {
	["goolord/alpha-nvim"] = overrides.alpha,

	["nvim-treesitter/nvim-treesitter"] = {
		override_options = overrides.treesitter,
	},

	["williamboman/mason.nvim"] = {
		override_options = overrides.mason,
	},

	["kyazdani42/nvim-tree.lua"] = {
		override_options = overrides.nvimtree,
	},

	-- code formatting, linting etc
	["jose-elias-alvarez/null-ls.nvim"] = {
		after = "nvim-lspconfig",
		config = function()
			require("custom.plugins.null-ls")
		end,
	},

	-- ["windwp/nvim-ts-autotag"] = {
	-- 	ft = { "html", "javascriptreact" },
	-- 	after = "nvim-treesitter",
	-- 	config = function()
	-- 		require("nvim-ts-autotag").setup()
	-- 	end,
	-- },
	-- -- ["github/copilot.vim"] = {},
	-- ["nathom/filetype.nvim"] = {},
	-- ["nkrkv/nvim-treesitter-rescript"] = {},
	-- ["rescript-lang/vim-rescript"] = { ft = "rescript" },
	--
}

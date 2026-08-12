return {
	-- blink.cmp (replaces nvim-cmp)
	{ import = "nvchad.blink.lazyspec" },

	-- copilot (load before blink so the client is ready)
	{
		"zbirenbaum/copilot.lua",
		lazy = false,
		cmd = "Copilot",
		opts = {
			suggestion = { enabled = false },
			panel = { enabled = false },
		},
	},

	-- copilot source for blink.cmp
	{
		"giuxtaposition/blink-cmp-copilot",
		lazy = false,
		dependencies = { "zbirenbaum/copilot.lua" },
	},

	-- blink.cmp overrides to add copilot source
	{
		"saghen/blink.cmp",
		version = "1.*",
		opts = {
			fuzzy = { prebuilt_binaries = { force_version = "v1.9.1" } },
			sources = {
				default = { "copilot" },
				providers = {
					copilot = {
						name = "copilot",
						module = "blink-cmp-copilot",
						score_offset = 100,
						async = true,
					},
				},
			},
		},
	},

	-- conform (formatting)
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		opts = require "configs.conform",
	},

	-- lspconfig
	{
		"neovim/nvim-lspconfig",
		config = function()
			require "configs.lspconfig"
		end,
	},

	-- treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"bash",
				"css",
				"html",
				"javascript",
				"json",
				"lua",
				"markdown",
				"scss",
				"solidity",
				"sql",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"yaml",
			},
		},
	},

	-- nvim-tree overrides
	{
		"nvim-tree/nvim-tree.lua",
		opts = {
			filters = {
				dotfiles = true,
				custom = { "node_modules" },
			},
			git = {
				enable = true,
				ignore = true,
			},
			renderer = {
				highlight_git = true,
				icons = {
					show = {
						git = true,
					},
				},
			},
		},
	},

	-- mason overrides
	{
		"williamboman/mason.nvim",
		opts = {
			ensure_installed = {
				"ruby-lsp",
				"lua-language-server",
				"stylua",
				"css-lsp",
				"html-lsp",
				"tailwindcss-language-server",
				"typescript-language-server",
				"eslint_d",
				"prettierd",
				"json-lsp",
				"markdownlint",
				"yaml-language-server",
				"graphql-language-service-cli",
				"shfmt",
				"shellcheck",
				"bash-language-server",
				"rust",
			},
		},
	},

	-- autoclose tags in html, jsx
	{
		"windwp/nvim-ts-autotag",
		event = "InsertEnter",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},

	-- goto-preview
	{
		"rmagatti/goto-preview",
		config = function()
			require("goto-preview").setup {}
		end,
	},

	-- trouble
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		config = function()
			require("trouble").setup()
		end,
	},

	-- zen mode
	{
		"folke/zen-mode.nvim",
		cmd = "ZenMode",
		config = function()
			require("zen-mode").setup()
		end,
	},

	-- context-aware jsx/tsx comments via treesitter
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		lazy = true,
		config = function()
			vim.g.skip_ts_context_commentstring_module = true
			require("ts_context_commentstring").setup({
				enable_autocmd = false,
				languages = {
					-- add jsx_self_closing_element (<Foo />) which is missing from defaults
					tsx = { jsx_self_closing_element = "{/* %s */}" },
					javascript = { jsx_self_closing_element = "{/* %s */}" },
				},
			})
		end,
	},

	-- wire ts-context-commentstring into mini.comment via pre hook
	{
		"echasnovski/mini.comment",
		opts = {
			hooks = {
				pre = function()
					require("ts_context_commentstring.internal").update_commentstring()
				end,
			},
		},
	},

	-- wakatime
	{ "wakatime/vim-wakatime", lazy = false },

	-- avante (AI assistant)
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		lazy = false,
		version = false,
		build = "make",
		dependencies = {
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			provider = "claude",
			providers = {
				claude = {
					model = "claude-sonnet-4-20250514",
					extra_request_body = {
						max_tokens = 4096,
					},
				},
			},
			behaviour = {
				auto_suggestions = false,
				auto_set_keymaps = true,
			},
			mappings = {
				ask = "<leader>aa",
				edit = "<leader>ae",
				refresh = "<leader>ar",
				toggle = {
					default = "<leader>at",
					debug = "<leader>ad",
					hint = "<leader>ah",
				},
			},
		},
	},
}

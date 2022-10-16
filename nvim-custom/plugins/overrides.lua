-- overriding default plugin configs!

local M = {}

M.mason = {
	ensure_installed = {
		-- lua
		"lua-language-server",
		"stylua",

		-- web
		"css-lsp",
		"html-lsp",
		"tailwindcss-language-server",

		-- js/ts
		"typescript-language-server",
		"eslint_d",
		"graphql-language-service-cli",
		"prettierd",

		-- misc
		"json-lsp",
		"deno",
		"markdownlint",
		"yaml-language-server",

		-- shell
		"shfmt",
		"shellcheck",
	},
}

M.treesitter = {
	ensure_installed = {
		"bash",
		"css",
		"dockerfile",
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
		-- "rescript",
		"yaml",
	},
	highlight = { -- Be sure to enable highlights if you haven't!
		enable = true,
	},
}

M.nvimtree = {
	git = {
		enable = true,
	},
	renderer = {
		highlight_git = true,
		icons = {
			show = {
				git = true,
			},
		},
	},
}

M.alpha = {
	header = {
		val = {
			"     █████                        ██████   █████    █████      ███   █████   ",
			"    ░░███                        ███░░███ ░░███    ░░███      ░░░   ░░███    ",
			"  ███████  ████████   ██████    ░███ ░░░  ███████   ░███████  ████  ███████  ",
			" ███░░███ ░░███░░███ ░░░░░███  ███████   ░░░███░    ░███░░███░░███ ░░░███░   ",
			"░███ ░███  ░███ ░░░   ███████ ░░░███░      ░███     ░███ ░███ ░███   ░███    ",
			"░███ ░███  ░███      ███░░███   ░███       ░███ ███ ░███ ░███ ░███   ░███ ███",
			"░░████████ █████    ░░████████  █████      ░░█████  ████████  █████  ░░█████ ",
			" ░░░░░░░░ ░░░░░      ░░░░░░░░  ░░░░░        ░░░░░  ░░░░░░░░  ░░░░░    ░░░░░  ",
		},
	},
}

return M

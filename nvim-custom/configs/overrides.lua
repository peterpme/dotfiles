local M = {}

-- Installation
-- :MasonInstallAll
M.mason = {
	ensure_installed = {
		-- ruby
		"ruby-lsp",
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
		"prettierd",
		-- "deno",

		-- misc
		"json-lsp",
		"markdownlint",
		"yaml-language-server",
		"graphql-language-service-cli",

		-- shell
		"shfmt",
		"shellcheck",
		"bash-language-server",

		-- rust
		"rust",
	},
}

M.treesitter = {
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
		"yaml",
	},
}

M.cmp = {
	sources = {
		-- trigger_characters is for unocss lsp
		-- { name = "nvim_lsp", trigger_characters = { "-" } },
		{ name = "path" },
		{ name = "luasnip" },
		{ name = "buffer" },
		-- { name = "codeium" },
		{ name = "nvim_lua" },
	},
	experimental = {
		ghost_text = true,
	},
}

M.nvimtree = {
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
}

return M

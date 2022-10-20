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

M.blankline = {
	filetype_exclude = {
		"help",
		"terminal",
		"alpha",
		"packer",
		"lspinfo",
		"TelescopePrompt",
		"TelescopeResults",
		"nvchad_cheatsheet",
		"lsp-installer",
		"norg",
		"",
	},
}

-- local function button(sc, txt, keybind)
-- 	local sc_ = sc:gsub("%s", ""):gsub("SPC", "<leader>")
--
-- 	local opts = {
-- 		position = "center",
-- 		text = txt,
-- 		shortcut = sc,
-- 		cursor = 5,
-- 		width = 36,
-- 		align_shortcut = "right",
-- 		hl = "AlphaButtons",
-- 	}
--
-- 	if keybind then
-- 		opts.keymap = { "n", sc_, keybind, { noremap = true, silent = true } }
-- 	end
--
-- 	return {
-- 		type = "button",
-- 		val = txt,
-- 		on_press = function()
-- 			local key = vim.api.nvim_replace_termcodes(sc_, true, false, true) or ""
-- 			vim.api.nvim_feedkeys(key, "normal", false)
-- 		end,
-- 		opts = opts,
-- 	}
-- end

M.alpha = {
	header = {
		val = {
			" █████                        █████                                   █████     ",
			"░░███                        ░░███                                   ░░███      ",
			" ░███████   ██████    ██████  ░███ █████ ████████   ██████    ██████  ░███ █████",
			" ░███░░███ ░░░░░███  ███░░███ ░███░░███ ░░███░░███ ░░░░░███  ███░░███ ░███░░███ ",
			" ░███ ░███  ███████ ░███ ░░░  ░██████░   ░███ ░███  ███████ ░███ ░░░  ░██████░  ",
			" ░███ ░███ ███░░███ ░███  ███ ░███░░███  ░███ ░███ ███░░███ ░███  ███ ░███░░███ ",
			" ████████ ░░████████░░██████  ████ █████ ░███████ ░░████████░░██████  ████ █████",
			"░░░░░░░░   ░░░░░░░░  ░░░░░░  ░░░░ ░░░░░  ░███░░░   ░░░░░░░░  ░░░░░░  ░░░░ ░░░░░ ",
			"                                         ░███                                   ",
			"                                         █████                                  ",
			"                                        ░░░░░",
		},
	},
	-- buttons = {
	-- 	val = {
	-- 		button("SPC f f", "  Find File  ", ":Telescope find_files<CR>"),
	-- 		button("SPC f o", "  Recent File  ", ":Telescope oldfiles<CR>"),
	-- 		button("SPC f w", "  Find Word  ", ":Telescope live_grep<CR>"),
	-- 		button("SPC b m", "  Bookmarks  ", ":Telescope marks<CR>"),
	-- 		button("SPC t h", "  Themes  ", ":Telescope themes<CR>"),
	-- 		button("SPC e s", "  Settings", ":e $MYVIMRC | :cd %:p:h <CR>"),
	-- 		button("SPC t k", "  Mappings", ":Telescope keymaps <CR>"),
	-- 		button("SPC c m", "  Git Commits", ":Telescope git_commits <CR>"),
	-- 		button("SPC g t", "  Git Status", ":Telescope git_status <CR>"),
	-- 	},
	-- },
}

return M

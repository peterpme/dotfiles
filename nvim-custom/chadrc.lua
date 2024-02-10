local M = {}

-- path for lazy.nvim
M.plugins = "custom.plugins"

-- Path to overriding theme and highlights files
local highlights = require("custom.highlights")

M.ui = {
	theme = "ashes",
	transparency = false,
	hl_override = highlights.override,
	hl_add = highlights.add,
	nvdash = {
		load_on_startup = true,
		header = {
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
}

M.mappings = require("custom.mappings")

return M

-- :MasonInstallAll

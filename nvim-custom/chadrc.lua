local M = {}

M.ui = {
	theme = "one_light",
	theme_toggle = { "one_light", "catppuccin" },
}

M.plugins = require("custom.plugins")
M.mappings = require("custom.mappings")

return M

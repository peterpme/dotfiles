local M = {}

M.ui = {
	theme = "catppuccin_latte",
	theme_toggle = { "catppuccin_latte", "catppuccin" },
}

M.plugins = require("custom.plugins")
M.mappings = require("custom.mappings")

return M

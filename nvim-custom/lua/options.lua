require "nvchad.options"

local opt = vim.opt
local cmd = vim.cmd

opt.title = true

cmd [[abbr funciton function]]
cmd [[abbr teh the]]
cmd [[abbr tempalte template]]
cmd [[abbr fitler filter]]
cmd [[abbr cosnt const]]
cmd [[abbr attribtue attribute]]
cmd [[abbr attribuet attribute]]
cmd [[abbr tamaguii tamagui]]
cmd [[abbr iimport import]]

opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.updatecount = 0

opt.backspace = { "indent", "eol,start" }

-- register mdx as markdown
vim.filetype.add { extension = { mdx = "mdx" } }
vim.treesitter.language.register("markdown", "mdx")

if vim.g.neovide then
	vim.g.neovide_refresh_rate = 75
	vim.g.neovide_cursor_vfx_mode = "railgun"
	vim.keymap.set("i", "<c-s-v>", "<c-r>+")
	vim.keymap.set("i", "<c-r>", "<c-s-v>")
end

-- https://github.com/siduck/dotfiles/tree/master/nvchad/custom
local opt = vim.opt
local cmd = vim.cmd

opt.title = true

cmd([[abbr funciton function]])
cmd([[abbr teh the]])
cmd([[abbr tempalte template]])
cmd([[abbr fitler filter]])
cmd([[abbr cosnt const]])
cmd([[abbr attribtue attribute]])
cmd([[abbr attribuet attribute]])
cmd([[abbr tamaguii tamagui]])
cmd([[abbr iimport import]])

opt.backup = false -- don't use backup files
opt.writebackup = false -- don't backup the file while editing
opt.swapfile = false -- don't create swap files for new buffers
opt.updatecount = 0 -- don't write swap files after some number of updates

opt.backspace = { "indent", "eol,start" } -- make backspace behave in a sane manner

if vim.g.neovide then
	vim.g.neovide_refresh_rate = 75

	vim.g.neovide_cursor_vfx_mode = "railgun"

	vim.keymap.set("i", "<c-s-v>", "<c-r>+")
	vim.keymap.set("i", "<c-r>", "<c-s-v>")
end

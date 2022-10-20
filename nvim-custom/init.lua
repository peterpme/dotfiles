-- https://github.com/siduck/dotfiles/tree/master/nvchad/custom
local opt = vim.opt
local cmd = vim.cmd

cmd([[abbr funciton function]])
cmd([[abbr teh the]])
cmd([[abbr tempalte template]])
cmd([[abbr fitler filter]])
cmd([[abbr cosnt const]])
cmd([[abbr attribtue attribute]])
cmd([[abbr attribuet attribute]])

opt.backup = false -- don't use backup files
opt.writebackup = false -- don't backup the file while editing
opt.swapfile = false -- don't create swap files for new buffers
opt.updatecount = 0 -- don't write swap files after some number of updates

opt.backspace = { "indent", "eol,start" } -- make backspace behave in a sane manner

-- Formatting used to timeout 
-- https://github.com/jose-elias-alvarez/null-ls.nvim#i-am-seeing-a-formatting-timeout-error-message
vim.lsp.buf.format({ timeout_ms = 5000 })

-- -- scroll the viewport faster
-- nnoremap("<C-e>", "3<c-e>")
-- nnoremap("<C-y>", "3<c-y>")
--
-- -- -- moving up and down work as you would expect
-- nnoremap("j", 'v:count == 0 ? "gj" : "j"', { expr = true })
-- nnoremap("k", 'v:count == 0 ? "gk" : "k"', { expr = true })
-- nnoremap("^", 'v:count == 0 ? "g^" :  "^"', { expr = true })
-- nnoremap("$", 'v:count == 0 ? "g$" : "$"', { expr = true })
--
-- -- custom text objects
-- -- inner-line
-- xmap("il", ":<c-u>normal! g_v^<cr>")
-- omap("il", ":<c-u>normal! g_v^<cr>")
-- -- around line
-- vmap("al", ":<c-u>normal! $v0<cr>")
-- omap("al", ":<c-u>normal! $v0<cr>")

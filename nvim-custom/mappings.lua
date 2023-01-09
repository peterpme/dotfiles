local M = {}

-- Github Copilot Bindings
-----------------------------------------------------------
-- M.copilot = {
-- 	mode_opts = { expr = true },
-- 	i = {
-- 		["<C-h>"] = { 'copilot#Accept("<Left>")', "   copilot accept" },
-- 	},
-- }

-- M.telescope = {
--   n = {
--     -- https://github.com/NvChad/NvChad/blob/main/lua/core/mappings.lua#L279
--     ["<leader>fw"] = { "<cmd> Telescope live_grep find_command=rg,--ignore,--hidden,--glob,!examples/<CR>", "live grep" },
--   }
-- }

M.lspconfig = {
	n = {
		["<leader>fe"] = { "<cmd> EslintFixAll <CR>", "eslint fix all" },
    -- BROKEN: fix this so that submatch works
		-- ["<leader>fq"] = { '<cmd> %s/\v"d+px"/=submatch(0)[1:-4]/ <CR>', "replace px to numbers" },
	},
}

return M

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
		["gpd"] = { "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", "goto-preview definition" },
		["gpt"] = {
			"<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>",
			"goto-preview type definition",
		},
		["gpi"] = {
			"<cmd>lua require('goto-preview').goto_preview_implementation()<CR>",
			"goto-preview implementation",
		},
		["gpD"] = { "<cmd>lua require('goto-preview').goto_preview_declaration()<CR>", "goto-preview declaration" },
		["gP"] = { "<cmd>lua require('goto-preview').close_all_win()<CR>", "close all preview windows" },
		["gpr"] = { "<cmd>lua require('goto-preview').goto_preview_references()<CR>", "goto-preview references" },
		-- BROKEN: fix this so that submatch works
		-- w
		-- ["<leader>fq"] = { '<cmd> %s/\v"d+px"/=submatch(0)[1:-4]/ <CR>', "replace px to numbers" },
	},
}

return M

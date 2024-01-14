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

-- function SearchFunctionScreen()
-- 	require("telescope.builtin").live_grep({
-- 		default_text = "function.*Screen",
-- 	})
-- end
--
-- function SearchFunctionScreen()
-- 	-- The Vim regex pattern for "function *Screen"
-- 	local pattern = "function.\\{-}Screen"
-- 	-- Call Vim's search function with the pattern
-- 	vim.fn.search(pattern)
-- end

function SearchFunctionScreen(word)
	local wordPattern = word and ".\\{-}" .. word or ""
	-- Add \c at the start of the pattern for case-insensitive search
	local pattern = "\\cfunction" .. wordPattern .. ".\\{-}Screen"
	vim.fn.search(pattern)
end

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
		["gS"] = { "<cmd>lua SearchFunctionScreen('')<CR>", "cycle through Screen functions" },
		["gs"] = { "<cmd>lua SearchFunctionScreen(vim.fn.input('Screen: '))<CR>", "cycle through Screen functions" },
	},
}

return M

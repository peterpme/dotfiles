local M = {}

function SearchFunctionScreen(word)
	local wordPattern = word and ".\\{-}" .. word or ""
	-- Add \c at the start of the pattern for case-insensitive search
	local pattern = "\\cfunction" .. wordPattern .. ".\\{-}Screen"
	vim.fn.search(pattern)
end

M.general = {
	n = {
		[";"] = { ":", "enter command mode", opts = { nowait = true } },
	},
	i = {
		["jk"] = { "<ESC>", "escape insert mode" },
	},
}

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

M.lsp = {
	n = {
		[";"] = { ":", "enter command mode", opts = { nowait = true } },
		--  format with conform
		-- ["<leader>fm"] = {
		-- 	function()
		-- 		require("conform").format()
		-- 	end,
		-- 	"formatting",
		-- },
	},
	v = {
		[">"] = { ">gv", "indent" },
	},
}

return M

require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode", nowait = true })
map("i", "jk", "<ESC>", { desc = "Escape insert mode" })

-- goto-preview
map("n", "gpd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", { desc = "Goto preview definition" })
map(
	"n",
	"gpt",
	"<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>",
	{ desc = "Goto preview type definition" }
)
map(
	"n",
	"gpi",
	"<cmd>lua require('goto-preview').goto_preview_implementation()<CR>",
	{ desc = "Goto preview implementation" }
)
map(
	"n",
	"gpD",
	"<cmd>lua require('goto-preview').goto_preview_declaration()<CR>",
	{ desc = "Goto preview declaration" }
)
map("n", "gP", "<cmd>lua require('goto-preview').close_all_win()<CR>", { desc = "Close all preview windows" })
map(
	"n",
	"gpr",
	"<cmd>lua require('goto-preview').goto_preview_references()<CR>",
	{ desc = "Goto preview references" }
)

-- diagnostics
map("n", "gl", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>lf", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- format with conform
map("n", "<leader>fm", function()
	require("conform").format()
end, { desc = "Format file" })

-- visual indent
map("v", ">", ">gv", { desc = "Indent and reselect" })

local formatters = {
	-- Initial setup for specific formatters
	-- css = { "stylelint", "prettierd" },
	sh = { "shellcheck", "shfmt" },
	lua = { "stylua" },
}

-- List of file types that will use "prettier" as their formatter
local prettierFileTypes = {
	"css",
	"javascript",
	"javascriptreact",
	"typescript",
	"typescriptreact",
	"json",
	"jsonc",
	"html",
	"yaml",
}

for _, fileType in ipairs(prettierFileTypes) do
	formatters[fileType] = { "prettierd" }
end

local options = {
	formatters = {
		prettierd = {
			require_cwd = true,
		},
	},

	formatters_by_ft = formatters,

	format_on_save = {
		-- These options will be passed to conform.format()
		timeout_ms = 500,
		lsp_format = "fallback",
	},
}

require("conform").setup(options)

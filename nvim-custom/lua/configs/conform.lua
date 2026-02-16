local formatters = {
	sh = { "shellcheck", "shfmt" },
	lua = { "stylua" },
}

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

return {
	formatters = {
		prettierd = {
			require_cwd = true,
		},
	},

	formatters_by_ft = formatters,

	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
}

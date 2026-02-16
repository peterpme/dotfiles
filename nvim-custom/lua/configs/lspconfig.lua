require("nvchad.configs.lspconfig").defaults()

local servers = {
	"vimls",
	"lua_ls",
	"eslint",
	"bashls",
	"html",
	"ts_ls",
	"jsonls",
	"cssls",
	"yamlls",
}

vim.lsp.enable(servers)

-- per-server settings
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim", "hs" },
			},
		},
	},
})

-- disable formatting for ts_ls (use prettierd via conform instead)
vim.lsp.config("ts_ls", {
	on_attach = function(client)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
})

-- diagnostics config: no virtual text, show signs and underline
vim.diagnostic.config {
	virtual_text = false,
	underline = true,
	signs = true,
	severity_sort = true,
	update_in_insert = false,
}

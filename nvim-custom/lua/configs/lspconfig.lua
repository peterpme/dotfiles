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

-- auto-fix eslint errors on save
vim.lsp.config("eslint", {
	settings = {
		useFlatConfig = true,
	},
	on_attach = function(client, bufnr)
		client.server_capabilities.diagnosticProvider = nil
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			callback = function()
				client:request_sync("workspace/executeCommand", {
					command = "eslint.applyAllFixes",
					arguments = {
						{
							uri = vim.uri_from_bufnr(bufnr),
							version = vim.lsp.util.buf_versions[bufnr],
						},
					},
				}, 3000, bufnr)
			end,
		})
	end,
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

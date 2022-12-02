local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
-- :help lspconfig-all
local servers = { "html", "cssls", "tsserver", "eslint", "jsonls", "tailwindcss" }
-- local servers = { "tsserver", "eslint" }
-- graphql, tailwindcss, cssls, html, jsonls

for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		on_attach = on_attach,
		capabilities = capabilities,
	})
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	virtual_text = false,
	underline = true,
	signs = true,
	severity_sort = true,
	update_in_insert = false,
})

local autocmd = vim.api.nvim_create_autocmd

autocmd("CursorHold", {
	callback = function()
		vim.diagnostic.open_float()
	end,
})

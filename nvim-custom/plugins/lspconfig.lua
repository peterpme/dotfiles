local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
-- :help lspconfig-all
-- local servers = { "html", "cssls", "tsserver", "eslint", "graphql", "jsonls", "tailwindcss" }
local servers = { "tsserver", "eslint" }
-- graphql, tailwindcss, cssls, html, jsonls

for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		on_attach = on_attach,
		capabilities = capabilities,
	})
end

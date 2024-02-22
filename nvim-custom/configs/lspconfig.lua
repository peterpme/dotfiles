local lspconfig = require("lspconfig")
local configs = require("plugins.configs.lspconfig")

-- Store the imported on_attach function for later use
local imported_on_attach = configs.on_attach
local capabilities = configs.capabilities

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
-- :help lspconfig-all
local servers = {
	"vimls",
	"lua_ls",
	"eslint",
	"bashls",
	"html",
	"tsserver",
	"jsonls",
	"cssls",
	-- "stylelint"
}

local function on_attach(client, bufnr)
	-- Disable document formatting for tsserver
	if client.name == "tsserver" then
		client.resolved_capabilities.document_formatting = false
	end

	-- Call the imported on_attach function to ensure any setup defined there is also executed
	if imported_on_attach then
		imported_on_attach(client, bufnr)
	end
end

for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		on_attach = on_attach,
		capabilities = capabilities,
	})
end

-- lspconfig for each
require("lspconfig").lua_ls.setup({
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim", "hs" },
			},
		},
	},
})

-- hide all the errors in the file
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	virtual_text = false,
	underline = true,
	signs = true,
	severity_sort = true,
	update_in_insert = false,
})

vim.diagnostic.config({
	virtual_text = false,
})

--
-- ruby / rails
-- https://github.com/Shopify/ruby-lsp-rails
-- https://shopify.github.io/ruby-lsp/ (gem install ruby-lsp)

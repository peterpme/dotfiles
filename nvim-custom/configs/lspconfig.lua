local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
-- :help lspconfig-all
local servers = {
	"vimls",
	"lua_ls",
	"html",
	"cssls",
	"tsserver",
	"jsonls",
}

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
				globals = { "vim", "h" },
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

-- vim.diagnostic.config({
-- 	virtual_text = false,
-- })

vim.cmd([[autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()]])
vim.cmd([[autocmd CursorHoldI * silent! lua vim.lsp.buf.signature_help()]])

-- ruby / rails
-- https://github.com/Shopify/ruby-lsp-rails
-- https://shopify.github.io/ruby-lsp/ (gem install ruby-lsp)

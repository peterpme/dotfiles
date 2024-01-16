local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")

-- ruby / rails
-- https://github.com/Shopify/ruby-lsp-rails
-- https://shopify.github.io/ruby-lsp/ (gem install ruby-lsp)

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
-- :help lspconfig-all
local servers = { "html", "cssls", "jsonls", "tailwindcss", "ruby_ls", "lua_ls" }
-- tsserver isn't in this list

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })
end

-- tsserver is down here
lspconfig.tsserver.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  -- root_dir = require("lspconfig.util").root_pattern(".git"),
})

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

-- local autocmd = vim.api.nvim_create_autocmd

-- autocmd("CursorHold", {
-- 	callback = function()
-- 		vim.diagnostic.open_float()
-- 	end,
-- })

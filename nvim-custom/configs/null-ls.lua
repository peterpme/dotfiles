local null_ls = require("null-ls")

local format = null_ls.builtins.formatting
local lint = null_ls.builtins.diagnostics

local sources = {
	-- Rescript/Reason
	-- format.rescript,

	-- Github Action Workflows
	lint.actionlint,

	-- Javascript / Typescript
	-- format.deno_fmt,
	lint.tsc,
	format.prettierd,

	-- b.code_actions.eslint_d,
	lint.eslint_d,
	format.eslint_d,

	-- https://github.com/jshint/jshint
	-- lint.jshint,

	-- lint.yamllint, python package only, meh
	-- lint.jsonlint,
	-- lint.markdownlint,

	-- Lua
	format.stylua,

	-- Shell
	format.shfmt,
	lint.shellcheck.with({ diagnostics_format = "#{m} [#{c}]" }),
	lint.zsh,

	-- harden shell scripts
	-- https://github.com/anordal/shellharden too lazy to install
	-- format.shellharden,

	-- SQL / Postgres
	-- https://github.com/darold/pgFormatter too lazy to install via curl
	-- format.pg_format,
}

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup({
	debug = true,
	sources = sources,
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({ async = true })
				end,
			})
		end
	end,
})

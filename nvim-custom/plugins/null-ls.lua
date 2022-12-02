local present, null_ls = pcall(require, "null-ls")

if not present then
	return
end

local b = null_ls.builtins

local sources = {
	-- Rescript/Reason
	-- b.formatting.rescript,

	-- Github Action Workflows
	b.diagnostics.actionlint,

	-- Javascript / Typescript
	-- b.diagnostics.tsc,
	b.formatting.prettierd,

	-- b.code_actions.eslint_d,
	-- b.diagnostics.eslint_d,
	b.formatting.eslint_d,

	-- https://github.com/jshint/jshint
	-- b.diagnostics.jshint,

	-- b.diagnostics.yamllint, python package only, meh
	b.diagnostics.jsonlint,
	b.diagnostics.markdownlint,

	-- Lua
	b.formatting.stylua,

	-- Shell
	b.formatting.shfmt,
	b.diagnostics.shellcheck.with({ diagnostics_format = "#{m} [#{c}]" }),
	b.diagnostics.zsh,

	-- harden shell scripts
	-- https://github.com/anordal/shellharden too lazy to install
	-- b.formatting.shellharden,

	-- SQL / Postgres
	-- https://github.com/darold/pgFormatter too lazy to install via curl
	-- b.formatting.pg_format,
}

null_ls.setup({
	debug = true,
	sources = sources,
	on_attach = function()
		vim.api.nvim_create_autocmd("BufWritePost", {
			callback = function()
				vim.lsp.buf.format()
			end,
		})
	end,
})

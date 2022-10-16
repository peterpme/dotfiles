local present, null_ls = pcall(require, "null-ls")

if not present then
	return
end

local b = null_ls.builtins

local sources = {
	-- Rescript/Reason
	-- b.formatting.rescript,

	-- Javascript
	b.formatting.prettierd,
	b.formatting.eslint_d,

	b.code_actions.eslint_d,
	b.diagnostics.eslint_d,

	b.diagnostics.tsc,

	-- Lua
	b.formatting.stylua,
	-- b.diagnostics.luacheck.with { extra_args = { "--global vim" } },

	-- Shell
	b.formatting.shfmt,
	b.diagnostics.shellcheck.with({ diagnostics_format = "#{m} [#{c}]" }),
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

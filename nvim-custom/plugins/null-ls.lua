local null_ls = require "null-ls"
local b = null_ls.builtins

local sources = {
   -- Rescript/Reason
   b.formatting.rescript,

   -- Javascript
   b.formatting.prettierd,
   b.formatting.eslint_d,
   b.code_actions.eslint_d,

   b.diagnostics.tsc,
   -- Won't work until we've upgraded to eslint 8, unless there's a way to downgrade
   -- b.diagnostics.eslint_d,

   -- Lua
   b.formatting.stylua,
   b.diagnostics.luacheck.with { extra_args = { "--global vim" } },
}

local M = {}

M.setup = function()
   null_ls.setup {
      debug = true,
      sources = sources,
      -- format on save
      on_attach = function(client)
         if client.resolved_capabilities.document_formatting then
            vim.cmd "autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()"
         end
      end,
   }
end

return M

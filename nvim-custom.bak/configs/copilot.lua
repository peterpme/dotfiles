
local get_nvm_node_dir = function (path)
  local entries = {}
  local handle = vim.loop.fs_scandir(path)

  if type(handle) == 'userdata' then
    local function iterator()
      return vim.loop.fs_scandir_next(handle)
    end

    for name in iterator do
      local absolute_path = path .. '/' .. name
      local relative_path = vim.fn.fnamemodify(absolute_path, ':.')
      local version_match = relative_path:match('v16.*')
      if version_match ~= nil then
        table.insert(entries, absolute_path)
      end
    end
    table.sort(entries)
  end
  return entries[#entries]
end

local node_fallback = function ()
  local node = vim.fn.exepath("node")

  if not node then
    print('Node not found in path')
    return
  end
  return node
end

local resolve_node_cmd = function ()
  local nvm_dir = vim.fn.expand('$NVM_DIR')

  if nvm_dir == "$NVM_DIR" then
    return node_fallback()
  end

  nvm_dir = nvm_dir .. "/versions/node"
  local node = get_nvm_node_dir(nvm_dir)
  if not node then
    return node_fallback()
  end
  node = node .. "/bin/node"
  return node
end


-- https://github.com/zbirenbaum/copilot.lua
require("copilot").setup({
  suggestion = {
    auto_trigger = true,
  },
  ft_disable = { "go", "dap-repl" },
  -- i don't think we need either of these tbh
  -- copilot_node_command = "~/.fnm/node-versions/v16.18.1/installation/bin/node"
  -- copilot_node_command = resolve_node_cmd(),
})

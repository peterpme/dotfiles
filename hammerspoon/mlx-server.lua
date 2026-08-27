-- luacheck: globals hs
-- Fast menubar: never shells out on click. Pidfile + file checks only.

local HOME = os.getenv("HOME")
local BIN = HOME .. "/models/mlx-server"
local MODEL = HOME .. "/models/Qwen3.8-27B-Uncensored-MLX/8-bit"
local PIDFILE = HOME .. "/models/mlx-server.pid"
local LOG = HOME .. "/models/mlx-server.log"
local PORT = 18765
local ENDPOINT = "http://qwen38-27b.ai.peterp.local/v1"

local menu = hs.menubar.new()
local cachedOn = false
local cachedReady = false

local function pidAlive(pid)
  if not pid then
    return false
  end
  -- /bin/kill is instant; do not go through mlx-server
  local ok = os.execute("/bin/kill -0 " .. tonumber(pid) .. " 2>/dev/null")
  return ok == 0 or ok == true
end

local function readPid()
  local f = io.open(PIDFILE, "r")
  if not f then
    return nil
  end
  local s = f:read("*l")
  f:close()
  return tonumber(s)
end

local function isOn()
  local pid = readPid()
  if pid and pidAlive(pid) then
    return true, pid
  end
  return false, nil
end

local function weightsReady()
  for i = 1, 6 do
    if not hs.fs.attributes(string.format("%s/model-0000%d-of-00006.safetensors", MODEL, i)) then
      return false
    end
  end
  return true
end

local function setTitle(on, ready)
  if on then
    menu:setTitle("🟢 MLX")
  elseif not ready then
    menu:setTitle("⬇️ MLX")
  else
    menu:setTitle("⚪️ MLX")
  end
end

local function refreshCache()
  cachedOn = select(1, isOn())
  cachedReady = weightsReady()
  setTitle(cachedOn, cachedReady)
end

local function notify(text)
  hs.notify.new({ title = "MLX", informativeText = text }):send()
end

local function spawn(args, doneText)
  hs.task.new(BIN, function()
    refreshCache()
    if doneText then
      notify(doneText)
    end
  end, args):start()
end

local function buildMenu()
  -- cheap: pidfile + six stat()s, no bash, no curl
  local on, pid = isOn()
  local ready = weightsReady()
  cachedOn, cachedReady = on, ready
  setTitle(on, ready)

  local state
  if on then
    state = "on  pid " .. tostring(pid)
  elseif not ready then
    state = "downloading"
  else
    state = "off"
  end

  return {
    { title = "MLX  ·  " .. state, disabled = true },
    { title = "-" },
    {
      title = on and "Turn Off" or "Turn On",
      disabled = (not on) and (not ready),
      fn = function()
        if on then
          spawn({ "off" }, "Stopped")
        elseif not ready then
          notify("Weights still downloading")
        else
          notify("Starting… first load can take a minute")
          spawn({ "on" }, "Started  " .. ENDPOINT)
        end
      end,
    },
    {
      title = "Restart",
      disabled = not ready,
      fn = function()
        notify("Restarting…")
        spawn({ "restart" }, "Restarted")
      end,
    },
    {
      title = "Status",
      fn = function()
        local o, p = isOn()
        local r = weightsReady()
        local msg = (o and ("on  pid " .. p) or "off")
          .. "\n"
          .. (r and "weights ready" or "weights incomplete")
          .. "\n" .. ENDPOINT
        hs.alert.show(msg, 2)
      end,
    },
    {
      title = "Open logs",
      fn = function()
        os.execute("open -t " .. string.format("%q", LOG) .. " &")
      end,
    },
    {
      title = "Copy endpoint",
      fn = function()
        hs.pasteboard.setContents(ENDPOINT)
        notify("Copied " .. ENDPOINT)
      end,
    },
    { title = "-" },
    {
      title = ready and "Weights ready (8-bit)" or "Weights downloading…",
      disabled = true,
    },
  }
end

if menu then
  menu:setMenu(buildMenu)
  refreshCache()
  hs.timer.doEvery(20, refreshCache)
end

local alert = require "hs.alert"

local workWifi = "MakeOffices 5Ghz"
local officeWifi = "STEVE'S PLACE"
local homeWifi = "NETFLIX & CHILL"

local taskManagerUrl = "https://basecamp.com"
local defaultBrowser = "Safari"

hs.wifi.watcher.new(function ()
  local currentWifi = hs.wifi.currentNetwork()
  if not currentWifi then return end

  local note = hs.notify.new({
    title="Connected to WiFi",
    informativeText="Now connected to " .. currentWifi
  }):send()

  hs.timer.doAfter(3, function ()
    note:withdraw()
    note = nil
  end)

  if currentWifi == workWifi then
    hs.timer.doAfter(3, function ()
      hs.execute("open " .. taskManagerUrl)
      hs.notify.new(function ()
        hs.application.launchOrFocus(defaultBrowser)
      end, {title="Check tasks for the day"}):send()
    end)
  end
end):start()

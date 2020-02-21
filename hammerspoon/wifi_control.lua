local alert = require "hs.alert"
local application = require "hs.application"

local workWifi = "draftbit"
local officeWifi = "STEVE'S PLACE"
local homeWifi = "NETFLIX & CHILL"

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
      hs.notify.new(function ()
        application.launchOrFocus("Slack")
      end, {title="Welcome back"}):send()
    end)
  end
end):start()

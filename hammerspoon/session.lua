local wifi = require("wifi")
local turnOnUrl =
	"http://homeassistant.local:8123/api/webhook/webhook-galactus-connected-at-home-8LTe3RtdLdsrDwNkDmA3lXrB"
local turnOffUrl = "http://homeassistant.local:8123/api/webhook/-W1xgxyZCwY3V_bfL5i-qu98MR"
local headers = { ["Content-Type"] = "application/json" }
local targetDeviceName = "Scarlett 4i4 USB"

local function isTargetDeviceConnected()
	for _, device in ipairs(hs.usb.attachedDevices()) do
		if device.productName == targetDeviceName then
			return true
		end
	end
	return false
end

local function postToHomeAssistant(url)
	local payload = url == turnOnUrl and [[ { "speakers": "switch.turn_on" }]] or [[ { "speakers": "switch.turn_off" }]]
	hs.http.post(url, payload, headers)
end

local function handleSessionEvent(eventType)
	if wifi.homeSSID == wifi.lastSSID then
		if eventType == hs.caffeinate.watcher.screensDidUnlock and isTargetDeviceConnected() then
			postToHomeAssistant(turnOnUrl)
		elseif
			eventType == hs.caffeinate.watcher.screensDidLock
			or eventType == hs.caffeinate.watcher.screensDidSleep
			or eventType == hs.caffeinate.watcher.screensDidPowerOff
		then
			postToHomeAssistant(turnOffUrl)
		end
	end
end

local sessionWatcher = hs.caffeinate.watcher.new(function(eventType)
	hs.timer.doAfter(1, function()
		handleSessionEvent(eventType)
	end)
end)

sessionWatcher:start()
return { sessionWatcher = sessionWatcher }

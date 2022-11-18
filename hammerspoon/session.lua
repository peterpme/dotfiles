local wifi = require("wifi")
local turnOnUrl = "http://homeassistant.local:8123/api/webhook/-kCb-V-1mjxsPcrgnP3zt7AFG" --git-ignore
local turnOffUrl = "http://homeassistant.local:8123/api/webhook/-W1MgMyMCwY3V_bfL5iqu98MZ" --git-ignore
local headers = {
	["Content-Type"] = "application/json",
}

local watcher = {}

function isAudioInterface(usbDevice)
	return usbDevice.productName == "Scarlett 4i4 USB"
end

function listenForAudioInterface(event)
	if wifi.homeSSID == wifi.lastSSID then
		hs.alert(wifi.lastSSID)
		if isAudioInterface(event) and event.eventType == "added" then
			watcher.usb = "on"
			local payload = [[ { "speakers": "switch.turn_on" }]]
			hs.http.post(turnOnUrl, payload, headers)
			return
		end

		-- if usb unplugged, turn off lights & speakers
		if isAudioInterface(event) and event.eventType == "removed" then
			watcher.usb = "off"
			local payload = [[ { "speakers": "switch.turn_off" }]]
			hs.http.post(turnOffUrl, payload, headers)
			return
		end
	end
end

function listenForSession(eventType)
	hs.alert(watcher.usb)
	if wifi.homeSSID == wifi.lastSSID then
		-- start / if usb is plugged in, but computer locks, turn off lights & speakers
		if eventType == hs.caffeinate.watcher.screensDidLock then
			hs.spotify.pause()
			local payload = [[ { "speakers": "switch.turn_off" }]]
			hs.http.post(turnOffUrl, payload, headers)
			return
		end

		if eventType == hs.caffeinate.watcher.screensDidSleep then
			hs.spotify.pause()
			local payload = [[ { "speakers": "switch.turn_off" }]]
			hs.http.post(turnOffUrl, payload, headers)
			return
		end

		if eventType == hs.caffeinate.watcher.screensDidPowerOff then
			hs.spotify.pause()
			local payload = [[ { "speakers": "switch.turn_off" }]]
			hs.http.post(turnOffUrl, payload, headers)
			return
		end
		-- end / if usb is plugged in, but computer locks, turn off lights & speakers

		-- if usb is plugged in and computer unlocks, turn on lights & speakers
		if eventType == hs.caffeinate.watcher.screensDidUnlock and watcher.usb == "on" then
			local payload = [[ { "speakers": "switch.turn_on" }]]
			hs.http.post(turnOnUrl, payload, headers)
			return
		end

		if eventType == hs.caffeinate.watcher.sessionDidBecomeActive and watcher.usb == "on" then
			local payload = [[ { "speakers": "switch.turn_on" }]]
			hs.http.post(turnOnUrl, payload, headers)
		end
	end
end

watcher.usbWatcher = hs.usb.watcher.new(listenForAudioInterface)
watcher.usbWatcher:start()

watcher.sessionWatcher = hs.caffeinate.watcher.new(listenForSession)
watcher.sessionWatcher:start()

return watcher

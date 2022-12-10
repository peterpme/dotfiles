local wifi = require("wifi")
-- turnOnUrl / turnOffUrl variables are ripped out
local turnOnUrl =
local headers = {
	["Content-Type"] = "application/json",
}

session = {}
session.usb = "off"
session.status = "locked"

function isAudioInterface(usbDevice)
	return usbDevice.productName == "Scarlett 4i4 USB"
end

function listenForAudioInterface(event)
	hs.alert.show(session.status)
	if wifi.homeSSID == wifi.lastSSID then
		if session.status == "unlocked" then
			if isAudioInterface(event) and event.eventType == "added" then
				session.usb = "on"
				local payload = [[ { "speakers": "switch.turn_on" }]]
				hs.http.post(turnOnUrl, payload, headers)
				return
			end
		end

		-- if usb unplugged, turn off lights & speakers
		if isAudioInterface(event) and event.eventType == "removed" then
			session.usb = "off"
			local payload = [[ { "speakers": "switch.turn_off" }]]
			hs.http.post(turnOffUrl, payload, headers)
			return
		end
	end
end

function listenForSession(eventType)
	session.status = "locked"
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
		if eventType == hs.caffeinate.watcher.screensDidUnlock then
			session.status = "unlocked"
			if session.usb == "on" then
				local payload = [[ { "speakers": "switch.turn_on" }]]
				hs.http.post(turnOnUrl, payload, headers)
			end
			return
		end
	end
end

function handleSessionChange()
	return hs.caffeinate.watcher.new(function(eventType)
		hs.timer.doAfter(2, function()
			return listenForSession(eventType)
		end)
	end)
end

function handleUsbChange()
	return hs.usb.watcher.new(function(eventType)
		hs.timer.doAfter(2, function()
			return listenForAudioInterface(eventType)
		end)
	end)
end

session.sessionWatcher = handleSessionChange()
session.sessionWatcher:start()

session.usbWatcher = handleUsbChange()
session.usbWatcher:start()

return session

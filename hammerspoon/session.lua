-- luacheck: globals hs
-- local wifi = require("wifi")

local thunderboltMonitorName = "LG HDR WQHD"
local log = hs.logger.new("session", "info") -- levels: debug, info, warning, error

-- local function httpPost(url, data, headers)
-- 	log.i(string.format("HTTP POST -> %s", url))
-- 	local code, body, respHeaders = hs.http.post(url, data, headers) -- returns (status, body, headers)
-- 	log.i(string.format("HTTP POST <- %s | status=%s len=%s", url, tostring(code), body and #body or 0))
-- 	if code and code >= 400 then
-- 		log.e(string.format("HTTP error: %s body=%s", tostring(code), tostring(body)))
-- 	end
-- 	return code, body, respHeaders
-- end

local function isThunderboltMonitorConnected()
	for _, screen in ipairs(hs.screen.allScreens()) do
		-- Log names to help confirm the monitor label
		log.d("Found screen: " .. (screen:name() or "nil"))
		if screen:name() == thunderboltMonitorName then
			return true
		end
	end
	return false
end

-- local function atHome()
-- 	local ssid = wifi.lastSSID
-- 	log.i("Current SSID: " .. tostring(ssid))
-- 	return ssid == wifi.homeSSID
-- end

-- local eventNames = {
-- 	[hs.caffeinate.watcher.screensDidUnlock] = "screensDidUnlock",
-- 	[hs.caffeinate.watcher.screensDidLock] = "screensDidLock",
-- 	[hs.caffeinate.watcher.screensDidSleep] = "screensDidSleep",
-- 	[hs.caffeinate.watcher.screensDidWake] = "screensDidWake",
-- 	[hs.caffeinate.watcher.screensDidPowerOff] = "screensDidPowerOff",
-- 	[hs.caffeinate.watcher.systemWillSleep] = "systemWillSleep",
-- 	[hs.caffeinate.watcher.systemDidWake] = "systemDidWake",
-- 	[hs.caffeinate.watcher.sessionDidBecomeActive] = "sessionDidBecomeActive",
-- 	[hs.caffeinate.watcher.sessionDidResignActive] = "sessionDidResignActive",
-- 	[hs.caffeinate.watcher.screensaverDidStart] = "screensaverDidStart",
-- 	[hs.caffeinate.watcher.screensaverWillStop] = "screensaverWillStop",
-- 	[hs.caffeinate.watcher.screensaverDidStop] = "screensaverDidStop",
-- }

local function handleSessionEvent(eventType)
	-- if not atHome() then
	-- 	log.i("Not on home Wi-Fi; skipping.")
	-- 	return
	-- end

	local tbConnected = isThunderboltMonitorConnected()
	log.i("Thunderbolt monitor connected? " .. tostring(tbConnected))

	-- if wifi.homeSSID == wifi.lastSSID then
	if eventType == hs.caffeinate.watcher.screensDidUnlock and isThunderboltMonitorConnected() then
		hs.http.post(unlockUrl)
	elseif
		eventType == hs.caffeinate.watcher.screensDidLock
		or eventType == hs.caffeinate.watcher.screensDidSleep
		or eventType == hs.caffeinate.watcher.screensDidPowerOff
		or (eventType == hs.caffeinate.watcher.screensDidWake and not isThunderboltMonitorConnected())
	then
		hs.http.post(lockUrl)
	end
	-- end
end

local sessionWatcher = hs.caffeinate.watcher.new(function(eventType)
	-- Delay to let Wi-Fi/display settle.
	hs.timer.doAfter(5, function()
		local ok, err = pcall(handleSessionEvent, eventType)
		if not ok then
			log.e("Error in handleSessionEvent: " .. tostring(err))
		end
	end)
end)

sessionWatcher:start()
return { sessionWatcher = sessionWatcher }

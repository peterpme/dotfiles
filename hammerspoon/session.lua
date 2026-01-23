-- luacheck: globals hs

local thunderboltMonitorName = "LG HDR WQHD"
local log = hs.logger.new("session", "info") -- levels: debug, info, warning, error

-- Track dock state to detect disconnect
local wasDocked = false

local function asyncHttpPost(url)
	log.d("HTTP POST -> " .. url)
	hs.http.asyncPost(url, "", nil, function(status, _, _)
		if status == 0 then
			log.w("HTTP POST failed (network error): " .. url)
		elseif status >= 400 then
			log.w(string.format("HTTP POST error: %s status=%d", url, status))
		else
			log.d(string.format("HTTP POST <- %s status=%d", url, status))
		end
	end)
end

local function isThunderboltMonitorConnected()
	for _, screen in ipairs(hs.screen.allScreens()) do
		log.d("Found screen: " .. (screen:name() or "nil"))
		if screen:name() == thunderboltMonitorName then
			return true
		end
	end
	return false
end

local function isCalDigitDockConnected()
	local _, status = hs.execute("ioreg -p IOUSB -l | grep -q 'CalDigit'")
	local connected = status == true
	log.d("CalDigit dock connected? " .. tostring(connected))
	return connected
end

local function handleSessionEvent(eventType)
	local docked = isCalDigitDockConnected()
	local tbConnected = isThunderboltMonitorConnected()
	log.i(string.format("Session event: docked=%s, monitor=%s", tostring(docked), tostring(tbConnected)))

	-- Lights ON: unlock while docked with monitor
	if eventType == hs.caffeinate.watcher.screensDidUnlock and docked and tbConnected then
		asyncHttpPost(unlockUrl)
	-- Lights OFF: lock/sleep while docked
	elseif
		docked
		and (eventType == hs.caffeinate.watcher.screensDidLock
			or eventType == hs.caffeinate.watcher.screensDidSleep
			or eventType == hs.caffeinate.watcher.screensDidPowerOff)
	then
		asyncHttpPost(lockUrl)
	end
end

local sessionWatcher = hs.caffeinate.watcher.new(function(eventType)
	hs.timer.doAfter(5, function()
		local ok, err = pcall(handleSessionEvent, eventType)
		if not ok then
			log.e("Error in handleSessionEvent: " .. tostring(err))
		end
	end)
end)

-- Watch for USB changes to detect dock disconnect
local usbWatcher = hs.usb.watcher.new(function(event)
	log.d("USB event: " .. hs.inspect(event))

	-- Small delay to let USB settle
	hs.timer.doAfter(1, function()
		local docked = isCalDigitDockConnected()

		-- Dock was connected, now disconnected -> turn off lights
		if wasDocked and not docked then
			log.i("CalDigit dock disconnected, turning off lights")
			asyncHttpPost(lockUrl)
		-- Dock was disconnected, now connected -> will handle via session events
		elseif not wasDocked and docked then
			log.i("CalDigit dock connected")
		end

		wasDocked = docked
	end)
end)

-- Initialize dock state
wasDocked = isCalDigitDockConnected()
log.i("Initial dock state: " .. tostring(wasDocked))

sessionWatcher:start()
usbWatcher:start()
return { sessionWatcher = sessionWatcher, usbWatcher = usbWatcher }

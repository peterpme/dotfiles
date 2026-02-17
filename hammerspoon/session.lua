-- luacheck: globals hs

local secrets = require("secrets")
local lockUrl = secrets.homeAssistantBaseUrl .. "/" .. secrets.lockWebhook
local unlockUrl = secrets.homeAssistantBaseUrl .. "/" .. secrets.unlockWebhook
local thunderboltMonitorName = "LG HDR WQHD"
local geforceNowAppName = "NVIDIA GeForce NOW"
local log = hs.logger.new("session", "info") -- levels: debug, info, warning, error

-- Track dock state to detect disconnect
local wasDocked = false

-- YouTube playlist URL
local youtubePlaylistUrl = "https://www.youtube.com/watch?v=iuLdwR768p8&list=RDiuLdwR768p8&start_radio=1"

local function isWorkHours()
	local hour = tonumber(os.date("%H"))
	return hour >= 8 and hour < 17
end

local function switchAudioDevice(deviceName)
	local device = hs.audiodevice.findOutputByName(deviceName)
	if device then
		device:setDefaultOutputDevice()
		log.i("Switched audio to " .. deviceName)
		return true
	else
		log.w("Could not find audio device: " .. deviceName)
		return false
	end
end

local function switchToOfficeSpeakers()
	if switchAudioDevice("Peter Office Speakers") then
		local device = hs.audiodevice.defaultOutputDevice()
		if device then
			device:setOutputVolume(20)
			log.i("Set Peter Office Speakers volume to 20%")
		end
	end
end

local function switchToHeadphone()
	if switchAudioDevice("Headphone") then
		-- Set volume to 20%
		local device = hs.audiodevice.defaultOutputDevice()
		if device then
			device:setOutputVolume(20)
			log.i("Set Headphone volume to 20%")
		end
	end
end

local function switchToUSBAudioDevice()
	if switchAudioDevice("USB Audio Device") then
		local device = hs.audiodevice.defaultOutputDevice()
		if device then
			device:setOutputVolume(30)
			log.i("Set USB Audio Device volume to 30%")
		end
	end
end

local function playYouTubeMusic()
	log.i("Opening YouTube playlist in Safari")
	hs.execute("open -a Safari '" .. youtubePlaylistUrl .. "'")
	-- Wait for page to load, then minimize Safari
	hs.timer.doAfter(5, function()
		local safari = hs.application.get("Safari")
		if safari then
			local win = safari:mainWindow()
			if win then
				win:minimize()
				log.i("Safari window minimized")
			end
		end
	end)
end

-- Menubar item for manual music trigger
local musicMenubar = hs.menubar.new()
if musicMenubar then
	musicMenubar:setTitle("♫")
	musicMenubar:setMenu({
		{ title = "Play YouTube Music", fn = playYouTubeMusic },
		{ title = "-" },
		{ title = "Switch to Peter Office Speakers", fn = switchToOfficeSpeakers },
		{ title = "Switch to Headphone", fn = switchToHeadphone }
	})
end

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
		-- Dock was disconnected, now connected -> switch audio and play music
		elseif not wasDocked and docked then
			log.i("CalDigit dock connected")
			switchToOfficeSpeakers()
			if isWorkHours() then
				hs.timer.doAfter(3, playYouTubeMusic)
			else
				log.i("Outside work hours (8am-5pm), skipping music")
			end
		end

		wasDocked = docked
	end)
end)

-- Initialize dock state
wasDocked = isCalDigitDockConnected()
log.i("Initial dock state: " .. tostring(wasDocked))

-- Pause Safari media (won't open Music app)
local function pauseSafariMedia()
	local safari = hs.application.get("Safari")
	if safari then
		hs.osascript.applescript([[
			tell application "Safari"
				do JavaScript "document.querySelectorAll('video, audio').forEach(v => v.pause())" in current tab of front window
			end tell
		]])
		log.i("Paused Safari media")
	else
		log.d("Safari not running, nothing to pause")
	end
end

-- Play Safari media
local function playSafariMedia()
	local safari = hs.application.get("Safari")
	if safari then
		hs.osascript.applescript([[
			tell application "Safari"
				do JavaScript "document.querySelectorAll('video, audio').forEach(v => v.play())" in current tab of front window
			end tell
		]])
		log.i("Resumed Safari media")
	else
		log.d("Safari not running, nothing to play")
	end
end

-- Watch for NVIDIA GeForce NOW to switch audio
local appWatcher = hs.application.watcher.new(function(appName, eventType, _)
	-- Log all app events for debugging
	if eventType == hs.application.watcher.terminated then
		log.d("App terminated: " .. tostring(appName))
	end

	if appName == geforceNowAppName then
		if eventType == hs.application.watcher.launched then
			log.i(geforceNowAppName .. " launched, switching to USB Audio Device")
			pauseSafariMedia()
			hs.alert.show("Switching to USB Audio Device")
			switchToUSBAudioDevice()
		elseif eventType == hs.application.watcher.terminated then
			log.i(geforceNowAppName .. " closed, switching to Headphone")
			hs.alert.show("Switching to Headphone & Resuming Music")
			hs.timer.doAfter(2, function()
				switchToHeadphone()
				playSafariMedia()
			end)
		end
	end
end)

sessionWatcher:start()
usbWatcher:start()
appWatcher:start()
return { sessionWatcher = sessionWatcher, usbWatcher = usbWatcher, appWatcher = appWatcher, musicMenubar = musicMenubar }

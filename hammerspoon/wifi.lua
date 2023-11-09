wifi = {}

wifi.homeSSID = "NETFLIX & CHILL" --git-ignore
wifi.lastSSID = nil -- Initialize as nil and let the watcher update it

function handleWifiNetwork()
	local newSSID = hs.wifi.currentNetwork()
	-- hs.alert.show("Current SSID: " .. (newSSID or "None"))

	if newSSID == wifi.homeSSID and wifi.lastSSID ~= wifi.homeSSID then
		-- We just joined our home WiFi network
		hs.audiodevice.defaultOutputDevice():setVolume(25)
	elseif newSSID ~= wifi.homeSSID and wifi.lastSSID == wifi.homeSSID then
		-- We just departed our home WiFi network
		hs.audiodevice.defaultOutputDevice():setVolume(0)
		hs.alert.show("Disconnected from Home Network")
	end

	wifi.lastSSID = newSSID
end

wifi.wifiWatcher = hs.wifi.watcher.new(handleWifiNetwork)
wifi.wifiWatcher:start()

-- Optionally, call handleWifiNetwork() to set the initial state
handleWifiNetwork()

return wifi

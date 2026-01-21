local wifi = {}

wifi.homeSSID = "Chestnut Castle" --git-ignore
wifi.lastSSID = nil -- Initialize as nil and let the watcher update it

local function handleWifiNetwork()
	local newSSID = hs.wifi.currentNetwork()
	local audioDevice = hs.audiodevice.defaultOutputDevice()

	if newSSID == nil then
		-- WiFi disconnected
		if wifi.lastSSID ~= nil then
			hs.alert.show("WiFi Disconnected")
		end
	elseif newSSID == wifi.homeSSID and wifi.lastSSID ~= wifi.homeSSID then
		-- We just joined our home WiFi network
		if audioDevice then
			audioDevice:setVolume(50)
		end
		hs.alert.show("Connected to Home Network")
	elseif newSSID ~= wifi.homeSSID and wifi.lastSSID == wifi.homeSSID then
		-- We just departed our home WiFi network
		if audioDevice then
			audioDevice:setVolume(0)
		end
		hs.alert.show("Disconnected from Home Network")
	end

	wifi.lastSSID = newSSID
end

wifi.wifiWatcher = hs.wifi.watcher.new(handleWifiNetwork)
wifi.wifiWatcher:start()

-- Set the initial state
handleWifiNetwork()

return wifi

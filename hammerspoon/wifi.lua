wifi = {}

wifi.homeSSID = "NETFLIX & CHILL" --git-ignore
wifi.lastSSID = hs.wifi.currentNetwork()

function handleWifiNetwork()
	newSSID = hs.wifi.currentNetwork()
	hs.alert(newSSID)

	if newSSID == wifi.homeSSID and wifi.lastSSID ~= wifi.homeSSID then
		-- We just joined our home WiFi network
		hs.audiodevice.defaultOutputDevice():setVolume(25)
	elseif newSSID ~= wifi.homeSSID and wifi.lastSSID == wifi.homeSSID then
		hs.alert("disconnected")
		-- We just departed our home WiFi network
		hs.audiodevice.defaultOutputDevice():setVolume(0)
	end

	wifi.lastSSID = newSSID
end

wifi.wifiWatcher = hs.wifi.watcher.new(handleWifiNetwork)
wifi.wifiWatcher:start()

return wifi

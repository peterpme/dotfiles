local menubar = hs.menubar.new()
menubar:setTitle("⌛")

netspeed_active_interface = hs.network.primaryInterfaces()
local interface_detail = hs.network.interfaceDetails(netspeed_active_interface)

local menuitems_table = {}

if interface_detail.AirPort then
	local ssid = interface_detail.AirPort.SSID
	table.insert(menuitems_table, {
		title = "SSID: " .. ssid,
		tooltip = "Copy SSID to clipboard",
		fn = function()
			hs.pasteboard.setContents(ssid)
		end,
	})
end

if interface_detail.IPv4 then
	local ipv4 = interface_detail.IPv4.Addresses[1]
	table.insert(menuitems_table, {
		title = "IPv4: " .. ipv4,
		tooltip = "Copy IPv4 to clipboard",
		fn = function()
			hs.pasteboard.setContents(ipv4)
		end,
	})
end

menubar:setMenu(menuitems_table)

function updateMenubar()
	menubar:setTooltip("Weather Info")
	menubar:setMenu(menuitems_table)
end

updateMenubar()

local alert = require "hs.alert"
local path = "http://homeassistant.local:8123"
local turn_on = "/api/services/hue/hue_activate_scene"
local turn_off = "/api/services/light/turn_off"


local headers = {
   ["Authorization"] = "Bearer " .. token,
   ["Content-Type"] = "application/json"
}

local day_payload = [[ "group_name":"Desk lights", "scene_name":"Default" ]]
local night_payload = [[ "group_name":"Desk lights", "scene_name":"Gamer" ]]

sessionWatcher = nil

function sessionChanged(eventType)
   hour = tonumber(os.date("%H"))

   -- After 8pm before 6am
   if (hour > 20 or hour < 3) then
    if (eventType == hs.caffeinate.watcher.screensDidUnlock) then
       hs.http.post(path .. turn_on, night_payload, headers)
    end

    if (eventType == hs.caffeinate.watcher.screensDidWake) then
       hs.http.post(path .. turn_on, night_payload, headers)
    end

    if (eventType == hs.caffeinate.watcher.systemDidWake) then
       hs.http.post(path .. turn_on, night_payload, headers)
    end

   else
        hs.http.post(path .. turn_on, day_payload, headers)
   end
end

sessionWatcher = hs.caffeinate.watcher.new(sessionChanged)
sessionWatcher:start()

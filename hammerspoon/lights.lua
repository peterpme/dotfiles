local path = "http://homeassistant.local:8123"
local turn_on = "/api/services/hue/hue_activate_scene"
local turn_off = "/api/services/light/turn_off"


local headers = {
   ["Authorization"] = "Bearer " .. token,
   ["Content-Type"] = "application/json"
}

sessionWatcher = nil

local turn_on_path = path .. turn_on
local turn_off_path = path .. turn_off

local day_payload = [[ {"group_name":"Desk lights", "scene_name":"Default"} ]]
local night_payload = [[ {"group_name":"Desk lights", "scene_name":"Gamer"} ]]
local turn_off_payload = [[ {"entity_id":"light.computer_backlight"} ]]

function sessionChanged(eventType)
   hour = tonumber(os.date("%H"))
   -- After 5pm before 7am
   if (hour > 17 or hour < 7) then
      if (eventType == hs.caffeinate.watcher.screensDidUnlock) then
         hs.http.post(turn_on_path, night_payload, headers)
      end
   else
      if (eventType == hs.caffeinate.watcher.screensDidUnlock) then
         hs.http.post(turn_on_path, day_payload, headers)
      end
   end

   if (eventType == hs.caffeinate.watcher.screensDidLock) then
      hs.http.post(turn_off_path, turn_off_payload, headers)
   end

   if (eventType == hs.caffeinate.watcher.screensDidSleep) then
      hs.http.post(turn_off_path, turn_off_payload, headers)
   end

   if (eventType == hs.caffeinate.watcher.screensDidPowerOff) then
      hs.http.post(turn_off_path, turn_off_payload, headers)
   end
end

sessionWatcher = hs.caffeinate.watcher.new(sessionChanged)
sessionWatcher:start()

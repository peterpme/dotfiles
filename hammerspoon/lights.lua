local path = "http://homeassistant.local:8123"
local turn_on = "/api/services/hue/hue_activate_scene"
local turn_off = "/api/services/light/turn_off"

local token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJhNjU3OTNhZmM3Njg0YTRkYTJlY2Y2ZDU4ODZlMDI4YiIsImlhdCI6MTYzOTAwMjUwOSwiZXhwIjoxOTU0MzYyNTA5fQ.7SZKK8FFTaczdnHRm1s4qQoRYbC1bqEca8jNfE8BJpI" -- #gitignore

local headers = {
   ["Authorization"] = "Bearer " .. token,
   ["Content-Type"] = "application/json"
}

sessionWatcher = nil

local turn_on_path = path .. turn_on
local turn_off_path = path .. turn_off

local turn_on_payload = [[ {"group_name":"Desk lights", "scene_name":"Gamer"} ]]
local turn_off_payload = [[ {"entity_id":"light.computer_backlight"} ]]

function sessionChanged(eventType)
   hour = tonumber(os.date("%H"))
   -- After 6pm before 7am
   if (hour > 18 or hour < 7) then
      if (eventType == hs.caffeinate.watcher.screensDidUnlock) then
         hs.http.post(turn_on_path, turn_on_payload, headers)
      end
   else
      if (eventType == hs.caffeinate.watcher.screensDidUnlock) then
         hs.http.post(turn_on_path, turn_on_payload, headers)
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

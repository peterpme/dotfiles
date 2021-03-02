local path = "http://192.168.6.142:8123"
local token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJhNDgwMzFmMWFjYTY0YWQ4YWU1NGMyODVjYjQ1ZjM2YiIsImlhdCI6MTYwMzg1NjUyNSwiZXhwIjoxOTE5MjE2NTI1fQ.6BhhCEdLvEXX_Tzbb8YsfEjE4PcWWd74zUhp4XHuyzs"; -- #gitignore

local headers = {
   ["Authorization"] = "Bearer " .. token,
   ["Content-Type"] = "application/json"
}

sessionWatcher = nil

function sessionChanged(eventType)
   hour = tonumber(os.date("%H"))
   -- After 6pm before 7am
   if (hour > 18 or hour < 7) then
      if (eventType == hs.caffeinate.watcher.screensDidUnlock) then
         local payload = [[ {"group_name":"Desk lights", "scene_name":"Gamer"} ]]
         hs.http.post(path .. "/api/services/hue/hue_activate_scene", payload, headers)
      end
   else
      if (eventType == hs.caffeinate.watcher.screensDidUnlock) then
         local payload = [[ {"group_name":"Desk lights", "scene_name":"Default"} ]]
         hs.http.post(path .. "/api/services/hue/hue_activate_scene", payload, headers)
      end
   end

   if (eventType == hs.caffeinate.watcher.screensDidLock) then
      local payload = [[ {"entity_id":"light.desk_lights"} ]]
      hs.http.post(path .. "/api/services/light/turn_off", payload, headers)
   end

   if (eventType == hs.caffeinate.watcher.screensDidSleep) then
      local payload = [[ {"entity_id":"light.desk_lights"} ]]
      hs.http.post(path .. "/api/services/light/turn_off", payload, headers)
   end

   if (eventType == hs.caffeinate.watcher.screensDidPowerOff) then
      local payload = [[ {"entity_id":"light.desk_lights"} ]]
      hs.http.post(path .. "/api/services/light/turn_off", payload, headers)
   end
end

sessionWatcher = hs.caffeinate.watcher.new(sessionChanged)
sessionWatcher:start()

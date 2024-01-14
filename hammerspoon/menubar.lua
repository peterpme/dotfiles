-- luacheck: globals hs



local turnOnUrl = baseUrl .. "/" .. turnOnSpeakersWebhook
local turnOffUrl = baseUrl .. "/" .. turnOffSpeakersWebhook

local headers = { ["Content-Type"] = "application/json" }

local function postToHomeAssistant(url)
  local payload = url == turnOnUrl and [[ { "speakers": "switch.turn_on" }]] or [[ { "speakers": "switch.turn_off" }]]
  hs.http.post(url, payload, headers)
end

local function toggleSpeakers(action)
  if action == "on" then
    postToHomeAssistant(turnOnUrl)
  elseif action == "off" then
    postToHomeAssistant(turnOffUrl)
  else
    print("Invalid action for toggleSpeakers")
  end
end

local function toggleBacklight(mode)
  if mode == "default" then
    postToHomeAssistant()
  elseif mode == "gamer" then
    postToHomeAssistant()
  else
    postToHomeAssistant()
  end
end

-- Create menubar
local menu = hs.menubar.new()

local menuItems = {
  {
    title = "Turn ON Speakers",
    fn = function()
      toggleSpeakers("on")
    end,
  },
  {
    title = "Turn OFF Speakers",
    fn = function()
      toggleSpeakers("off")
    end,
  },
  -- {
  --   title = "Default Backlight",
  --   fn = function()
  --     toggleBacklight("default")
  --   end,
  -- },
  -- {
  --   title = "Gamer Backlight",
  --   fn = function()
  --     toggleBacklight("gamer")
  --   end,
  -- },
  -- {
  --   title = "Turn OFF Backlight",
  --   fn = function()
  --     toggleBacklight("")
  --   end,
  -- },
}

-- Set menu items
menu:setTitle("🎮")
menu:setMenu(menuItems)

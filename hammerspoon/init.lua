local application = require "hs.application"
local hotkey = require "hs.hotkey"
local alert = require "hs.alert"
local Grid = require 'grid'

require "wifi_control"

local mashGeneral = {
  'cmd',
  'ctrl'
}

local mashApps = {
  'cmd',
  'ctrl'
}

local screenKeys = {
  'cmd',
  'ctrl',
  'shift'
}

for screenIndex = 1, 3 do
  hs.hotkey.bind(screenKeys, tostring(screenIndex), function()
    local win = hs.window.focusedWindow()
    local screen = hs.screen.allScreens()[screenIndex]

    win:moveToScreen(screen)
    win:setFrame(screen:frame())
  end)
end

hs.hotkey.bind(mashGeneral, "S", function()
  for i, screen in ipairs(hs.screen.allScreens()) do
    hs.alert("Screen " .. i, {}, screen)
  end
end)

-- Disable window animations (janky for iTerm)
hs.window.animationDuration = 0

-- Hammerspoon repl
hs.hotkey.bind(mashGeneral, 'C', hs.openConsole)

-- Window Management
hs.hotkey.bind(mashGeneral, 'O', Grid.fullscreen)
hs.hotkey.bind(mashGeneral, 'H', Grid.leftchunk)
hs.hotkey.bind(mashGeneral, 'L', Grid.rightchunk)
hs.hotkey.bind(mashGeneral, 'K', Grid.topHalf)
hs.hotkey.bind(mashGeneral, 'J', Grid.bottomHalf)

hs.hotkey.bind(mashGeneral, 'U', Grid.topleft)
hs.hotkey.bind(mashGeneral, 'N', Grid.bottomleft)
hs.hotkey.bind(mashGeneral, 'I', Grid.topright)
hs.hotkey.bind(mashGeneral, 'M', Grid.bottomright)

-- Spotify
hs.hotkey.bind(mashGeneral, 'P', hs.spotify.play)
hs.hotkey.bind(mashGeneral, 'Y', hs.spotify.pause)
hs.hotkey.bind(mashGeneral, 'T', hs.spotify.displayCurrentTrack)

-- Slack-specific app launcher (since I keep it "peeked" to the side by default)
function showSlack()
  local appName = 'Slack'
  local app = hs.application.find(appName)
  hs.application.launchOrFocus(appName)

  if (app and hs.application.isRunning(app)) then
    Grid.topleft()
  end
end

-- App Shortcuts
hs.hotkey.bind(mashApps, '1', function() hs.application.launchOrFocus('kitty') end)
hs.hotkey.bind(mashApps, '2', function() hs.application.launchOrFocus('Firefox') end)
hs.hotkey.bind(mashApps, '3', showSlack)
hs.hotkey.bind(mashApps, '4', function() hs.application.launchOrFocus('Polymail') end)

-- Reload automatically on config changes
hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', hs.reload):start()
hs.alert('Hammerspoon is locked and loaded', 1)

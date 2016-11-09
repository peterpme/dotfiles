local screen = require "hs.screen"
local audiodevice = require "hs.audiodevice"
local alert = require "hs.alert"
local itunes = require "hs.itunes"

-- Mute everything when a screen gets (dis)connected.
watcher = screen.watcher.new(function()
  audioDevices = audiodevice.allOutputDevices()
  for i = 1, #audioDevices do
    device = audioDevices[i]
    device:setVolume(0.0)
    device:setMuted(true)
    itunes.pause()
  end
  alert.show("Sound muted!")
end)
watcher:start()

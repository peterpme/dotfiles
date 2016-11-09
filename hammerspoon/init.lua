local application = require "hs.application"
local hotkey = require "hs.hotkey"
local alert = require "hs.alert"

local keys = require "keys"
require "window_management"

keys.deactivateKeys()
keys.activateKeys()

alert.show("Hammerspoon loaded!")

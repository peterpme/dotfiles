local hotkey = require("hs.hotkey")
local Grid = require("grid")

local grid = require("hs.grid")

grid.GRIDHEIGHT = 4
grid.GRIDWIDTH = 4

require("utils")
-- require("wifi_control")
-- require "lights"

local mashGeneral = {
	"cmd",
	"ctrl",
}

local mashResize = {
	"cmd",
	"ctrl",
	"alt",
}

local screenKeys = {
	"cmd",
	"ctrl",
	"shift",
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
hs.hotkey.bind(mashGeneral, "C", hs.openConsole)

-- Window Management
hs.hotkey.bind(mashGeneral, "O", Grid.fullscreen)
hs.hotkey.bind(mashGeneral, "H", Grid.leftHalf)
hs.hotkey.bind(mashGeneral, "L", Grid.rightHalf)
hs.hotkey.bind(mashGeneral, "K", Grid.topHalf)
hs.hotkey.bind(mashGeneral, "J", Grid.bottomHalf)

hs.hotkey.bind(mashGeneral, "U", Grid.topleft)
hs.hotkey.bind(mashGeneral, "N", Grid.bottomleft)
hs.hotkey.bind(mashGeneral, "I", Grid.topright)
hs.hotkey.bind(mashGeneral, "M", Grid.bottomright)

hotkey.bind(mashResize, "k", grid.resizeWindowShorter)
hotkey.bind(mashResize, "j", grid.resizeWindowTaller)
hotkey.bind(mashResize, "l", grid.resizeWindowWider)
hotkey.bind(mashResize, "h", grid.resizeWindowThinner)

-- Spotify
hs.hotkey.bind(mashGeneral, "P", hs.spotify.play)
hs.hotkey.bind(mashGeneral, "Y", hs.spotify.pause)
hs.hotkey.bind(mashGeneral, "T", hs.spotify.displayCurrentTrack)

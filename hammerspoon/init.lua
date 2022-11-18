local grid = require("hs.grid")
local hotkey = require("hs.hotkey")
local alert = require("hs.alert")

local Grid = require("grid")
require("wifi")
require("session")

alert("Hammerspoon is locked and loaded", 1)

grid.setGrid("16x4")
grid.setMargins("0x0")

-- Disable window animations (janky for iTerm)
hs.window.animationDuration = 0

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
	hotkey.bind(screenKeys, tostring(screenIndex), function()
		local win = hs.window.focusedWindow()
		local screen = hs.screen.allScreens()[screenIndex]

		win:moveToScreen(screen)
		win:setFrame(screen:frame())
	end)
end

hotkey.bind(mashGeneral, "S", function()
	for i, screen in ipairs(hs.screen.allScreens()) do
		alert("Screen " .. i, {}, screen)
	end
end)

-- Hammerspoon repl
hotkey.bind(mashGeneral, "C", hs.openConsole)

-- Window Management
hotkey.bind(mashGeneral, "O", Grid.fullscreen)
hotkey.bind(mashGeneral, "H", Grid.leftHalf)
hotkey.bind(mashGeneral, "L", Grid.rightHalf)
hotkey.bind(mashGeneral, "K", Grid.topHalf)
hotkey.bind(mashGeneral, "J", Grid.bottomHalf)

hotkey.bind(mashGeneral, "U", Grid.topleft)
hotkey.bind(mashGeneral, "N", Grid.bottomleft)
hotkey.bind(mashGeneral, "I", Grid.topright)
hotkey.bind(mashGeneral, "M", Grid.bottomright)

hotkey.bind(mashResize, "K", grid.resizeWindowShorter)
hotkey.bind(mashResize, "J", grid.resizeWindowTaller)
hotkey.bind(mashResize, "L", grid.resizeWindowWider)
hotkey.bind(mashResize, "H", grid.resizeWindowThinner)

-- Spotify
hs.hotkey.bind(mashGeneral, "P", hs.spotify.play)
hs.hotkey.bind(mashGeneral, "Y", hs.spotify.pause)
hs.hotkey.bind(mashGeneral, "T", hs.spotify.displayCurrentTrack)

-- Easy config reloading
reloader = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", function(files)
	doReload = false
	for _, file in pairs(files) do
		if file:sub(-4) == ".lua" then
			doReload = true
		end
	end
	if doReload then
		hs.reload()
	end
end)
reloader:start()

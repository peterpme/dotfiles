hs.loadSpoon("SpoonInstall")

local grid = require("hs.grid")
local hotkey = require("hs.hotkey")
local alert = require("hs.alert")

require("wifi")
require("session")
-- require("menubar")
-- require("crypto")
-- require("weather")

alert("Hammerspoon is locked and loaded", 1)
-- for i, screen in ipairs(hs.screen.allScreens()) do
-- 	alert("Screen " .. i, {}, screen:name())
-- end

grid.setGrid("16x4")
grid.setMargins("0x0")

-- Disable window animations (janky for iTerm)
hs.window.animationDuration = 0

spoon.SpoonInstall.repos.ShiftIt = {
	url = "https://github.com/peterklijn/hammerspoon-shiftit",
	desc = "ShiftIt spoon repository",
	branch = "master"
}

spoon.SpoonInstall:andUse("ShiftIt", {repo = "ShiftIt"})

spoon.ShiftIt:bindHotkeys(
	{
		left = {{"ctrl", "alt", "cmd"}, "h"},
		down = {{"ctrl", "alt", "cmd"}, "j"},
		up = {{"ctrl", "alt", "cmd"}, "k"},
		right = {{"ctrl", "alt", "cmd"}, "l"},
		upleft = {{"ctrl", "alt", "cmd"}, "u"},
		upright = {{"ctrl", "alt", "cmd"}, "i"},
		botleft = {{"ctrl", "alt", "cmd"}, "n"},
		botright = {{"ctrl", "alt", "cmd"}, "m"},
		maximum = {{"ctrl", "alt", "cmd"}, "o"}
	}
)

local mashGeneral = {
	"cmd",
	"ctrl"
}

local screenKeys = {
	"cmd",
	"ctrl",
	"shift"
}

-- Pushes windows to different screens
for screenIndex = 1, 3 do
	hotkey.bind(
		screenKeys,
		tostring(screenIndex),
		function()
			local win = hs.window.focusedWindow()
			local screen = hs.screen.allScreens()[screenIndex]

			win:moveToScreen(screen)
			win:setFrame(screen:frame())
		end
	)
end

-- lists each screen index (Screen 1, 2, 3, etc)
hotkey.bind(
	screenKeys,
	"S",
	function()
		for i, screen in ipairs(hs.screen.allScreens()) do
			alert("Screen " .. i, {}, screen)
		end
	end
)

-- Hammerspoon rep
hotkey.bind(mashGeneral, "C", hs.openConsole)

-- Easy config reloading
reloader =
	hs.pathwatcher.new(
	os.getenv("HOME") .. "/.hammerspoon/",
	function(files)
		doReload = false
		for _, file in pairs(files) do
			if file:sub(-4) == ".lua" then
				doReload = true
			end
		end
		if doReload then
			hs.reload()
		end
	end
)
reloader:start()

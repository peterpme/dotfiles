local hotkey = require "hs.hotkey"
local window = require "hs.window"
local screen = require "hs.screen"
local alert = require "hs.alert"
local keys = require "keys"

window.animationDuration = 0

function screenWatcher()
    print(table.show(hs.screen.allScreens(), "allScreens"))
    newNumberOfScreens = #hs.screen.allScreens()
end

screen.watcher.new(screenWatcher):start()

function alertCannotManipulateWindow()
  alert.show("Can't move window")
end

keys.bindKeyFor("Fullscreen window", function()
  local win = window.focusedWindow()
  if not win then
    alertCannotManipulateWindow()
    return
  end
  local screen = win:screen()
  local max = screen:frame()

  win:setFrame(max)
end)

keys.bindKeyFor("Center window", function()
  local win = window.focusedWindow()
  if not win then
    alertCannotManipulateWindow()
    return
  end
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  if max.x < 0 then
    -- If on screen on the left of the main display
    f.x = max.x + f.w / 2
  else
    f.x = (max.w - f.w) / 2
  end
  f.y = (max.h - f.h) / 2
  win:setFrame(f)
end)

keys.bindKeyFor("Left 50% window", function()
  local win = window.focusedWindow()
  if not win then
    alertCannotManipulateWindow()
    return
  end
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

keys.bindKeyFor("Right 50% window", function()
  local win = window.focusedWindow()
  if not win then
    alertCannotManipulateWindow()
    return
  end
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  if max.x < 0 then
    -- If on screen on the left of the main display
    f.x = max.x + max.w / 2
  else
    f.x = max.x2 / 2
  end
  f.y = max.y
  f.x2 = max.x2
  f.y2 = max.y2
  win:setFrame(f)
end)

keys.bindKeyFor("Top left 25% window", function()
  local win = window.focusedWindow()
  if not win then
    alertCannotManipulateWindow()
    return
  end
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h / 2
  win:setFrame(f)
end)

keys.bindKeyFor("Top right 25% window", function()
  local win = window.focusedWindow()
  if not win then
    alertCannotManipulateWindow()
    return
  end
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  if max.x < 0 then
    -- If on screen on the left of the main display
    f.x = max.x + max.w / 2
  else
    f.x = max.x2 / 2
  end
  f.y = max.y
  f.x2 = max.x2
  f.h = max.h / 2
  win:setFrame(f)
end)

keys.bindKeyFor("Bottom center 25% window", function()
  local win = window.focusedWindow()
  if not win then
    alertCannotManipulateWindow()
    return
  end
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  if max.x < 0 then
    -- If on screen on the left of the main display
    f.x = max.x + max.w / 4
  else
    f.x = max.x2 / 4
  end
  f.y = max.y2 / 2
  f.x2 = (max.x2 / 4) * 3
  f.y2 = max.y2
  win:setFrame(f)
end)

keys.bindKeyFor("Move window display left", function()
  local win = hs.window.focusedWindow()
  if not win then
    alertCannotManipulateWindow()
    return
  end
  win:moveOneScreenWest()
end)

keys.bindKeyFor("Move window display right", function()
  local win = hs.window.focusedWindow()
  if not win then
    alertCannotManipulateWindow()
    return
  end
  win:moveOneScreenEast()
end)

keys.bindKeyFor("Shrink window", function()
  local win = window.focusedWindow()
  if not win then
    alertCannotManipulateWindow()
    return
  end
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  if f.x + f.w >= (max.w - 5) then
    -- Aligned to the right
    f.w = f.w - 20
    f.x = max.w - f.w
  elseif (max.w - 10) <= (f.x * 2) + f.w then
    -- Center window shrinking
    f.w = f.w - 20
    f.x = (max.w - f.w) / 2
  else
    f.w = f.w - 20
  end

  win:setFrame(f)
end)

keys.bindKeyFor("Grow window", function()
  local win = window.focusedWindow()
  if not win then
    alertCannotManipulateWindow()
    return
  end
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  if f.x == 0 then
    -- Aligned to the left
    f.w = f.w + 20
  elseif f.x + f.w >= (max.w - 5) then
    -- Aligned to the right
    f.w = f.w + 20
    f.x = max.w - f.w
  elseif (max.w - 10) <= (f.x * 2) + f.w then
    -- Center window growing
    f.w = f.w + 20
    f.x = (max.w - f.w) / 2
  else
    -- Everywhere else
    f.w = f.w + 20
    f.x = f.x - 10
  end

  win:setFrame(f)
end)

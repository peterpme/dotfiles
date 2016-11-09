local hotkey = require "hs.hotkey"
local alert = require "hs.alert"

auto_hide = true
hotkey.bind({"cmd", "alt", "ctrl"}, "H", function()
  auto_hide = not auto_hide
  message = "Auto hide disabled"
  if auto_hide then
    message = "Auto hide enabled"
  end
  alert.show(message)
end)

auto_hide_applications = {"Finder", "Safari", "Telegram", "Tweetbot", "Wunderlist", "Calendar"}
watcher = hs.application.watcher.new(function(name, event, app)
  if auto_hide == false then
    return
  end

  for _, value in pairs(auto_hide_applications) do
    if name == value and event == hs.application.watcher.deactivated then
      app:hide()
    end
  end
end)
watcher:start()


local alert = require "hs.alert"

WiFiControl = {}

function WiFiControl.status()
  output = io.popen("networksetup -getairportpower en0", "r")
  result = output:read()
  return result:find(": On") and "on" or "off"
end

function WiFiControl.toggle()
  if WiFiControl.status() == "on" then
    alert.show("Wi-Fi: Off")
    os.execute("networksetup -setairportpower en0 off")
  else
    alert.show("Wi-Fi: On")
    os.execute("networksetup -setairportpower en0 on")
  end
end

return WiFiControl

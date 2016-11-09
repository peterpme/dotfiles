local alert = require "hs.alert"
local blueutil = "/usr/local/bin/blueutil"

BluetoothControl = {}

function BluetoothControl.status()
  output = io.popen(blueutil, "r")
  result = output:read()
  return result:find("Power: 1") and "on" or "off"
end

function BluetoothControl.toggle()
  if BluetoothControl.status() == "on" then
    alert.show("Bluetooth: Off")
    os.execute(blueutil.." power 0")
  else
    alert.show("Bluetooth: On")
    os.execute(blueutil.." power 1")
  end
end

return BluetoothControl

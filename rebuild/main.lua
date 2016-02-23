DEBUG = true
function debug_message(message)
  if DEBUG then
    print(message)
  end
  --TODO: rolling last 10
end

local yo = require('yo')
local server = require('server')
local read = require('read')

function wifi_setup(func, ...)
  wifi.setmode(wifi.STATIONAP)
  wifi.ap.config({
    ssid = "YoButton-" .. node.chipid(),
    pwd = "yobutton",
    max = 1,
    auth = wifi.AUTH_OPEN
  })
  wifi.ap.dhcp.start()

  func(...)
end

function wifi_default(func, ...)
  server.stop()
  wifi.setmode(wifi.STATION)

  func(...)
end

function short_press()
  wifi_default(yo.yo, read.yo_recipient(), read.api_key())
end

function long_press()
  wifi_setup(server.start)
end

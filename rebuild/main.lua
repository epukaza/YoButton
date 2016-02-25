DEBUG = true
TIMERS = {
  interrupt = 1
}
function debug_message(message)
  if DEBUG then
    print(message)
  end
  --TODO: rolling last 10
end

local yo = require('yo')
local server = require('server')
local read = require('read')
local button_pin = 6

function wifi_setup(func, ...)
  wifi.setmode(wifi.STATIONAP)
  wifi.ap.config({
    ssid = "YoButton-" .. node.chipid(),
    pwd = "yobutton",
    max = 1,
    auth = wifi.AUTH_OPEN
  })
  wifi.ap.dhcp.start()
  wifi.sleeptype(wifi.NONE_SLEEP)

  func(...)

  --TODO wifi_setup inactivity timeout
end

function wifi_default(func, ...)
  server.stop()
  wifi.setmode(wifi.STATION)
  wifi.sleeptype(wifi.NONE_SLEEP)

  func(...)

  wifi.sleeptype(wifi.MODEM_SLEEP)
end

function short_press()
  wifi_default(yo.yo, read.yo_recipient(), read.api_key())
end

function long_press()
  wifi_setup(server.start)
end

function short_or_long_press()
  local long_press_time = 3000 -- 3 seconds
  local level = gpio.read(button_pin)
  debug_message('short_or_long_press: ' .. level)

  if level == 1 then -- button depressed
    debug_message('short_or_long_press: pressed: start long press timer')
    tmr.alarm(TIMERS.interrupt, long_press_time, 0, function()
      debug_message('short_or_long_press: long press!')
      if server.is_serving() then
        debug_message('short_or_long_press: toggle setup OFF')
        short_press()
      else
        debug_message('short_or_long_press: toggle setup ON')
        long_press()
      end
    end)
  else -- button released
    debug_message('short_or_long_press: released: end long press timer')
    tmr.stop(TIMERS.interrupt)
    if not server.is_serving() then
      debug_message('short_or_long_press: short press!')
      short_press()
    end
  end
end

function debounce(func)
  local last = 0 --units: microseconds
  local delay = 50000 --units: microseconds

  return function(...)
    local now = tmr.now()
    if now - last < delay then
      tmr.stop(TIMERS.interrupt)
      debug_message("debounce: prevented extra push")
      return
    end

    last = now
    debug_message("debounce: succeed")
    return func(...)
  end
end

gpio.mode(button_pin, gpio.INT, gpio.FLOAT)
gpio.trig(button_pin, "both", debounce(short_or_long_press))

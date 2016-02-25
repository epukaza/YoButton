TIMERS = {
  interrupt = 0
  setup_timeout = 1
}

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

  --wifi_setup inactivity timeout: 5 minutes
  tmr.alarm(TIMERS.setup_timeout, 60*5*1000, wifi_default(function()
    return nil  --nil function to use decorator side effects: code smell
  end))

  func(...)

end

function wifi_default(func, ...)
  server.stop()
  wifi.setmode(wifi.STATION)
  wifi.sleeptype(wifi.NONE_SLEEP)

  func(...)

  wifi.sleeptype(wifi.MODEM_SLEEP)
end

function handle_short_press()
  wifi_default(yo.yo, read.yo_recipient(), read.api_key())
end

function handle_long_press()
  wifi_setup(server.start)
end

function handle_button_flip()
  local long_press_time = 3000 -- 3 seconds
  local level = gpio.read(button_pin)
  debug_message('handle_button_flip: ' .. level)

  if level == 1 then -- button depressed
    debug_message('handle_button_flip: pressed: start long press timer')
    tmr.alarm(TIMERS.interrupt, long_press_time, 0, function()
      debug_message('handle_button_flip: long press!')
      if server.is_serving() then
        debug_message('handle_button_flip: toggle setup OFF')
        handle_short_press()
      else
        debug_message('handle_button_flip: toggle setup ON')
        handle_long_press()
      end
    end)
  else -- button released
    debug_message('handle_button_flip: released: end long press timer')
    tmr.stop(TIMERS.interrupt)
    if not server.is_serving() then
      debug_message('handle_button_flip: short press!')
      handle_short_press()
    end
  end
end

function debounce(delay, func)
  local last = 0

  return function(...)
    local now = tmr.now()
    if now - last < delay then
      debug_message("debounce: prevent")
      return
    end

    last = now
    debug_message("debounce: allow")
    return func(...)
  end
end

handle_short_press = debounce(3000000, handle_short_press) --3 seconds
gpio.mode(button_pin, gpio.INT, gpio.FLOAT)
gpio.trig(button_pin, "both", debounce(50000, handle_button_flip)) --50 ms

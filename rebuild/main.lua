TIMERS = {
  interrupt = 0,
  setup_timeout = 1,
  led = 3
}

local button_pin = 6
local led_pin = 1
local yo = require('yo')
local server = require('server')
local led = require('led')
local read = require('read')

function setup_mode(func, ...)
  led.kill()
  led.q_heart_beat()

  wifi.setmode(wifi.STATIONAP)
  wifi.ap.config({
    ssid = "YoButton-" .. node.chipid(),
    pwd = "yobutton",
    auth = wifi.AUTH_OPEN,
    max = 1
  })
  wifi.ap.dhcp.start()
  wifi.sleeptype(wifi.NONE_SLEEP)

  --setup_mode inactivity timeout: 5 minutes
  tmr.alarm(TIMERS.setup_timeout, 60*5*1000, tmr.ALARM_SINGLE, function()
    default_mode(function()
      debug_message('setup_mode: timeout')
      return nil  --nil function to use decorator side effects: code smell
    end)
  end)

  func(...)
end

function default_mode(func, ...)
  led.kill()
  led.q_fade_in()
  server.stop()

  wifi.setmode(wifi.STATION)
  wifi.sleeptype(wifi.NONE_SLEEP)

  local success = func(...)

  debug_message(success)

  wifi.sleeptype(wifi.MODEM_SLEEP)
end


function handle_short_press()
  default_mode(yo.yo, read.yo_recipient(), read.api_key())
end

function handle_long_press()
  setup_mode(server.start)
end

function handle_button_flip()
  local long_press_time = 3000 -- 3 seconds
  local level = gpio.read(button_pin)
  debug_message('handle_button_flip: ' .. level)

  if level == 1 then -- button depressed
    debug_message('handle_button_flip: pressed: start long press timer')
    tmr.alarm(TIMERS.interrupt, long_press_time, tmr.ALARM_SINGLE, function()
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

wifi.setmode(wifi.STATION)
pwm.setduty(led_pin, 0)

handle_short_press = debounce(3000000, handle_short_press) --3 seconds
gpio.mode(button_pin, gpio.INT, gpio.FLOAT)
gpio.trig(button_pin, "both", debounce(50000, handle_button_flip)) --50 ms

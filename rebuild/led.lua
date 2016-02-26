--pin definitions, should we move it out to another module?
-- local led_pin = 1 --GPIO 5
local led_pin = 2 --nodeMCU LED
local override_pin = 4 --GPIO 4

--pattern definitions
local patterns = {
  STOPPED = 0,
  HEARTBEAT = 1,
  FADEIN = 2,
  FADEOUT = 3,
  TRIPLEBLINK = 4
}

--private constants
local HEARTBEAT_times = {40, 200, 40, 900} --format is alternating on and off times in ms
local TRIPLEBLINK_times = {100, 20, 100, 20, 100, 20, 100} --format is alternating off and on times in ms
local led_pwm_frequency = 500 --units: hz
local led_max_brightness = 1023

--state variables
local current_pattern
local pattern_queue = {}
local HEARTBEAT_index = 1
local TRIPLEBLINK_index = 1

--dependencies
local TIMER = TIMERS.led
local debug_message = debug_message
local gpio = gpio
local pwm = pwm
local tmr = tmr
local table = table

local print = print
module(...)

function testcall()
  do_pattern(patterns.FADEOUT)
end

function init(timer)
  debug_message('led.timer')
  --handle timer, take exclusive control
  TIMER = timer
  tmr.unregister(TIMER)

  --init pins
  gpio.mode(override_pin, gpio.OUTPUT)
  pwm.setup(led_pin, led_pwm_frequency, 0)
  pwm.start(led_pin)
  pwm.stop(led_pin)
  
  stop()
end

function stop()
  if(invalid_timer()) then
    print "Error, call led.init(TIMER) before calling any member functions"
    return
  end
  tmr.unregister(TIMER)

  --deassert control
  gpio.write(override_pin, gpio.LOW)

  current_pattern = patterns.STOPPED
  pattern_queue = {}
end

function do_pattern(pattern)
  debug_message('led.do_pattern: ' .. pattern)

  if(pattern == current_pattern) then
    --do nothing
    return
  end

  if not (current_pattern == patterns.STOPPED) then
    --put pattern in queue
    table.insert(pattern_queue, pattern)
  else

    debug_message('current, next: ' .. current_pattern .. ', ' .. pattern)
    --start pattern!
    current_pattern = pattern
  
    -- override_enable()
    gpio.write(override_pin, gpio.HIGH)

    pattern_funcs[current_pattern]()
  end
end

-- do patterns --
function do_FADEIN()
  debug_message('led.do_FADEIN')
  pwm.setduty(led_pin, 0)
  pwm.start(led_pin)
  FADEIN_update()
end

function do_FADEOUT()
  debug_message('led.do_FADEOUT')
  pwm.setduty(led_pin, led_max_brightness)
  pwm.start(led_pin)
  FADEOUT_update()
end

function do_HEARTBEAT()
  debug_message('led.do_HEARTBEAT')
  pwm.setduty(led_pin, 0)
  pwm.start(led_pin)
  HEARTBEAT_index = 1
  HEARTBEAT_update()
end

function do_TRIPLEBLINK()
  debug_message('led.do_TRIPLEBLINK')
  pwm.setduty(led_pin, led_max_brightness)
  pwm.start(led_pin)
  TRIPLEBLINK_index = 1
  TRIPLEBLINK_update()
end

pattern_funcs = {
  do_HEARTBEAT,
  do_FADEIN,
  do_FADEOUT,
  do_TRIPLEBLINK
}

-----------------------private functions-------------------------
function FADEIN_update()
  local current_brightness = pwm.getduty(led_pin)
  current_brightness = current_brightness + 1
  if(current_brightness > led_max_brightness) then
    current_brightness = led_max_brightness
  end
  pwm.setduty(led_pin, current_brightness)
  if current_brightness < led_max_brightness then
    tmr.alarm(TIMER, 2, tmr.ALARM_SINGLE, FADEIN_update)
  else
    end_pattern()
  end
end

function FADEOUT_update()
  local current_brightness = pwm.getduty(led_pin)
  current_brightness = current_brightness - 1
  if(current_brightness < 0) then
    current_brightness = 0
  end
  pwm.setduty(led_pin, current_brightness)
  if current_brightness > 0 then
    tmr.alarm(TIMER, 2, tmr.ALARM_SINGLE, FADEOUT_update)
  else
    end_pattern()
  end
end

function HEARTBEAT_update()
  local current_brightness = pwm.getduty(led_pin)
  current_brightness = led_max_brightness - current_brightness
  pwm.setduty(led_pin, current_brightness)
  tmr.alarm(TIMER, HEARTBEAT_times[HEARTBEAT_index], tmr.ALARM_SINGLE, HEARTBEAT_update)
  HEARTBEAT_index = HEARTBEAT_index + 1
  if HEARTBEAT_index > table.getn(HEARTBEAT_times) then
    HEARTBEAT_index = 1
  end
  --pattern does not end
end

function TRIPLEBLINK_update()
  local current_brightness = pwm.getduty(led_pin)
  current_brightness = led_max_brightness - current_brightness
  pwm.setduty(led_pin, current_brightness)
  tmr.alarm(TIMER, TRIPLEBLINK_times[TRIPLEBLINK_index], tmr.ALARM_SINGLE, TRIPLEBLINK_update)
  TRIPLEBLINK_index = TRIPLEBLINK_index + 1
  if TRIPLEBLINK_index > table.getn(TRIPLEBLINK_times) then
    end_pattern()
  end
end

function end_pattern()
  if table.getn(pattern_queue) == 0 then
    stop()
  else
    p = pattern_queue[1]
    table.remove(pattern_queue, 1)
    current_pattern = patterns.STOPPED
    tmr.unregister(TIMER)
    do_pattern(p)
  end
end

function invalid_timer()
  return (TIMER == nil or TIMER > 6)
end

init(TIMER)

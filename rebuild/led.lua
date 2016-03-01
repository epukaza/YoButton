-- local led_pin = 1 --GPIO 5
local led_pin = 1 --nodeMCU LED
local override_pin = 4 --GPIO 4

local HEARTBEAT_times = {40, 200, 40, 900} --format is alternating on and off times in ms
local TRIPLEBLINK_times = {100, 20, 100, 20, 100, 20, 100} --format is alternating off and on times in ms
local led_pwm_frequency = 500 --units: hz
local led_max_brightness = 1023
local current_pattern
local pattern_queue = {}
local HEARTBEAT_index = 1
local TRIPLEBLINK_index = 1

--pattern definitions
local patterns = {
  STOPPED = 0,
  HEARTBEAT = 1,
  FADEIN = 2,
  FADEOUT = 3,
  TRIPLEBLINK = 4
}

local patterns_initial_pwm_duty = {
  [0] = 0,
  0,
  0,
  led_max_brightness,
  led_max_brightness
}

local pattern_intervals = {
  [0] = 0,
  HEARTBEAT_times,
  1,
  1,
  TRIPLEBLINK_times
}

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
  do_pattern(patterns.FADEIN)
  do_pattern(patterns.FADEOUT)
end

function init()
  debug_message('led.init')

  --handle timer, take exclusive control
  tmr.unregister(TIMER)
  current_pattern = patterns.STOPPED

  --init pins
  gpio.mode(override_pin, gpio.OUTPUT)
  pwm.setup(led_pin, led_pwm_frequency, 0)
  pwm.start(led_pin)
  pwm.stop(led_pin)
end

function stop()
  tmr.unregister(TIMER)
  --deassert control
  gpio.write(override_pin, gpio.LOW)
  current_pattern = patterns.STOPPED
  pattern_queue = {}
end

function do_pattern(next_pattern)
  debug_message('led.do_pattern: ' .. next_pattern)

  if(next_pattern == current_pattern) then
    debug_message('led.do_pattern: next same as current')
    return
  end
  if current_pattern ~= patterns.STOPPED then
    debug_message('led.do_pattern: current not STOPPED')
    --put next_pattern in queue
    table.insert(pattern_queue, next_pattern)
  else
    debug_message('current, next: ' .. current_pattern .. ', ' .. next_pattern)
    --start next_pattern!
    current_pattern = next_pattern
    -- override_enable()
    gpio.write(override_pin, gpio.HIGH)

    pattern(
      patterns_initial_pwm_duty[next_pattern],
      pattern_intervals[next_pattern],
      next_pattern_funcs[next_pattern]
    )
  end

  --rewrite queue:
  --when queueing new pattern, if transition (or flag) not nil then do immediately
  --otherwise enqueue and let end_function or similar get next from queue

  --STOP should instead a pattern like all others, renamed as OFF

  --transition functions transition(t) --> t+1
  --if t+1 is nil, end pattern

end

--TODO: intervals not used (still using global state)
function pattern(initial_pwm_duty, intervals, transition)
  debug_message('led.pattern')
  pwm.setduty(led_pin, initial_pwm_duty)
  local pwm_duty = initial_pwm_duty

  --looping timer instead of alarm_single, can deregister on nil
  transition()
end

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

next_pattern_funcs = {
  HEARTBEAT_update,
  FADEIN_update,
  FADEOUT_update,
  TRIPLEBLINK_update
}

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

init(TIMER)

--pin definitions, should we move it out to another module?
local led_pin = 1 --GPIO 5  
local override_pin = 2 --GPIO 4

--pattern definitions
local STOPPED = 0
local HEARTBEAT = 1
local FADE_IN = 2
local FADE_OUT = 3
local TRIPLE_BLINK = 4

--private constants
local heartbeat_times = {40, 200, 40, 900} --format is alternating on and off times in ms
local triple_blink_times = {100, 20, 100, 20, 100, 20, 100} --format is alternating off and on times in ms
local timer_id = nil --"constant"
local led_pwm_frequency = 500 --units: hz
local led_max_brightness = 1023

--state variables
local current_pattern
local pattern_queue = {}
local heartbeat_index = 1
local triple_blink_index = 1

--function declarations
local init = nil
local stop = nil
local do_pattern = nil
local fade_in_update = nil
local fade_out_update = nil
local heartbeat_update = nil
local triple_blink_update = nil
local end_pattern = nil
local override_enable = nil
local override_disable = nil
local invalid_timer = nil

-----------------------public functions------------------------------
function init(timer)
  --handle timer, take exclusive control
  timer_id = timer
  tmr.unregister(timer_id)

  --init pins
  gpio.mode(override_pin, gpio.OUTPUT)
  pwm.setup(led_pin, led_pwm_frequency, 0)
  pwm.start(led_pin)
  pwm.stop(led_pin)
  
  stop()
end

function stop()
  if(invalid_timer()) then
    print "Error, call led.init(timer_id) before calling any member functions"
    return
  end
  tmr.unregister(timer_id)
  --deassert control
  override_disable()
  --stop pwm
  --pwm.stop(led_pin)
  current_pattern = STOPPED
  pattern_queue = {}
end

function do_pattern(pattern)
  if(invalid_timer()) then
    print "Error, call led.init(timer_id) before calling any member functions"
    return
  end

  --TODO: CONFIRM VALID PATTERN
  --if(not is_valid_pattern(pattern))

  if(pattern == current_pattern) then
    --do nothing
    return
  end

  if not (current_pattern == STOPPED) then
    --put pattern in queue
    table.insert(pattern_queue, pattern)
  else
    --start pattern!
    current_pattern = pattern
    override_enable()

    --if train could be optimized with else's but this is more readable
    if(current_pattern == FADE_IN) then
      pwm.setduty(led_pin, 0)
      pwm.start(led_pin)
      fade_in_update()
    end
    if(current_pattern == FADE_OUT) then
      pwm.setduty(led_pin, led_max_brightness)
      pwm.start(led_pin)
      fade_out_update()
    end
    if(current_pattern == HEARTBEAT) then
      pwm.setduty(led_pin, 0)
      pwm.start(led_pin)
      heartbeat_index = 1
      heartbeat_update()
    end
    if(current_pattern == TRIPLE_BLINK) then
      pwm.setduty(led_pin, led_max_brightness)
      pwm.start(led_pin)
      triple_blink_index = 1
      triple_blink_update()
    end
  end
end

-----------------------private functions-------------------------
function fade_in_update()
  local current_brightness = pwm.getduty(led_pin)
  current_brightness = current_brightness + 1
  if(current_brightness > led_max_brightness) then
    current_brightness = led_max_brightness
  end
  pwm.setduty(led_pin, current_brightness)
  if current_brightness < led_max_brightness then
    tmr.alarm(timer_id, 2, tmr.ALARM_SINGLE, fade_in_update)
  else
    end_pattern()
  end
end

function fade_out_update()
  local current_brightness = pwm.getduty(led_pin)
  current_brightness = current_brightness - 1
  if(current_brightness < 0) then
    current_brightness = 0
  end
  pwm.setduty(led_pin, current_brightness)
  if current_brightness > 0 then
    tmr.alarm(timer_id, 2, tmr.ALARM_SINGLE, fade_out_update)
  else
    end_pattern()
  end
end

function heartbeat_update()
  local current_brightness = pwm.getduty(led_pin)
  current_brightness = led_max_brightness - current_brightness
  pwm.setduty(led_pin, current_brightness)
  tmr.alarm(timer_id, heartbeat_times[heartbeat_index], tmr.ALARM_SINGLE, heartbeat_update)
  heartbeat_index = heartbeat_index + 1
  if heartbeat_index > table.getn(heartbeat_times) then
    heartbeat_index = 1
  end
  --pattern does not end
end

function triple_blink_update()
  local current_brightness = pwm.getduty(led_pin)
  current_brightness = led_max_brightness - current_brightness
  pwm.setduty(led_pin, current_brightness)
  tmr.alarm(timer_id, triple_blink_times[triple_blink_index], tmr.ALARM_SINGLE, triple_blink_update)
  triple_blink_index = triple_blink_index + 1
  if triple_blink_index > table.getn(triple_blink_times) then
    end_pattern()
  end
end

function end_pattern()
  if table.getn(pattern_queue) == 0 then
    stop()
  else
    p = pattern_queue[1]
    table.remove(pattern_queue, 1)
    current_pattern = STOPPED
    tmr.unregister(timer_id)
    do_pattern(p)
  end
end

function override_enable()
  gpio.write(override_pin, gpio.HIGH)
end

function override_disable()
  gpio.write(override_pin, gpio.LOW)
end

function invalid_timer()
  return (timer_id == nil or timer_id > 6)
end

return {
  init = init,
  stop = stop,
  do_pattern = do_pattern,
  HEARTBEAT = HEARTBEAT,
  FADE_IN = FADE_IN,
  FADE_OUT = FADE_OUT,
  TRIPLE_BLINK = TRIPLE_BLINK,
}

local LED_PIN = 1
local OVERRIDE_PIN = 4
local MAX_BRIGHTNESS = 1023
local HEART_BEAT_IDX = 1
local TRIPLE_BLINK_IDX = 1
local TIMER = TIMERS.led
local Q = {}

local debug_message = debug_message
local gpio = gpio
local pwm = pwm
local tmr = tmr
local table = table
local next = next

module(...)

local function init()
  debug_message('led.init')

  --handle timer, take exclusive control
  tmr.unregister(TIMER)

  --init pins
  gpio.mode(OVERRIDE_PIN, gpio.OUTPUT)
  pwm.setup(LED_PIN, 500, 0)
  pwm.start(LED_PIN)
  pwm.stop(LED_PIN)
end

local function enqueue(pattern)
  return function()
    table.insert(Q, pattern)
    if not tmr.state(TIMER) then
      next_pattern()
    end
  end
end

local function fade_in()
  local current_brightness = pwm.getduty(LED_PIN)

  if current_brightness < MAX_BRIGHTNESS then
    current_brightness = current_brightness + 1
    pwm.setduty(LED_PIN, current_brightness)
    tmr.alarm(TIMER, 2, tmr.ALARM_SINGLE, fade_in)
  else
    next_pattern()
  end
end

local function fade_out()
  local current_brightness = pwm.getduty(LED_PIN)

  if current_brightness > 0 then
    current_brightness = current_brightness - 1
    pwm.setduty(LED_PIN, current_brightness)
    tmr.alarm(TIMER, 2, tmr.ALARM_SINGLE, fade_out)
  else
    next_pattern()
  end
end

local function heart_beat()
  local intervals = {40, 200, 40, 900} --alternating, millisec
  local current_brightness = pwm.getduty(LED_PIN)

  current_brightness = MAX_BRIGHTNESS - current_brightness
  pwm.setduty(LED_PIN, current_brightness)

  tmr.alarm(TIMER, intervals[HEART_BEAT_IDX], tmr.ALARM_SINGLE, heart_beat)

  HEART_BEAT_IDX = HEART_BEAT_IDX + 1
  if HEART_BEAT_IDX > table.getn(intervals) then
    HEART_BEAT_IDX = 1
  end
  -- must call next_pattern() yourself
end

local function triple_blink()
  local intervals =  {200, 50, 200, 50, 200, 50, 200} --alternating, millisec

  local current_brightness = pwm.getduty(LED_PIN)
  current_brightness = MAX_BRIGHTNESS - current_brightness
  pwm.setduty(LED_PIN, current_brightness)
  
  TRIPLE_BLINK_IDX = TRIPLE_BLINK_IDX + 1
  if TRIPLE_BLINK_IDX > table.getn(intervals) then
    TRIPLE_BLINK_IDX = 1
    pwm.setduty(LED_PIN, 0)
    next_pattern()
  else
    tmr.alarm(TIMER, intervals[TRIPLE_BLINK_IDX], tmr.ALARM_SINGLE, triple_blink)
  end
end

-- interface --
q_fade_in = enqueue(fade_in)
q_fade_out = enqueue(fade_out)
q_heart_beat = enqueue(heart_beat)
q_triple_blink = enqueue(triple_blink)

function next_pattern()
  tmr.unregister(TIMER)
  if next(Q) then
    local next_p = table.remove(Q, 1) -- how expensive is this?
    next_p()
  else
  end
end

function kill()
  Q = {}
  tmr.unregister(TIMER)
  pwm.setduty(LED_PIN, 0)
end

init(TIMER)

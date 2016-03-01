local LED_PIN = 1
local OVERRIDE_PIN = 4
local MAX_BRIGHTNESS = 1023
local HEART_BEAT_IDX = 1
local TRIPLE_BLINK_IDX = 1
local TIMER = TIMERS.led
local IS_FADE_IN = false

local debug_message = debug_message
local gpio = gpio
local pwm = pwm
local tmr = tmr
local table = table

module(...)

function init()
  debug_message('led.init')

  --handle timer, take exclusive control
  tmr.unregister(TIMER)

  --init pins
  gpio.mode(OVERRIDE_PIN, gpio.OUTPUT)
  pwm.setup(LED_PIN, 500, 0)
  pwm.start(LED_PIN)
  pwm.stop(LED_PIN)
end

function pattern(start_duty, )

function fade_in()
  IS_FADE_IN = true
  local current_brightness = pwm.getduty(LED_PIN)
  current_brightness = current_brightness + 1
  if(current_brightness > MAX_BRIGHTNESS) then
    current_brightness = MAX_BRIGHTNESS
  end
  pwm.setduty(LED_PIN, current_brightness)

  if current_brightness < MAX_BRIGHTNESS then
    tmr.alarm(TIMER, 2, tmr.ALARM_SINGLE, fade_in)
  else
    IS_FADE_IN = false
  end
end

function fade_out()
  local current_brightness = pwm.getduty(LED_PIN)
  current_brightness = current_brightness - 1
  if(current_brightness < 0) then
    current_brightness = 0
  end
  pwm.setduty(LED_PIN, current_brightness)

  if current_brightness > 0 then
    tmr.alarm(TIMER, 2, tmr.ALARM_SINGLE, fade_out)
  end
end

function heart_beat()
  local intervals = {40, 200, 40, 900} --alternating, millisec
  local current_brightness = pwm.getduty(LED_PIN)
  current_brightness = MAX_BRIGHTNESS - current_brightness
  pwm.setduty(LED_PIN, current_brightness)
  
  --endless
  tmr.alarm(TIMER, intervals[HEART_BEAT_IDX], tmr.ALARM_SINGLE, heart_beat)

  HEART_BEAT_IDX = HEART_BEAT_IDX + 1
  if HEART_BEAT_IDX > table.getn(intervals) then
    HEART_BEAT_IDX = 1
  end
end

function triple_blink()
  local intervals =  {100, 20, 100, 20, 100, 20, 100} --alternating, millisec

  local current_brightness = pwm.getduty(LED_PIN)
  current_brightness = MAX_BRIGHTNESS - current_brightness
  pwm.setduty(LED_PIN, current_brightness)
  
  TRIPLE_BLINK_IDX = TRIPLE_BLINK_IDX + 1
  if TRIPLE_BLINK_IDX > table.getn(intervals) then
    TRIPLE_BLINK_IDX = 1
    pwm.setduty(LED_PIN, 0)
  else
    tmr.alarm(TIMER, intervals[TRIPLE_BLINK_IDX], tmr.ALARM_SINGLE, triple_blink)
  end
end

function is_fade_in() return IS_FADE_IN end

init(TIMER)

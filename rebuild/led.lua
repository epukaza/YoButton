local LED_PIN = 1
local MAX_DUTY = 1023
local HEART_BEAT_IDX = 1
local TRIPLE_BLINK_IDX = 1
local TIMER = TIMERS.led
local Q = {}

local debug_message = debug_message
local pwm = pwm
local tmr = tmr
local table = table
local next = next

local tostring = tostring
local print = print
local pairs = pairs

module(...)

local function init()
  debug_message('led.init')

  --handle timer, take exclusive control
  tmr.unregister(TIMER)
  --init pins
  pwm.setup(LED_PIN, 500, 0)
  pwm.start(LED_PIN)
  pwm.stop(LED_PIN)
end

-- params must contain duty and interval
function pattern(params, trans_func)
  local params = params 

  debug_message('pattern')
  for k,v in pairs(params) do print(k,v) end

  function callback()
    if params and params.duty ~= nil then
      pwm.setduty(LED_PIN, params.duty)
      tmr.alarm(TIMER, params.interval, tmr.ALARM_SINGLE, callback)
      params = trans_func(params)
    else
      next_pattern()
    end
  end

  return callback
end

function enqueue(pattern)
  debug_message('enqueue')
  for k,v in pairs(Q) do print(k,v) end
  table.insert(Q, pattern)
  -- debug_message('tmr.state ' .. tostring(tmr.state(TIMER)))
  -- if not tmr.state(TIMER) then
  --   next_pattern()
  -- end
end

function next_pattern()
  debug_message('next_pattern')
  if next(Q) then
    debug_message('has next')

    local next_p = table.remove(Q, 1) -- how expensive is this?
    next_p()
  end
end

function kill()
  Q = {}
  tmr.unregister(TIMER)
  pwm.setduty(LED_PIN, 0)
end








-- built-in conveniences specific to Yo Button
function q_fade_in()
  local params = {interval=2, duty=0}
  local transition = function(params)
    if params.duty >= 1023 then
      return nil
    else
      params.duty = params.duty + 1
      return params
    end      
  end

  enqueue(pattern(params, transition))
end

function q_fade_out()
  local params = {interval=2, duty=MAX_DUTY}
  local transition = function(params)
    if params.duty <= 0 then
      return nil
    else
      params.duty = params.duty - 1
      return params
    end      
  end

  enqueue(pattern(params, transition))
end

-- local function fade_in()
--   local current_brightness = pwm.getduty(LED_PIN)

--   if current_brightness < MAX_DUTY then
--     current_brightness = current_brightness + 1
--     pwm.setduty(LED_PIN, current_brightness)
--     tmr.alarm(TIMER, 2, tmr.ALARM_SINGLE, fade_in)
--   else
--     next_pattern()
--   end
-- end

-- local function fade_out()
--   local current_brightness = pwm.getduty(LED_PIN)

--   if current_brightness > 0 then
--     current_brightness = current_brightness - 1
--     pwm.setduty(LED_PIN, current_brightness)
--     tmr.alarm(TIMER, 2, tmr.ALARM_SINGLE, fade_out)
--   else
--     next_pattern()
--   end
-- end

-- local function heart_beat()
--   local intervals = {40, 200, 40, 900} --alternating, millisec
--   local current_brightness = pwm.getduty(LED_PIN)

--   current_brightness = MAX_DUTY - current_brightness
--   pwm.setduty(LED_PIN, current_brightness)

--   tmr.alarm(TIMER, intervals[HEART_BEAT_IDX], tmr.ALARM_SINGLE, heart_beat)

--   HEART_BEAT_IDX = HEART_BEAT_IDX + 1
--   if HEART_BEAT_IDX > table.getn(intervals) then
--     HEART_BEAT_IDX = 1
--   end
--   -- must call next_pattern() yourself
-- end

-- local function triple_blink()
--   local intervals =  {200, 50, 200, 50, 200, 50, 200} --alternating, millisec

--   local current_brightness = pwm.getduty(LED_PIN)
--   current_brightness = MAX_DUTY - current_brightness
--   pwm.setduty(LED_PIN, current_brightness)
  
--   TRIPLE_BLINK_IDX = TRIPLE_BLINK_IDX + 1
--   if TRIPLE_BLINK_IDX > table.getn(intervals) then
--     TRIPLE_BLINK_IDX = 1
--     pwm.setduty(LED_PIN, 0)
--     next_pattern()
--   else
--     tmr.alarm(TIMER, intervals[TRIPLE_BLINK_IDX], tmr.ALARM_SINGLE, triple_blink)
--   end
-- end

-- interface --
-- q_fade_in = enqueue(fade_in)
-- q_fade_out = enqueue(fade_out)
-- q_heart_beat = enqueue(heart_beat)
-- q_triple_blink = enqueue(triple_blink)

init(TIMER)

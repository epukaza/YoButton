local LED_PIN = 1
local MAX_DUTY = 1023
local TIMER = TIMERS.led
local Q = {}

local debug_message = debug_message
local pwm = pwm
local tmr = tmr
local table = table
local next = next

module(...)

local function init()
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
  local callback = nil

  callback = function()
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

function next_pattern()
  debug_message('next_pattern')
  if next(Q) then
    debug_message('has next')

    local next_p = table.remove(Q, 1) -- how expensive is this?
    next_p()
  end
end

function enqueue(pattern)
  debug_message('enqueue')
  table.insert(Q, pattern)
  if not tmr.state(TIMER) then
    next_pattern()
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

function q_triple_blink()
  local params = {interval=50, duty=MAX_DUTY, reps = 3}

  local transition = function(params)
    if params.reps <= 0 then
      return nil
    elseif params.interval == 50 then
      params.interval = 200
      params.duty = 0
      params.reps = params.reps - 1
    else
      params.interval = 50
      params.duty = MAX_DUTY
    end

    return params
  end

  enqueue(pattern(params, transition))
end

function q_heart_beat()
  local params = {interval=40, duty=MAX_DUTY, index = 1}

  local transition = function(params)
    local intervals = {40, 200, 40, 900}

    params.index = params.index + 1
    if params.index > 4 then
      params.index = 1
    end

    params.interval = intervals[params.index]
    params.duty = (params.index % 2) * MAX_DUTY

    return params
  end

  enqueue(pattern(params, transition))
end

init(TIMER)

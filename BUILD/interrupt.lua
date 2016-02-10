local longPress = 3000 -- 3 seconds

function shortOrLongPress()
  local level = gpio.read(buttonPin)

  debugMsg('The pin value has changed to '..gpio.read(buttonPin))
  debugMsg("detected level " .. level)

  if level == 1 then -- button depressed
    debugMsg("LONG PRESS TIMER START")
    tmr.alarm(INTERRUPT_TIMER, longPress, 0, function()
      debugMsg("LONG PRESS")
      dofile('wifiSetup.lua')
    end)
  else -- button released
    debugMsg("SETUP STATUS " .. tostring(SETUP))
    tmr.stop(INTERRUPT_TIMER)
    if not SETUP then
      debugMsg("SHORT PRESS")
      dofile('sendYo.lua')
    end
  end
end

function debounce (func)
  local last = 0 --units: microseconds
  local delay = 200000 --units: microseconds

  return function (...)
    local now = tmr.now()
    if now - last < delay then
      tmr.stop(INTERRUPT_TIMER)
      debugMsg("DEBOUNCE PREVENTED EXTRA PRESS")
      if not SETUP then
        debugMsg("DEBOUNCE INTERPRETED AS SHORT PRESS")
        dofile('sendYo.lua')
      end
      return
    end

    last = now
    debugMsg("PRESS")
    return func(...)
  end
end

gpio.mode(buttonPin, gpio.INT, gpio.FLOAT)
gpio.trig(buttonPin, "both", debounce(shortOrLongPress))
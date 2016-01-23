-- using timer 5 for short/long press detection
longPress = 3000 -- 3 seconds
buttonPin = 6 -- GPIO6
DEBUG = true
SETUP = false

function debugMsg(msg)
  if DEBUG then
    print(msg)
  end
end

function shortOrLongPress()
  level = gpio.read(buttonPin)

  debugMsg('The pin value has changed to '..gpio.read(buttonPin))
  debugMsg("detected level " .. level)

  if level == 0 then -- button depressed
    debugMsg("LONG PRESS TIMER START")
    tmr.alarm(5, longPress, 0, function()
                                 debugMsg("LONG PRESS")
                                 dofile('wifiSetup.lua')
                               end)
  else -- button released
    debugMsg("SETUP STATUS " .. tostring(SETUP))
    tmr.stop(5)
    if not SETUP then
      debugMsg("SHORT PRESS")
      dofile('sendYo.lua')
    end
  end
end

function debounce (func)
  local last = 0
  local delay = 100000

  return function (...)
    local now = tmr.now()
    if now - last < delay then
      tmr.stop(5)
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

gpio.mode(buttonPin, gpio.INT, gpio.PULLUP)
gpio.trig(buttonPin, "both", debounce(shortOrLongPress))
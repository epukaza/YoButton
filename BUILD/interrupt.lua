-- using timer 5 for short/long press detection
longPress = 3000 -- 3 seconds
buttonPin = 6 -- GPIO6
DEBUG = false

function debugMsg(msg)
  if DEBUG then
    print(msg)
  end
end

function shortOrLongPress()
  debugMsg('The pin value has changed to '..gpio.read(buttonPin))
  debugMsg("detected level " .. level)

  level = gpio.read(buttonPin)
  if level == 0 then -- button depressed
    debugMsg("LONG PRESS TIMER START")
    tmr.alarm(5, longPress, 0, function()
                                 if DEBUG then
                                  print("LONG PRESS")
                                 end 
                                 dofile('wifiSetup.lua')
                               end)
  else -- button released
    tmr.stop(5)
    debugMsg("SHORT PRESS")
    dofile('sendYo.lua')
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
      debugMsg("DEBOUNCE INTERPRETED AS SHORT PRESS")
      dofile('sendYo.lua')
      return
    end

    last = now
    debugMsg("PRESS")
    return func(...)
  end
end

gpio.mode(buttonPin, gpio.INT, gpio.PULLUP)
gpio.trig(buttonPin, "both", debounce(shortOrLongPress))
gpio.mode(6, gpio.INT, gpio.PULLUP)
delay = 0
setupStarted = 0
function buttonHandler(level)
   x = tmr.now()
   if x > delay then
   	  --button has been debounced
      delay = tmr.now()+50000
      tmr.delay(2000)
      level = gpio.read(6)
      print("handler called with level: "..level)
      if level == 0 then
      	--button pressed down initially
      	tmr.alarm(4, 2000, 0, function()
			setupStarted = 1
			dofile("wifiSetup.lua")
			end
		)
	  else
	    tmr.stop(4)
		--button released
		if setupStarted == 0 then
  	      dofile("sendYo.lua")
        end
      end
   end
end

gpio.trig(6, "both",buttonHandler)
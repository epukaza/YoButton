gpio.mode(4, gpio.INT, gpio.PULLUP)
delay = 0
setupStarted = 0
function buttonHandler(level)
   x = tmr.now()
   if x > delay then
   	  --button has been debounced
   	  print("handler called with level: "..level)
      delay = tmr.now()+50000
      if level == 1 then
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

gpio.trig(4, "both",buttonHandler)

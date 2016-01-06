gpio.mode(3, gpio.INT, gpio.FLOAT)
delay = 0

function sendYo(level)
   x = tmr.now()
   if x > delay then
      delay = tmr.now()+250000
      dofile("sendYo.lua")
      end
   end
gpio.trig(3, "down",sendYo)

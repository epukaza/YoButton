DEBUG = true
function debug_message(message)
  if DEBUG then
    print(message)
  end
  --TODO: rolling last 10
end

local yo = require('yo')
local server = require('server')
local read = require('read')


a = '0c6ac771-71fa-420f-810c-2853989a8ca6'
y = 'ariyeah'
wifi.sta.config('Pizza Pirate Cove', 'pizzapirates')
wifi.setmode(wifi.STATION)

function short_press()
  server.stop()
  yo.yo(y, a)
end

function long_press()


  server.start()
end

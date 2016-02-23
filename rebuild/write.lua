local wifi = wifi
local file = file
local assert = assert
local type = type
local yo_file = 'yorecipient.txt'
local debug_message = debug_message

--TODO: validate ALL THE THINGS!
module(...)

function yo_recipient(value)
  --TODO strip all non-alphanumeric
  assert(type(value) == 'string')
  file.open(yo_file, 'w+')
  file.write(value)
  file.close()
end

function new_settings(settings)
  --TODO 1-7 length passwords --> ''
  --TODO strip all invalid SSID,pw chars
  assert(type(settings.ssid) == 'string', 'ssid must be a string')
  assert(type(settings.password) == 'string', 'password must be a string')
  assert(type(settings.yo_to) == 'string', 'yo_to must be a string')

  yo_recipient(settings.yo_to)
  wifi.sta.config(settings.ssid, settings.password)
end

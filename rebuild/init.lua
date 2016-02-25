DEBUG = true

function debug_message(message)
  if DEBUG then
    print(message)
  end
  --TODO: rolling last 10
end

if DEBUG then
  debug_message('1 second startup delay on timer 0 ...')
  tmr.alarm(0, 1000, 0, function()
    dofile('main.lua')
  end)
else
  dofile('main.lua')
end
DEBUG = false

function debug_message(message)
  if DEBUG then
    print(message)
  end
  --TODO: rolling last 10
end

if DEBUG then
  debug_message('1 second startup delay on timer 0 ...')
  tmr.alarm(0, 1000, 0, function()
    if file.exists('main.lc') then
      dofile('main.lc')
    else
      dofile('main.lua')
    end
  end)
else
  if file.exists('main.lc') then
    dofile('main.lc')
  else
    dofile('main.lua')
  end
end
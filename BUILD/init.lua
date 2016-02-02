startupDelayTimer = 1
print("3 second startup delay using timer " .. startupDelayTimer .. '...')
tmr.alarm(startupDelayTimer, 3000, 0, function ()
  print("Starting.")
  dofile("interrupt.lua")
end)
tmr.alarm(1, 3000, 0, 

function ()
	print("Starting delayedInit")
	dofile("interrupt.lua")
end
)
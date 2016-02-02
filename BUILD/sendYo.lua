--This code assumes that the WIFI AP has already been set up
file.open("yorecipient.txt", "r")
print("sending yo to "..file.readline())
file.close()
wifi.sleeptype(wifi.NONE_SLEEP)
wifi.setmode(wifi.STATION)

function generateContentString()
	file.open("yorecipient.txt", "r")
	return "api_token=0c6ac771-71fa-420f-810c-2853989a8ca6&username="..string.upper(file.readline())
end

local contentString = generateContentString()
local contentLength = string.len(contentString)

http.post(
	'https://api.justyo.co/yo/',
	'Content-Type: application/x-www-form-urlencoded\r\n'..
	'Content-length: ' ..contentLength.. '\r\n',
	contentString,
	function(code, data)
		debugMsg("POST REQUEST CALLBACK")
		debugMsg("code: " .. code)
		debugMsg("data: " .. data)
		wifi.sleeptype(wifi.LIGHT_SLEEP)
	end
)
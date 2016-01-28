--This code assumes that the WIFI AP has already been set up
file.open("yorecipient.txt", "r")
print("sending yo to "..file.readline())
file.close()
wifi.sleeptype(wifi.NONE_SLEEP)

function generateContentString()
	file.open("yorecipient.txt", "r")
	return "api_token=0c6ac771-71fa-420f-810c-2853989a8ca6&username="..string.upper(file.readline())
end

wifi.setmode(wifi.STATION)

contentString = generateContentString()
contentLength = string.len(contentString)
http.post(
	'https://api.justyo.co/yo/',
	'Content-Type: application/x-www-form-urlencoded\r\n'..
	'Content-length: ' ..contentLength.. '\r\n',
	contentString,
	function(code, data)
		print("POST REQUEST CALLBACK")
		print("code: ", code)
		print("data: ", data)
		wifi.sleeptype(wifi.MODEM_SLEEP)
	end
)
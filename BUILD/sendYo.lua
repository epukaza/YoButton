wifi.sleeptype(wifi.NONE_SLEEP)
wifi.setmode(wifi.STATION)

if YO_RECIPIENT then
	debugMsg('sending yo to ' .. YO_RECIPIENT)
	local contentString = "api_token=0c6ac771-71fa-420f-810c-2853989a8ca6&username="..string.upper(YO_RECIPIENT)
	local contentLength = string.len(contentString)

	http.post(
		'https://api.justyo.co/yo/',
		'Content-Type: application/x-www-form-urlencoded\r\n'..
		'Content-length: ' .. contentLength .. '\r\n',
		contentString,
		function(code, data)
			debugMsg("POST REQUEST CALLBACK")
			debugMsg("code: " .. code)
			debugMsg("data: " .. data)
			wifi.sleeptype(wifi.LIGHT_SLEEP)
		end
	)
else
	debugMsg("Yo not sent - invalid YO_RECIPIENT")
end

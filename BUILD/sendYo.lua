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
sk = nil
sk = net.createConnection(net.TCP,0)
sk:on("receive", function(sck, c)
    print(c)
    wifi.sleeptype(wifi.MODEM_SLEEP)
    end)
    
sk:on("connection", function(sk, payload)
						contentString = generateContentString()
						strlen = string.len(contentString)
						sk:send("POST /yo/ HTTP/1.1\r\n"
							.."Host: api.justyo.co\r\n"
							.."Connection: close\r\n"
							.."Content-Length: "..strlen.."\r\n"
							.."Accept: */*\r\n"
							.."Content-type: application/x-www-form-urlencoded\r\n\r\n"
							..contentString)
					end)
sk:connect(80, "api.justyo.co")

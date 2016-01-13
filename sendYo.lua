--This code assumes that the WIFI AP has already been set up
file.open("yorecipient.txt", "r")
print("sending yo to "..file.readline())
file.close()

function generateContentString()
	file.open("yorecipient.txt", "r")
	return "api_token=99c680b7-5f9f-48fd-9459-46cda7e1c8fa&username="..string.upper(file.readline())
end


sk = nil
sk = net.createConnection(net.TCP,0)
sk:on("receive", function(sck, c) print(c) end )
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

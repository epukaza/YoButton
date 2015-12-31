--This code assumes that the WIFI AP has already been set up
sk=net.createConnection(net.TCP,0)
sk:on("receive", function(sck, c) print(c) end )
sk:connect(80, "api.justyo.co")
sk:send("POST /yo/ HTTP/1.1\r\nHost: api.justyo.co\r\nConnection: close\r\nContent-Length: 63\r\nAccept: */*\r\nContent-type: application/x-www-form-urlencoded\r\n\r\napi_token=5f9f-99c680b7-48fd-9459-46cda7e1c8fa&username=ARIYEAH")
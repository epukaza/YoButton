function startSetup()
  print("Button press registered")
  wifi.sta.disconnect()
  print("Wifi disconnected")
  wifi.setmode(wifi.STATIONAP)
  stationConfig = {}
  stationConfig.ssid = "YoButtonSetup"
  stationConfig.pwd = "password"
  stationConfig.auth = wifi.OPEN
  wifi.ap.config(stationConfig)
  wifi.ap.dhcp.start()
  print("Wifi station set up")
  setupServerResponses()
end

function updateWithNewValues(payload)
      ssidIndex = {payload:find("newssid=")}
      passIndex = {payload:find("&newpass=")}
      recipientIndex = {payload:find("&newrecipient=")}
      submitIndex = {payload:find("&Submit=")}

      if(ssidIndex[1]~=nil and payload:find("?")~=nil) then
        print(ssidIndex[1]..", "..ssidIndex[2])
        print(passIndex[1]..", "..passIndex[2])
        print(recipientIndex[1]..", "..recipientIndex[2])
        print(submitIndex[1]..", "..submitIndex[2])
        newssid = string.gsub(string.sub(payload, ssidIndex[2]+1, passIndex[1]-1), "+", " ")
        newpassword = string.gsub(string.sub(payload, passIndex[2]+1, recipientIndex[1]-1), "+", " ")
        newrecipient = string.upper(string.sub(payload, recipientIndex[2]+1, submitIndex[1]-1))
        print(newssid)
        print(newpassword)
        print(newrecipient)
        wifi.sta.config(newssid, newpassword)
        file.open("yorecipient.txt", "w+")
        file.write(newrecipient)
        file.close()
      end
end

function setupServerResponses()
  if(srv~=nil) then
    srv:close()
    srv=nil
  end
  srv=net.createServer(net.TCP)
  srv:listen(80,function(conn)
    conn:on("receive",function(conn,payload)
      print("request received")
      ind = {string.find(payload, "\n")}
      if(ind[1] ~= nil)then
        payload = string.sub(payload, 1, ind[1])
      end
      print(payload)
      updateWithNewValues(payload)

      file.open("yorecipient.txt", "r")
      recipient = string.gsub(file.readline(), "\n", "", 1)
      file.close()

      ssid, password = wifi.sta.getconfig()
      ip = wifi.sta.getip()
      if(ip==nil) then
        ip="0.0.0.0"
      end
      conn:send("<body><h1>YO Button setup</h1>")
      conn:send("Current wifi SSID: <br>")
      conn:send("<input type=\"text\" value=\""..ssid .."\" readonly><br>")
      conn:send("Current wifi password: <br>")
      conn:send("<input type=\"text\" value=\""..password .."\" readonly><br>")
      conn:send("Yo Button's IP address: <br>")
      conn:send("<input type=\"text\" value=\""..ip.."\" readonly><br>")
      conn:send("Yo recipient: <br>")
      conn:send("<input type=\"text\" value=\""..recipient.."\" readonly><br>")
      conn:send("<form>New SSID: <br>")
      conn:send("<input type=\"text\" name=\"newssid\" value=\""..ssid .."\"><br>")
      conn:send("New password: <br>")
      conn:send("<input type=\"text\" name=\"newpass\" value=\""..password .."\"><br>")
      conn:send("New recipient: <br>")
      conn:send("<input type=\"text\" name=\"newrecipient\" value=\""..recipient.."\"><br>")
      conn:send("<input type=\"submit\" name=\"Submit\">")
      conn:send("</form></body>")
    end)
    conn:on("sent",function(conn) conn:close() end)
  end)
end

startSetup()
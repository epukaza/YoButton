function broadcastAP()
  SETUP = true
  wifi.sta.disconnect()
  debugMsg("WiFi disconnected")
  wifi.setmode(wifi.STATIONAP)
  stationConfig = {}
  stationConfig.ssid = "YoButtonSetup"
  stationConfig.pwd = "password"
  stationConfig.auth = wifi.OPEN
  wifi.ap.config(stationConfig)
  wifi.ap.dhcp.start()
  debugMsg("Wifi station + access point")
end

function updateWiFiCreds(payload)
  ssidIndex = {payload:find("newssid=")}
  passIndex = {payload:find("&newpass=")}
  recipientIndex = {payload:find("&newrecipient=")}
  submitIndex = {payload:find("&Submit=")}

  if(ssidIndex[1]~=nil and payload:find("?")~=nil) then
    wifi.setmode(wifi.STATION)

    debugMsg(ssidIndex[1]..", "..ssidIndex[2])
    debugMsg(passIndex[1]..", "..passIndex[2])
    debugMsg(recipientIndex[1]..", "..recipientIndex[2])
    debugMsg(submitIndex[1]..", "..submitIndex[2])
    newssid = string.gsub(string.sub(payload, ssidIndex[2]+1, passIndex[1]-1), "+", " ")
    newpassword = string.gsub(string.sub(payload, passIndex[2]+1, recipientIndex[1]-1), "+", " ")
    newrecipient = string.upper(string.sub(payload, recipientIndex[2]+1, submitIndex[1]-1))
    debugMsg(newssid)
    debugMsg(newpassword)
    debugMsg(newrecipient)
    wifi.sta.config(newssid, newpassword)
    file.open("yorecipient.txt", "w+")
    file.write(newrecipient)
    file.close()
  end
  SETUP = false -- currently: attempts to send Yos regardless of connection status, as long as form is submitted
end

function setupServerResponses()
  if(srv~=nil) then
    srv:close()
    srv=nil
  end
  srv=net.createServer(net.TCP)
  srv:listen(80,function(conn)
    conn:on("receive",function(conn,payload)
      debugMsg("request received")
      ind = {string.find(payload, "\n")}
      if(ind[1] ~= nil)then
        payload = string.sub(payload, 1, ind[1])
      end
      --payload is reduced to the first line
      debugMsg(payload)
      updateWiFiCreds(payload)

      file.open("yorecipient.txt", "r")
      recipient = string.gsub(file.readline(), "\n", "", 1)
      file.close()

      ssid, password = wifi.sta.getconfig()
      ip = wifi.sta.getip()
      if(ip==nil) then
        ip="0.0.0.0"
      end

      file.open('index.html')
      indexhtml = file.read()
      file.close()

      indexhtml = string.gsub(indexhtml, "SSID_T", ssid)
      indexhtml = string.gsub(indexhtml, "PASSWORD_T", password)
      indexhtml = string.gsub(indexhtml, "IP_T", ip)
      indexhtml = string.gsub(indexhtml, "RECIPIENT_T", recipient)

      conn:send(indexhtml)

    end)
    conn:on("sent", function(conn)
                      conn:close()
                    end)
  end)
end

broadcastAP()
setupServerResponses()
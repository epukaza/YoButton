--hoisting globals for easy future removal
settingsUpdated = false
srv = nil
indexTimer = 3

function broadcastAP()
  wifi.setmode(wifi.STATIONAP)

  gpio.mode(4, gpio.OUTPUT)
  gpio.write(4, gpio.LOW)

  local accessPointConfig = {}
  accessPointConfig.ssid = "YoButton-" .. node.chipid()
  accessPointConfig.pwd = "yobutton"
  accessPointConfig.max = 1
  accessPointConfig.auth = wifi.AUTH_WPA2_PSK

  wifi.ap.config(accessPointConfig)
  wifi.ap.dhcp.start()
  debugMsg("Wifi station + access point")
end

function stopBroadcastAP()
  wifi.setmode(wifi.STATION)
  gpio.write(4, gpio.HIGH)
  srv:close()
  srv = nil
  SETUP = false
end

function updateSettings(payload)
  if payload then
    local ssidIndex = {payload:find("ssid=")}
    local passIndex = {payload:find("&pass=")}
    local recipientIndex = {payload:find("&recipient=")}
    local submitIndex = {payload:find("&Submit=")}

    if ssidIndex[1] ~= nil then
      local newssid = string.gsub(string.sub(payload, ssidIndex[2]+1, passIndex[1]-1), "+", " ")
      local newpassword = string.gsub(string.sub(payload, passIndex[2]+1, recipientIndex[1]-1), "+", " ")
      local newrecipient = string.upper(string.sub(payload, recipientIndex[2]+1, submitIndex[1]-1))

      debugMsg(newssid)
      debugMsg(newpassword)
      debugMsg(newrecipient)

      -- require SSID name, Yo recipient, valid password length
      if newssid == nil or newssid == "" then
        return false
      end
      if string.len(newpassword) > 0 and string.len(newpassword) < 8 then
        return false
      end
      if newrecipient == nil or newrecipient == "" then
        return false
      end

      wifi.sta.config(newssid, newpassword)
      file.open("yorecipient.txt", "w+")
      file.write(newrecipient)
      file.close()

      stopBroadcastAP()

      return true
    end
  else
    return false
  end
end

function setupServer()
  if(srv ~= nil) then
    srv:close()
    srv = nil
  end
  srv = net.createServer(net.TCP)
  srv:listen(80, function(conn)
    conn:on("receive", function(conn, payload)
      debugMsg("request received")
      debugMsg(payload)
      updateSettings(payload)
      
      tmr.alarm(indexTimer, 100, 0, function ()
        sendIndex(conn)
      end)
    end)

    conn:on("sent", function(conn)
      conn:close()
    end)
  end)
end

function sendIndex(conn)
  file.open('index.html')
  local indexhtml = file.read()
  file.close()

  --[[ STATUS CODES:
  0: STATION_IDLE
  1: STATION_CONNECTING
  2: STATION_WRONG_PASSWORD
  3: STATION_NO_AP_FOUND
  4: STATION_CONNECT_FAIL
  5: STATION_GOT_IP ]]

  local statusMessages = {}
  statusMessages[0] = 'not enabled'
  statusMessages[1] = 'connecting'
  statusMessages[2] = 'wrong password'
  statusMessages[3] = 'network not found'
  statusMessages[4] = 'connection fail'
  statusMessages[5] = 'connected'

  local ssid = wifi.sta.getconfig()
  local status = statusMessages[wifi.sta.status()]
  file.open("yorecipient.txt", "r")
  local recipient = string.gsub(file.readline(), "\n", "", 1)
  file.close()

  indexhtml = string.gsub(indexhtml, "_S_", ssid)
  indexhtml = string.gsub(indexhtml, "_T_", status)
  indexhtml = string.gsub(indexhtml, "_R_", recipient)

  conn:send(indexhtml)
  
end

function setupMode()
  if SETUP ~= true then
    SETUP = true    
    broadcastAP()
    setupServer()
  end
end

setupMode()
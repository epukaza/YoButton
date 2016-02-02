function broadcastAP()
  SETUP = true
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
  tmr.stop(SETUP_INACTIVITY_TIMER)
  wifi.setmode(wifi.STATION)
  gpio.write(4, gpio.HIGH)
  srv:close()
  srv = nil
  SETUP = false
end

function restartSetupTimeout(millisec)
  local ms = millisec or SETUP_TIMEOUT
  tmr.unregister(SETUP_INACTIVITY_TIMER)
  tmr.alarm(SETUP_INACTIVITY_TIMER, ms, tmr.ALARM_SINGLE, function()
      debugMsg("Setup mode timed out")   
      stopBroadcastAP()
    end)
end

function waitForWifiStatus(conn)
  tmr.alarm(WIFI_WAIT_TIMER, 1000, 1, function()
    if wifi.sta.status() ~= 0 and wifi.sta.status() ~= 1 then
      local newStatus = wifi.sta.status()
      debugMsg("Wifi status: " .. newStatus)
      tmr.stop(WIFI_WAIT_TIMER)
      sendIndex(conn)
    else
      debugMsg ("Waiting for Wifi status, currently " .. wifi.sta.status())
      restartSetupTimeout()
    end
  end)
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

      return true
    end
  else
    return false
  end
end

function setupServer()
  srv = net.createServer(net.TCP)
  srv:listen(80, function(conn)
    conn:on("receive", function(conn, payload)
      debugMsg("request received")
      debugMsg(payload)

      restartSetupTimeout()
      updated = updateSettings(payload)
      waitForWifiStatus(conn)
    end)

    conn:on("sent", function(conn)
      conn:close()
      if updated and wifi.sta.status() == 5 then
        debugMsg("updated and connected")
        tmr.alarm(SUCCESS_SETUP_TIMER, 3000, tmr.ALARM_SINGLE, function()
          debugMsg("closing AP")
          stopBroadcastAP()
        end)
      end
    end)
  end)
end

function sendIndex(conn)

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

  file.open('index.html')
  local indexhtml = file.read()
  file.close()

  indexhtml = string.gsub(indexhtml, "_S_", ssid)
  indexhtml = string.gsub(indexhtml, "_T_", status)
  indexhtml = string.gsub(indexhtml, "_R_", recipient)

  conn:send(indexhtml)
end

function setupMode()
  local srv = nil

  if SETUP ~= true then
    restartSetupTimeout()
    broadcastAP()
    setupServer()
  end
end

setupMode()
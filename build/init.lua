--[[ ASSUMPTIONS
yorecipient.txt exists
apikey.txt exists and contains a valid API key
]] 

VERSION = '0.1.0'
DEBUG = true
SETUP = false
SETUP_TIMEOUT = 120000

STARTUP_DELAY_TIMER = 0
INTERRUPT_TIMER = 1
INDEX_TIMER = 2
SETUP_INACTIVITY_TIMER = 3
WIFI_WAIT_TIMER = 4
SUCCESS_SETUP_TIMER = 5

YO_RECIPIENT = nil
API_KEY = nil

buttonPin = 6 -- GPIO12
ledPin = 2 --GPIO4

function debugMsg(msg)
  print("Yo debug: " .. msg)
end

debugMsg("3 second startup delay using timer " .. STARTUP_DELAY_TIMER .. '...')
tmr.alarm(STARTUP_DELAY_TIMER, 3000, 0, function ()
  debugMsg("Starting.")



  wifi.setmode(wifi.STATION)

  debugMsg('Booting button ' .. node.chipid())
  debugMsg('Version ' .. VERSION)

  yoRecipientExists = file.open('yorecipient.txt', 'r')
  YO_RECIPIENT = file.read()
  file.close()
  if YO_RECIPIENT then
    YO_RECIPIENT = string.gsub(YO_RECIPIENT, '\n', '')
    YO_RECIPIENT = string.gsub(YO_RECIPIENT, ' ', '')
  end
  debugMsg('found recipient:' .. tostring(YO_RECIPIENT) .. '.')

  apiKeyExists = file.open('apikey.txt', 'r')
  API_KEY = file.read()
  file.close()
  debugMsg('api key: ' .. API_KEY)

  dofile("interrupt.lua")
end)
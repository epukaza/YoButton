local wifi = wifi
local file = file
local yo_file = 'yo_recipient.txt'
local wifi_status = {
  [0] = 'not enabled',
  'connecting',
  'wrong password',
  'network not found',
  'connection fail',
  'connected'
}
local debug_message = debug_message

module(...)

function yo_recipient()
  debug_message('read.yo_recipient')
  
  if file.exists(yo_file) == false then
    debug_message('creating file')
    file.open(yo_file, 'w+')
    file.write('')
    file.close()
  else
    debug_message('file exists')
    file.open(yo_file)
    yo = file.read()
    file.close()
  end

  return (yo or '')
end

function api_key()
  file.open('api_key.txt')
  api_key = file.read()
  file.close()
end

function current_settings()
  return {
    yo_to = yo_recipient(),
    ssid = wifi.sta.getconfig(),
    status = wifi_status[wifi.sta.status()]
  }
end

function index()
  --TODO determine tradeoff of hardcoding index.html
  file.open('index.html')
  local index = file.read()
  file.close()
  return index
end

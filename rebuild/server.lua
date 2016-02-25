local read = require('read')
local write = require('write')
local net = net
local string = string
local srv = nil
local debug_message = debug_message


local pairs = pairs
local print = print
module(...)

local function connect(conn)
  local query_data

  conn:on('receive', function(cn, req_data)
    debug_message('req_data:')
    debug_message(req_data)

    --below methodology is flawed - this callback handles statelessly per chunk,
    --however the client MAY send the POST payload in another chunk.
    --temporarily work around by examining stringy properties of chunk,
    --but it's totes insecure and will need updating.

    if string.find(req_data, 's=.*&p=.*&r=.*&s=Update') then
      new_settings = parse_post(req_data)
      write.new_settings(new_settings)
    end

    -- query_data = get_http_req(req_data)
    -- debug_message(query_data['METHOD'] .. ' ' .. ' ' .. query_data['User-Agent'])
    --TODO discriminate request types (POST --> update)
    -- if query_data['METHOD'] == 'POST' then
    --   debug_message('handling POST request')
    --   new_settings = parse_post(req_data)
    --   debug_message('new settings: ' .. (new_settings or 'nil'))
      -- write.new_settings(new_settings)
    -- else
      --TODO discriminate endpoints (/, /yo.css, /status, /favicon.ico)
    -- end

    send_index(cn)
  end)

  conn:on('sent', function(cn)
    cn:close()
  end)
end

function parse_post(req_data)
  --TODO refactor this function
  debug_message('server.parse_post')
  if req_data then
    local ssid_index = {req_data:find("s=")}
    local pass_index = {req_data:find("&p=")}
    local recipient_index = {req_data:find("&r=")}
    local submit_index = {req_data:find("&s=")}

    if ssid_index[1] ~= nil then
      local new_ssid = string.gsub(string.sub(req_data, ssid_index[2]+1, pass_index[1]-1), "+", " ")
      local new_password = string.gsub(string.sub(req_data, pass_index[2]+1, recipient_index[1]-1), "+", " ")
      local new_recipient = string.upper(string.sub(req_data, recipient_index[2]+1, submit_index[1]-1))

      debug_message('new ssid: ' .. new_ssid)
      debug_message('new password: ' .. new_password)
      debug_message('new recipient: ' .. new_recipient)

      return {
        ssid = new_ssid,
        password = new_password,
        yo_to = new_recipient
      }
    end
  else
    return nil
  end
end

-- Build and return a table of the http request data
function get_http_req(instr)
  local t = {}
  local first = nil
  local key, v, strt_ndx, end_ndx

  for str in string.gmatch(instr, '([^\n]+)') do
    -- First line in the method and path
    if(first == nil) then
      first = 1
      strt_ndx, end_ndx = string.find(str, '([^ ]+)')
      v = trim(string.sub(str, end_ndx + 2))
      key = trim(string.sub(str, strt_ndx, end_ndx))
      t['METHOD'] = key
      t['REQUEST'] = v
    else -- Process and reamaining ':' fields
      strt_ndx, end_ndx = string.find(str, '([^:]+)')
      if(end_ndx ~= nil) then
        v = trim(string.sub(str, end_ndx + 2))
        key = trim(string.sub(str, strt_ndx, end_ndx))
        t[key] = v
      end
    end
  end

  return t
end

-- String trim left and right
function trim(s)
  return(s:gsub('^%s*(.-)%s*$', '%1'))
end

function send_index(conn)
  debug_message('server.send_index')

  index = read.index()

  local settings = read.current_settings()

  index = string.gsub(index, 'S_', settings.ssid)
  index = string.gsub(index, 'T_', settings.status)
  index = string.gsub(index, 'R_', settings.yo_to)

  debug_message('sending index')
  debug_message('____________')
  debug_message(index)
  debug_message('____________')
  conn:send('HTTP/1.1 200 OK\r\n\r\n' .. index)
end

function is_serving()
  return srv ~= nil
end

function start()
  debug_message('server.start')
  debug_message(srv)

  if srv then
    srv = nil
  end
  srv = net.createServer(net.TCP, 30)
  srv:listen(80, connect)
  debug_message(srv)
end

function stop()
  debug_message('server.stop')
  debug_message(srv)
  if srv then
    srv:close()
    srv = nil
  end
  debug_message(srv)
end

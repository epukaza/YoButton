local http = http
local string = string
local assert = assert
local type = type
local debug_message = debug_message

module(...)

function yo(yo_user, api_token)
  assert(type(yo_user) == 'string', 'yo_user must be a string')
  assert(type(api_token) == 'string', 'api_token must be a string')
  assert(yo_user ~= '', 'yo_user must not be empty string')
  assert(api_token ~= '', 'api_token must not be empty string')

  local content_string = "api_token=" .. api_token .. "&username=" .. string.upper(yo_user)
  local content_length = string.len(content_string)

  debug_message('yo.yo: sending Yo')
  http.post(
    'https://api.justyo.co/yo/',
    'Content-Type: application/x-www-form-urlencoded\r\n' ..
    'Content-length: ' .. content_length .. '\r\n',
    content_string,
    function(status_code, response_data)
      debug_message('yo.yo: status code: ' .. status_code)
      debug_message('yo.yo: response data: ' .. (response_data or 'nil'))
    end
  )
end

module(..., package.seeall)

function yo(yo_user, api_token)
  assert(type(yo_user) == 'string', 'yo_user must be a string')
  assert(type(api_token) == 'string', 'api_token must be a string')
  assert(yo_user ~= '', 'yo_user must not be empty string')
  assert(api_token ~= '', 'api_token must not be empty string')

  local content_string = "api_token=" .. api_token .. "&username=" .. string.upper(yo_user)
  local content_length = string.len(content_string)

  debug('yo.yo: sending Yo')
  wifi.sleeptype(wifi.NONE_SLEEP)
  http.post(
    'https://api.justyo.co/yo/',
    'Content-Type: application/x-www-form-urlencoded\r\n' ..
    'Content-length: ' .. content_length .. '\r\n',
    content_string,
    function(status_code, response_data)
      wifi.sleeptype(wifi.LIGHT_SLEEP)
      debug('yo.yo: status code: ' .. status_code)
      debug('yo.yo: response data: ' .. (response_data or 'nil'))
    end
  )
end

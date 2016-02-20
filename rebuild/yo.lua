module(..., package.seeall)

function yo(yo_user, api_token)
  assert(type(yo_user) == 'string', 'yo_user must be a string')
  assert(type(api_token) == 'string', 'api_token must be a string')
  assert(yo_user ~= '', 'yo_user must not be empty string')
  assert(api_token ~= '', 'api_token must not be empty string')

  local contentString = "api_token=" .. api_token .. "&username="..string.upper(yo_user)
  local contentLength = string.len(contentString)

  debug('yo.yo: sending Yo')
  wifi.sleeptype(wifi.NONE_SLEEP)
  http.post(
    'https://api.justyo.co/yo/',
    'Content-Type: application/x-www-form-urlencoded\r\n' ..
    'Content-length: ' .. contentLength .. '\r\n',
    contentString,
    function(status_code, response_data)
      wifi.sleeptype(wifi.LIGHT_SLEEP)
      debug('yo.yo: status code ' .. status_code)
      debug('yo.yo: response data ' .. response_data)
    end
  )
end

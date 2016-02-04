import requests
import json
username = 'ARIYEAH'
api_token = '99c680b7-5f9f-48fd-9459-46cda7e1c8fa'

r = requests.post("https://api.justyo.co/yo/", data={'api_token': api_token, 'username': username})

print r.headers

print ""

print r.json()

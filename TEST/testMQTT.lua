-- Test simple unencrypted MQTT connection using Mosquitto test server
m = mqtt.Client("clientid", 120, "user", "password")
m:connect("192.168.1.13", 1883, 0, function(conn) print("connected!") end)
m:on("connect", function(con) print("actually connected!") end)
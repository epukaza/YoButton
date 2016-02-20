## Use firmware 1.5.1 ONLY: https://github.com/nodemcu/nodemcu-firmware/issues/719

## OSX ESP firmware build notes

Use the Docker NodeMCU build: https://hub.docker.com/r/marcelstoer/nodemcu-build/

OSX: `docker run --rm -ti -v /Users/aria/code/nodemcu-firmware/:/opt/nodemcu-firmware/ marcelstoer/nodemcu-build`

Using these modules only:

    #define LUA_USE_MODULES_CJSON
    #define LUA_USE_MODULES_CRYPTO
    #define LUA_USE_MODULES_FILE
    #define LUA_USE_MODULES_GPIO
    #define LUA_USE_MODULES_HTTP
    #define LUA_USE_MODULES_NET
    #define LUA_USE_MODULES_NODE
    #define LUA_USE_MODULES_PWM
    #define LUA_USE_MODULES_RTCFIFO
    #define LUA_USE_MODULES_RTCMEM
    #define LUA_USE_MODULES_RTCTIME
    #define LUA_USE_MODULES_SNTP
    #define LUA_USE_MODULES_TMR
    #define LUA_USE_MODULES_UART
    #define LUA_USE_MODULES_WIFI

# Flashing

`/Users/aria/code/espbuild/esp-open-sdk/esptool`

`python esptool.py -p /dev/tty.SLAB_USBtoUART write_flash 0x00 /opt/Espressif/nodemcu-firmware/bin/0x00000.bin` etc


# other notes

Building with default modules + debug causes luatool to fail with `'stdin:1: attempt to call field 'open' (a nil value)'` since it seems file.open isn't defined. Rebuilt with fewer modules + debug and file upload seems to work fine. Did the build... just run out of space and truncate the image?

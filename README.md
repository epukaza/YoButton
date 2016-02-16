###current version: 0.1.0

## Use firmware 1.5.1 ONLY: https://github.com/nodemcu/nodemcu-firmware/issues/719

## OSX ESP firmware build notes

`error: unknown type name 'ptrdiff_t'` when installing pass-2 core C compiler. 

Solution: `https://github.com/pfalcon/esp-open-sdk/issues/45` delete define/endef statements

# Relevant output

Xtensa toolchain is built, to use it:

`export PATH=/Users/aria/code/espbuild/esp-open-sdk/xtensa-lx106-elf/bin:$PATH`

Espressif ESP8266 SDK is installed. Toolchain contains only Open Source components
To link external proprietary libraries add:

`xtensa-lx106-elf-gcc -I/Users/aria/code/espbuild/esp-open-sdk/sdk/include -L/Users/aria/code/espbuild/esp-open-sdk/sdk/lib`

# Flashing

`/Users/aria/code/espbuild/esp-open-sdk/esptool`

`python esptool.py -p /dev/tty.SLAB_USBtoUART write_flash 0x00 /opt/Espressif/nodemcu-firmware/bin/0x00000.bin` etc


# other notes

Building with default modules + debug causes luatool to fail with `'stdin:1: attempt to call field 'open' (a nil value)'` since it seems file.open isn't defined. Rebuilt with fewer modules + debug and file upload seems to work fine. Did the build... just run out of space and truncate the image?

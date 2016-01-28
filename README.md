## OSX ESP firmware build notes

`error: unknown type name 'ptrdiff_t'` when installing pass-2 core C compiler. 

Solution: `https://github.com/pfalcon/esp-open-sdk/issues/45` delete define/endef statements

# Relevant output

Xtensa toolchain is built, to use it:

`export PATH=/Users/aria/code/espbuild/esp-open-sdk/xtensa-lx106-elf/bin:$PATH`

Espressif ESP8266 SDK is installed. Toolchain contains only Open Source components
To link external proprietary libraries add:

`xtensa-lx106-elf-gcc -I/Users/aria/code/espbuild/esp-open-sdk/sdk/include -L/Users/aria/code/espbuild/esp-open-sdk/sdk/lib`

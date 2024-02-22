# SPDX-License-Identifier: Apache-2.0

cmake_minimum_required(VERSION 3.20.0)
find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(secure_device_app)

FILE(GLOB app_sources app/*.c)
FILE(GLOB wrapper_sources wrapper/*.c)
target_sources(app PRIVATE
    src/main.c
    ${app_sources}
    ${wrapper_sources}
    $ENV{FWLIB_PATH}/fido2_lib/fido_ble_receive.c
    $ENV{FWLIB_PATH}/fido2_lib/fido_ble_send.c
    $ENV{FWLIB_PATH}/fido2_lib/fido_command.c
    $ENV{FWLIB_PATH}/fw_common/fw_common.c
    $ENV{FWLIB_PATH}/tiny_tft_lib/tiny_tft_const.c
    $ENV{FWLIB_PATH}/tiny_tft_lib/tiny_tft_util.c
    $ENV{FWLIB_PATH}/tiny_tft_lib/tiny_tft.c
    $ENV{FWLIB_PATH}/vendor_lib/vendor_command.c
)
target_include_directories(app PRIVATE 
    $ENV{ZEPHYR_BASE}/subsys/settings/include
    app
    $ENV{FWLIB_PATH}/fido2_lib
    $ENV{FWLIB_PATH}/fw_common
    $ENV{FWLIB_PATH}/tiny_tft_lib
    $ENV{FWLIB_PATH}/vendor_lib
    $ENV{FWLIB_PATH}/wrapper_header
)

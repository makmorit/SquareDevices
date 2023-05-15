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
    $ENV{NCS_HOME}/mbedtls/library/ctr_drbg.c
    $ENV{FWLIB_PATH}/fido2_lib/fido_ble_receive.c
    $ENV{FWLIB_PATH}/fido2_lib/fido_ble_send.c
    $ENV{FWLIB_PATH}/fido2_lib/fido_command.c
    $ENV{FWLIB_PATH}/vendor_lib/vendor_command.c
)
target_include_directories(app PRIVATE 
    $ENV{NCS_HOME}/modules/lib/tinycbor/include
    $ENV{ZEPHYR_BASE}/subsys/settings/include
    app
    $ENV{FWLIB_PATH}/fido2_lib
    $ENV{FWLIB_PATH}/vendor_lib
    $ENV{FWLIB_PATH}/wrapper_header
)

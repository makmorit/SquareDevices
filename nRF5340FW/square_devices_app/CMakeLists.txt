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
)
target_include_directories(app PRIVATE 
    $ENV{NCS_HOME}/modules/lib/tinycbor/include
    $ENV{ZEPHYR_BASE}/subsys/settings/include
    app
)
#!/bin/bash

# Build target
#   raytac_mdbt53v_db_40_nrf5340_cpuapp
export BUILD_TARGET=raytac_mdbt53v_db_40_nrf5340_cpuapp

# Environment variables for Zephyr SDK
export ZEPHYR_SDK_INSTALL_DIR="${HOME}/opt/zephyr-sdk-0.16.5"
export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
export ZEPHYR_TOOLCHAIN_PATH="${HOME}/opt/zephyr-sdk-0.16.5"

# bash completion
export NCS_HOME=${HOME}/opt/ncs_2.6.1
export ZEPHYR_BASE=${NCS_HOME}/zephyr
source ${ZEPHYR_BASE}/zephyr-env.sh

# Enter Python3 venv
source ${NCS_HOME}/bin/activate

if [ "$1" == "-f" ]; then
    # Flash for nRF5340
    ${NCS_HOME}/bin/west -v flash -d build_signed
    if [ `echo $?` -ne 0 ]; then
        deactivate
        exit 1
    fi
else
    # Build for nRF5340
    rm -rf build_signed
    ${NCS_HOME}/bin/west build -c -b ${BUILD_TARGET} -d build_signed -- DTS_OPT="-DDTC_OVERLAY_FILE=raytac_mdbt53v_db_40_nrf5340_cpuapp.overlay"
    if [ `echo $?` -ne 0 ]; then
        deactivate
        exit 1
    fi
fi

deactivate
exit 0

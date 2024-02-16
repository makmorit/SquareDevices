#!/bin/bash

# Build target
#   nrf5340dk_nrf5340_cpuapp
export BUILD_TARGET=nrf5340dk_nrf5340_cpuapp

# Environment variables for Zephyr SDK
export ZEPHYR_SDK_INSTALL_DIR="${HOME}/opt/zephyr-sdk-0.16.1"
export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
export ZEPHYR_TOOLCHAIN_PATH="${HOME}/opt/zephyr-sdk-0.16.1"

# Paths for command
export PATH=${PATH}:/usr/local/bin

# Paths for firmware source & header
export FWLIB_PATH=../../Firmwares

# bash completion
export NCS_HOME=${HOME}/opt/ncs_2.5.2
export ZEPHYR_BASE=${NCS_HOME}/zephyr
source ${ZEPHYR_BASE}/zephyr-env.sh

# Retrieve config value from prj.conf
retrieve_prj_conf() {
    if [ "${BUILD_TARGET}" == "nrf5340dk_nrf5340_cpuapp" ]; then
        CONFIG_FILE=boards/nrf5340dk_nrf5340_cpuapp.conf
    else
        CONFIG_FILE=prj.conf
    fi
    grep $1 ${CONFIG_FILE} | sed -e "s/.*\"\(.*\)\"/\1/"
}

retrieve_config_yesno() {
    grep $1 $2 | sed -e "s/.*=\(.*\)/\1/"
}

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
    # Config for BLE DFU
    OVR_OPT="-DOVERLAY_CONFIG=overlay-smp.conf"
    # Config for target board
    HW_REV_STR=`retrieve_prj_conf CONFIG_BT_DIS_HW_REV_STR`
    if [ -n "${HW_REV_STR}" ]; then
        DTS_FILE=configuration/${BUILD_TARGET}/${HW_REV_STR}.overlay
        if [ -f ${DTS_FILE} ]; then
            DTS_OPT="-DDTC_OVERLAY_FILE=${DTS_FILE}"
        fi
        OVR_FILE=configuration/${BUILD_TARGET}/${HW_REV_STR}.conf
        if [ -f ${OVR_FILE} ]; then
            OVR_OPT="${OVR_OPT};${OVR_FILE}"
            # Config for tiny TFT
            USE_TFT=`retrieve_config_yesno CONFIG_USE_TINY_TFT ${OVR_FILE}`
            if [ "${USE_TFT}" == "y" ]; then
                DTS_OPT="${DTS_OPT};configuration/${BUILD_TARGET}/tiny_tft.overlay"
            fi
        fi
    fi
    # Build for nRF5340
    rm -rf build_signed
    ${NCS_HOME}/bin/west build -c -b ${BUILD_TARGET} -d build_signed -- ${OVR_OPT} ${DTS_OPT}
    if [ `echo $?` -ne 0 ]; then
        deactivate
        exit 1
    fi
    # Deploy binary file for DFU
    FW_REV_STR=`retrieve_prj_conf CONFIG_BT_DIS_FW_REV_STR`
    cp -pv build_signed/zephyr/app_update.bin ../firmwares/square_devices_app/app_update.${HW_REV_STR}.${FW_REV_STR}.bin
    echo Application binary for secure bootloader is now available.
fi

deactivate
exit 0

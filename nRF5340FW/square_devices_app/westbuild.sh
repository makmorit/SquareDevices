#!/bin/bash

# Usage
#  west build:
#   BUILD_TARGET=raytac_mdbt53v_db_40_nrf5340_cpuapp ./westbuild.sh
#  west flash:
#   BUILD_TARGET=raytac_mdbt53v_db_40_nrf5340_cpuapp ./westbuild.sh -f
#  support board:
#   nrf5340dk_nrf5340_cpuapp
#   raytac_mdbt53v_db_40_nrf5340_cpuapp

# Environment variables for Zephyr SDK
export ZEPHYR_SDK_INSTALL_DIR="${HOME}/opt/zephyr-sdk-0.16.5"
export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
export ZEPHYR_TOOLCHAIN_PATH="${HOME}/opt/zephyr-sdk-0.16.5"

# Paths for command
export PATH=${PATH}:/usr/local/bin

# Paths for firmware source & header
export FWLIB_PATH=../../Firmwares

# bash completion
export NCS_HOME=${HOME}/opt/ncs_2.6.1
export ZEPHYR_BASE=${NCS_HOME}/zephyr
source ${ZEPHYR_BASE}/zephyr-env.sh

# Retrieve config value from prj.conf
retrieve_prj_conf() {
    CONFIG_FILE="boards/${BUILD_TARGET}.conf"
    grep $1 ${CONFIG_FILE} | sed -e "s/.*\"\(.*\)\"/\1/"
}

retrieve_config_yesno() {
    grep $1 $2 | sed -e "s/.*=\(.*\)/\1/"
}

# Enter Python3 venv
source ${NCS_HOME}/bin/activate

# Retrieve build target from env
if [ -n "${BUILD_TARGET}" ]; then
    echo Building application for ${BUILD_TARGET}
else
    echo Build target not specified
    deactivate
    exit 1
fi

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
    DTS_FILE=configuration/${BUILD_TARGET}/peripherals.overlay
    if [ -f ${DTS_FILE} ]; then
        DTS_OPT="-DDTC_OVERLAY_FILE=${DTS_FILE}"
    fi
    # Config for tiny TFT
    CNF_FILE=boards/${BUILD_TARGET}.conf
    if [ -f ${CNF_FILE} ]; then
        USE_TFT=`retrieve_config_yesno CONFIG_USE_TINY_TFT ${CNF_FILE}`
        if [ "${USE_TFT}" == "y" ]; then
            DTS_OPT="${DTS_OPT};configuration/${BUILD_TARGET}/tiny_tft.overlay"
        fi
        USE_BATT_ADC=`retrieve_config_yesno CONFIG_USE_BATT_ADC ${CNF_FILE}`
        if [ "${USE_BATT_ADC}" == "y" ]; then
            DTS_OPT="${DTS_OPT};configuration/${BUILD_TARGET}/adc.overlay"
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
    HW_REV_STR=`retrieve_prj_conf CONFIG_BT_DIS_HW_REV_STR`
    FW_REV_STR=`retrieve_prj_conf CONFIG_BT_DIS_FW_REV_STR`
    cp -pv build_signed/zephyr/app_update.bin ../firmwares/square_devices_app/app_update.${HW_REV_STR}.${FW_REV_STR}.bin
    echo Application binary for secure bootloader is now available.
fi

deactivate
exit 0

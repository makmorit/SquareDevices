/* 
 * File:   app_batt_adc.c
 * Author: makmorit
 *
 * Created on 2024/09/19, 10:58
 */
#include <zephyr/types.h>
#include <zephyr/kernel.h>
#include <zephyr/drivers/adc.h>

// ログ出力制御
#define LOG_LEVEL LOG_LEVEL_DBG
#include <zephyr/logging/log.h>
LOG_MODULE_REGISTER(app_batt_adc);

// Define a variable of type adc_dt_spec for each channel
static const struct adc_dt_spec adc_channel = ADC_DT_SPEC_GET(DT_PATH(zephyr_user));

// Define a variable of type adc_sequence and a buffer of type uint16_t
static int16_t buf;
static struct adc_sequence sequence = {
    .buffer = &buf,
    // buffer size in bytes, not number of samples
    .buffer_size = sizeof(buf),
    // Optional
    //.calibrate = true,
};

static int app_batt_adc_init_channel(void)
{
    // validate that the ADC peripheral (SAADC) is ready
    if (!adc_is_ready_dt(&adc_channel)) {
        LOG_ERR("ADC controller devivce %s not ready", adc_channel.dev->name);
        return -ENOTSUP;
    }
    // Setup the ADC channel
    int err = adc_channel_setup_dt(&adc_channel);
    if (err < 0) {
        LOG_ERR("Could not setup channel #%d (%d)", 0, err);
        return -ENOTSUP;
    }
    // Initialize the ADC sequence
    err = adc_sequence_init_dt(&adc_channel, &sequence);
    if (err < 0) {
        LOG_ERR("Could not initalize sequence");
        return -ENOTSUP;
    }
    LOG_INF("ADC channel and sequence initialized");
    return 0;
}

SYS_INIT(app_batt_adc_init_channel, APPLICATION, CONFIG_KERNEL_INIT_PRIORITY_DEVICE);

bool app_batt_adc_read_millivolts_value(int *val_mv)
{
    // Read a sample from the ADC
    int err = adc_read(adc_channel.dev, &sequence);
    if (err < 0) {
        LOG_ERR("Could not read (%d)", err);
        return false;
    }
    // Convert raw value to mV
    *val_mv = (int)buf;
    err = adc_raw_to_millivolts_dt(&adc_channel, val_mv);
    if (err < 0) {
        // conversion to mV may not be supported
        LOG_WRN("Value in mV not available");
        return false;
    } else {
        return true;
    }
}

//
// Battery measurement simulation test
//
void app_batt_adc_test(void)
{
    int val_mv;
    if (app_batt_adc_read_millivolts_value(&val_mv)) {
        LOG_DBG("Battery measurement test: %d mV", val_mv);
    }
}

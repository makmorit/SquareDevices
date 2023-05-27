/* 
 * File:   wrapper_common.h
 * Author: makmorit
 *
 * Created on 2023/05/10, 17:22
 */
#ifndef WRAPPER_COMMON_H
#define WRAPPER_COMMON_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

//
// 関数群
//
void        fido_log_error(const char *fmt, ...);
void        fido_log_info(const char *fmt, ...);
void        fido_log_debug(const char *fmt, ...);
void        fido_log_print_hexdump_debug(uint8_t *data, size_t size);
void        fido_ble_response_send_resume(void);
bool        fido_ble_response_send(uint8_t *u2f_status_buffer, size_t u2f_status_buffer_length);
void        fido_ble_peripheral_terminate(void);
void        fido_ble_advertise_start_smp_service(void);
bool        fido_ble_unpairing_get_peer_id(uint16_t *peer_id_to_unpair);
bool        fido_ble_unpairing_delete_peer_id(uint16_t peer_id_to_unpair);
bool        fido_ble_unpairing_delete_all_peers(void);
bool        fido_rtcc_get_timestamp(char *buf, size_t size);
bool        fido_rtcc_set_timestamp(uint32_t seconds_since_epoch, uint8_t timezone_diff_hours);
bool        fido_flash_get_stat_csv(uint8_t *stat_csv_data, size_t *stat_csv_size);
bool        fido_board_get_version_info_csv(uint8_t *info_csv_data, size_t *info_csv_size);

#ifdef __cplusplus
}
#endif

#endif /* WRAPPER_COMMON_H */

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
bool        fido_ble_response_send(uint8_t *u2f_status_buffer, size_t u2f_status_buffer_length);
bool        fido_ble_unpairing_get_peer_id(uint16_t *peer_id_to_unpair);

#ifdef __cplusplus
}
#endif

#endif /* WRAPPER_COMMON_H */

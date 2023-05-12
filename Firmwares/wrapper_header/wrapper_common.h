/* 
 * File:   wrapper_common.h
 * Author: makmorit
 *
 * Created on 2023/05/10, 17:22
 */
#ifndef WRAPPER_COMMON_H
#define WRAPPER_COMMON_H

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

#ifdef __cplusplus
}
#endif

#endif /* WRAPPER_COMMON_H */

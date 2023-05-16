/* 
 * File:   fw_common.h
 * Author: makmorit
 *
 * Created on 2023/05/16, 16:51
 */
#ifndef FW_COMMON_H
#define FW_COMMON_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

//
// 関数群
//
void        fw_common_set_uint16_bytes(uint8_t *p_dest_buffer, uint16_t bytes);
uint16_t    fw_common_get_uint16_from_bytes(uint8_t *p_src_buffer);

#ifdef __cplusplus
}
#endif

#endif /* FW_COMMON_H */

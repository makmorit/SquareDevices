/* 
 * File:   fw_common.c
 * Author: makmorit
 *
 * Created on 2023/05/16, 16:51
 */
#include <stdint.h>

void fw_common_set_uint16_bytes(uint8_t *p_dest_buffer, uint16_t bytes)
{
    // ２バイトの整数をビッグエンディアン形式で
    // 指定の領域に格納
    p_dest_buffer[0] = bytes >>  8 & 0xff;
    p_dest_buffer[1] = bytes >>  0 & 0xff;
}

uint16_t fw_common_get_uint16_from_bytes(uint8_t *p_src_buffer)
{
    // ２バイトのビッグエンディアン形式配列を、
    // ２バイト整数に変換
    uint16_t uint16;
    uint8_t *p_dest_buffer = (uint8_t *)&uint16;
    p_dest_buffer[0] = p_src_buffer[1];
    p_dest_buffer[1] = p_src_buffer[0];
    return uint16;
}

uint32_t fw_common_get_uint32_from_bytes(uint8_t *p_src_buffer)
{
    // ４バイトのビッグエンディアン形式配列を、
    // ４バイト整数に変換
    uint32_t uint32;
    uint8_t *p_dest_buffer = (uint8_t *)&uint32;
    p_dest_buffer[0] = p_src_buffer[3];
    p_dest_buffer[1] = p_src_buffer[2];
    p_dest_buffer[2] = p_src_buffer[1];
    p_dest_buffer[3] = p_src_buffer[0];
    return uint32;
}

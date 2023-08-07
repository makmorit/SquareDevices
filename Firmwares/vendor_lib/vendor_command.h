/* 
 * File:   vendor_command.h
 * Author: makmorit
 *
 * Created on 2023/05/15, 15:57
 */
#ifndef VENDOR_COMMAND_H
#define VENDOR_COMMAND_H

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

//
// 関数群
//
bool        vendor_command_on_fido_msg(void *p_fido_request, void *p_fido_response);
void        vendor_command_on_ble_disconnected(void);
bool        vendor_command_on_button_pressed_short(void);
bool        vendor_command_on_button_pressed_sub(void);

#ifdef __cplusplus
}
#endif

#endif /* VENDOR_COMMAND_H */

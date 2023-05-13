/* 
 * File:   fido_command.h
 * Author: makmorit
 *
 * Created on 2023/05/12, 10:51
 */
#ifndef FIDO_COMMAND_H
#define FIDO_COMMAND_H

#ifdef __cplusplus
extern "C" {
#endif

//
// 関数群
//
void        fido_command_on_ble_request_received(void *p_fido_request, void *p_fido_response);
void        fido_command_on_ble_response_sent(void *p_fido_request, void *p_fido_response);

#ifdef __cplusplus
}
#endif

#endif /* FIDO_COMMAND_H */

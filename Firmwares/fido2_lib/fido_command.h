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
void        fido_command_ctap1_status_response(void *p_fido_response, uint32_t cid, uint8_t cmd, uint8_t ctap1_status);
void        fido_command_ctap_status_and_data_response(void *p_fido_response, uint32_t cid, uint8_t cmd, uint8_t ctap1_status, uint8_t *data, size_t data_size);
void        fido_command_u2f_ping_response(void *p_fido_request, void *p_fido_response);
bool        fido_command_on_ble_request_received(void *p_fido_request, void *p_fido_response);
void        fido_command_on_ble_response_sent(void *p_fido_request, void *p_fido_response);
void        fido_command_on_ble_disconnected(void);
void        fido_command_on_ble_advertise_started_smp_service(void);
bool        fido_command_on_button_pressed_short(void);
bool        fido_command_on_button_pressed_sub(void);

#ifdef __cplusplus
}
#endif

#endif /* FIDO_COMMAND_H */

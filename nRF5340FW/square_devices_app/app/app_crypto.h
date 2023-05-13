/* 
 * File:   app_crypto.h
 * Author: makmorit
 *
 * Created on 2023/05/08, 9:39
 */
#ifndef APP_CRYPTO_H
#define APP_CRYPTO_H

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

//
// 関数群
//
void       *app_crypto_ctr_drbg_context(void);
bool        app_crypto_event_notify(uint8_t event);

#ifdef __cplusplus
}
#endif

#endif /* APP_CRYPTO_H */

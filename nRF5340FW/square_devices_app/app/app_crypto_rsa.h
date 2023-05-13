/* 
 * File:   app_crypto_rsa.h
 * Author: makmorit
 *
 * Created on 2023/05/08, 10:07
 */
#ifndef APP_CRYPTO_RSA_H
#define APP_CRYPTO_RSA_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

//
// 関数群
//
uint8_t    *app_crypto_rsa_e_bytes(void);
uint8_t     app_crypto_rsa_e_size(void);
bool        app_crypto_rsa_private(uint8_t *rsa_private_key_raw, uint8_t *input, uint8_t *output);
bool        app_crypto_rsa_public(uint8_t *rsa_public_key_raw, uint8_t *input, uint8_t *output);
bool        app_crypto_rsa_import_pubkey_from_prvkey(uint8_t *rsa_private_key_raw, uint8_t *rsa_public_key_raw);
bool        app_crypto_rsa_generate_key(uint8_t *rsa_private_key_raw, uint8_t *rsa_public_key_raw, unsigned int nbits);

#ifdef __cplusplus
}
#endif

#endif /* APP_CRYPTO_RSA_H */

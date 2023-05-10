/* 
 * File:   app_crypto_define.h
 * Author: makmorit
 *
 * Created on 2023/05/08, 10:02
 */
#ifndef APP_CRYPTO_DEFINE_H
#define APP_CRYPTO_DEFINE_H

#ifdef __cplusplus
extern "C" {
#endif

#define AES_KEY_SIZE        32
#define AES_IV_SIZE         16
#define SHA256_HASH_SIZE    32
#define DES3_KEY_SIZE       24
#define DES3_CRYPTO_SIZE    8
#define RSA2048_PQ_SIZE     128
#define EC_RAW_PRIVKEY_SIZE 32
#define EC_RAW_PUBKEY_SIZE  64

// イベント種別
typedef enum {
    CRYPTO_EVT_NONE = 0,
    CRYPTO_EVT_INIT,
    CRYPTO_EVT_RANDOM_PREGEN,
} CRYPTO_EVENT_T;

#ifdef __cplusplus
}
#endif

#endif /* APP_CRYPTO_DEFINE_H */

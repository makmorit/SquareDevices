/* 
 * File:   fido_transport_define.h
 * Author: makmorit
 *
 * Created on 2023/05/11, 10:19
 */
#ifndef FIDO_TRANSPORT_DEFINE_H
#define FIDO_TRANSPORT_DEFINE_H

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// リクエストデータに含まれるコマンドヘッダーを保持
typedef struct {
    uint32_t CID;
    uint8_t  CMD;
    uint32_t LEN;
    uint8_t  SEQ;

    // リクエストデータの検査中に確認されたエラーを保持
    uint8_t  ERROR;

    // リクエストデータの検査中に設定されたステータスワードを保持
    uint16_t STATUS_WORD;

    // 後続リクエストがあるかどうかを保持
    bool CONT;
} FIDO_COMMAND_T;

// リクエストデータに含まれるAPDU項目を保持
typedef struct {
    uint8_t  CLA;
    uint8_t  INS;
    uint8_t  P1;
    uint8_t  P2;
    uint32_t Lc;
    uint8_t *data;
    uint32_t data_length;
    uint32_t Le;
} FIDO_APDU_T;

#ifdef __cplusplus
}
#endif

#endif /* FIDO_TRANSPORT_DEFINE_H */

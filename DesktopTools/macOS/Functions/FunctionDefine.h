//
//  FunctionDefine.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/11/27.
//
#ifndef FunctionDefine_h
#define FunctionDefine_h

#pragma mark - FIDO機能関連エラーステータス
#define CTAP1_ERR_SUCCESS                   0x00

#pragma mark - U2Fコマンド
#define U2F_COMMAND_PING                    0x01
#define U2F_COMMAND_KEEPALIVE               0x02
#define U2F_COMMAND_MSG                     0x03
#define U2F_COMMAND_UNKNOWN_ERROR           0x3f

#pragma mark - ベンダー固有コマンド
#define VENDOR_COMMAND_GET_APP_VERSION      0x43
#define VENDOR_COMMAND_GET_TIMESTAMP        0x4a
#define VENDOR_COMMAND_SET_TIMESTAMP        0x4b
#define VENDOR_COMMAND_UNPAIRING_REQUEST    0x4d
#define VENDOR_COMMAND_UNPAIRING_CANCEL     0x4e
#define VENDOR_COMMAND_ERASE_BONDING_DATA   0x4f

#endif /* FunctionDefine_h */

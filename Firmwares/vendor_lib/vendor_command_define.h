/* 
 * File:   vendor_command_define.h
 * Author: makmorit
 *
 * Created on 2023/05/15, 16:38
 */
#ifndef VENDOR_COMMAND_DEFINE_H
#define VENDOR_COMMAND_DEFINE_H

#ifdef __cplusplus
extern "C" {
#endif

// ベンダー固有コマンドの識別用
#define VENDOR_COMMAND_UNPAIRING_REQUEST    0x4d
#define VENDOR_COMMAND_UNPAIRING_CANCEL     0x4e
#define VENDOR_COMMAND_ERASE_BONDING_DATA   0x4f

#ifdef __cplusplus
}
#endif

#endif /* VENDOR_COMMAND_DEFINE_H */

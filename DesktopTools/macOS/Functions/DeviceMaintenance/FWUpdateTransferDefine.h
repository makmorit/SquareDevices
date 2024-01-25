//
//  FWUpdateTransferDefine.h
//  DesktopTool
//
//  Created by Makoto Morita on 2024/01/11.
//
#ifndef FWUpdateTransferDefine_h
#define FWUpdateTransferDefine_h

#pragma mark - イメージ反映所要時間（秒）
#define DFU_WAITING_SEC_ESTIMATED   33

#pragma mark - SMPトランザクションで使用する定義
#define OP_READ_REQ             0
#define OP_WRITE_REQ            2

#define GRP_IMG_MGMT            1
#define CMD_IMG_MGMT_STATE      0
#define CMD_IMG_MGMT_UPLOAD     1

#define GRP_OS_MGMT             0
#define CMD_OS_MGMT_RESET       5

#pragma mark - イメージ反映モード　true＝テストモード[Swap type: test]、false＝通常モード[Swap type: perm]
#define IMAGE_UPDATE_TEST_MODE  false

#endif /* FWUpdateTransferDefine_h */

//
//  BLEDefines.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/10/30.
//
#ifndef BLEDefines_h
#define BLEDefines_h

#pragma mark - BLEサービスに関する定義
#define U2F_BLE_SERVICE_UUID_STR                    @"0000FFFD-0000-1000-8000-00805f9b34fb"
#define U2F_CONTROL_POINT_CHAR_UUID_STR             @"F1D0FFF1-DEAA-ECEE-B42F-C9BA7ED623BB"
#define U2F_STATUS_CHAR_UUID_STR                    @"F1D0FFF2-DEAA-ECEE-B42F-C9BA7ED623BB"

#define BLE_SMP_SERVICE_UUID_STR                    @"8D53DC1D-1DB7-4CD3-868B-8A527460AA84"
#define BLE_SMP_CHARACT_UUID_STR                    @"DA2E7828-FBCE-4E01-AE9E-261174997C48"

#pragma mark - BLEフレームに関する定数
#define SMP_HEADER_SIZE                             8

#endif /* BLEDefines_h */

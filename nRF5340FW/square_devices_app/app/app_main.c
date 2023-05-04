/* 
 * File:   app_main.c
 * Author: makmorit
 *
 * Created on 2023/05/04, 18:05
 */
#include "app_ble_init.h"
#include "app_board.h"
#include "app_event.h"
#include "app_event_define.h"
#include "app_main.h"
#include "app_rtcc.h"
#include "app_timer.h"
#include "app_usb.h"

//
// アプリケーション初期化処理
//
void app_main_init(void) 
{
    // ボタン、LEDを使用可能にする
    app_board_initialize();

    // USBを使用可能にする
    app_usb_initialize();

    // タイマーを使用可能にする
    app_timer_initialize();

    // 業務処理イベント（APEVT_XXXX）を
    // 通知できるようにする
    app_event_main_enable(true);

    // サブシステム初期化をメインスレッドで実行
    app_event_notify(APEVT_SUBSYS_INIT);
}

void app_main_subsys_init(void)
{
    // リアルタイムクロックカレンダーの初期化
    app_rtcc_initialize();

    // Bluetoothサービス開始を指示
    //   同時に、Flash ROMストレージが
    //   使用可能となります。
    app_ble_init();
}

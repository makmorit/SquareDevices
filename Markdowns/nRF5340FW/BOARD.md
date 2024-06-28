# nRF5340開発ボードについて

最終更新日：2024/6/28

## 概要

nRF5340を搭載する開発ボードについての技術情報を掲載しています。

## ピン割り当て

#### MDBT53V-DB

開発ボード「[MDBT53V-DB](https://www.raytac.com/product/ins.php?index_id=140)」におけるピン割り当ては下記になります。<br>
ただし最終更新日現在、<b>下記割り当ては仮内容</b>であり、今後検証作業を進める中で変更される可能性があります。

|ピン名|通称|内容|用途等|
|:--:|:-|:-|:-|
|`P1.13`|SW1|メインスイッチ|業務用プッシュボタン|
|`P0.25`|SW2|サブスイッチ|予備プッシュボタン|
|`P0.26`|SW3|サブスイッチ|予備プッシュボタン|
|`P0.31`|LED1|LED|状態表示用|
|`P0.18`|LED2|LED|同上|
|`P0.17`|LED3|LED|同上|
|`P0.16`|LED4|LED|同上|
|`P1.02`|RTCC-SDA（TWIM_SDA）|RTCCデータ入出力|RTCCモジュールで使用（`i2c1`）|
|`P1.03`|RTCC-SCL（TWIM_SCL）|RTCCクロック入力|RTCCモジュールで使用（`i2c1`）|
|`未定`|TFT-LEDA|TFTバックライト制御信号|[超小型TFT液晶ディスプレイ]()で使用|
|`未定`|TFT-RESET|TFTのリセット|同上|
|`未定`|TFT-D/C|TFTデータ／コマンド切替え|同上|
|`未定`|TFT-CS|TFT通信開始|同上|
|`未定`|TFT-SDA（SPIM_MOSI）|TFTデータ入力|同上（`spi4`）|
|`未定`|TFT-SCL（SPIM_SCK）|TFTクロック入力|同上（`spi4`）|
|`RESET`|RESET|リセットスイッチ|ファームウェアの強制再起動用|
|`SWDIO`|SWDIO|書込み用I/O|ファームウェアの直接書込み用|
|`SWCLK`|SWDCLK|書込み用Clock|同上|
|`P0.9`|UART_TX|シリアル通信送信|デバッグ出力用（`uart0`）|
|`P0.8`|UART_RX|シリアル通信受信|デバッグ入力用（`uart0`）|
|`P0.11`|UART_RTS|シリアル通信制御|予備（`uart0`）|
|`P0.12`|UART_CTS|シリアル通信制御|予備（`uart0`）|

#### nRF5340 DK

開発ボード「[nRF5340 DK](https://www.nordicsemi.com/Products/Development-hardware/nrf5340-dk)」におけるピン割り当ては下記になります。

|ピン名|通称|内容|用途等|
|:--:|:-|:-|:-|
|`P0.23`|SW1|メインスイッチ|業務用プッシュボタン|
|`P0.24`|SW2|サブスイッチ|予備プッシュボタン|
|`P0.28`|LED1|LED|状態表示用|
|`P0.29`|LED2|LED|同上|
|`P0.30`|LED3|LED|同上|
|`P0.31`|LED4|LED|同上|
|`P1.02`|RTCC-SDA（TWIM_SDA）|RTCCデータ入出力|RTCCモジュールで使用（`i2c1`）|
|`P1.03`|RTCC-SCL（TWIM_SCL）|RTCCクロック入力|RTCCモジュールで使用（`i2c1`）|
|`P1.09`|TFT-LEDA|TFTバックライト制御信号|[超小型TFT液晶ディスプレイ]()で使用|
|`P1.10`|TFT-RESET|TFTのリセット|同上|
|`P1.11`|TFT-D/C|TFTデータ／コマンド切替え|同上|
|`P1.12`|TFT-CS|TFT通信開始|同上|
|`P1.13`|TFT-SDA（SPIM_MOSI）|TFTデータ入力|同上（`spi4`）|
|`P1.15`|TFT-SCL（SPIM_SCK）|TFTクロック入力|同上（`spi4`）|
|`RESET`|RESET|リセットスイッチ|ファームウェアの強制再起動用|
|`SWDIO`|SWDIO|書込み用I/O|ファームウェアの直接書込み用|
|`SWDCLK`|SWDCLK|書込み用Clock|同上|
|`P0.20`|UART_TX|シリアル通信送信|デバッグ出力用（`uart0`）|
|`P0.22`|UART_RX|シリアル通信受信|デバッグ入力用（`uart0`）|
|`P0.19`|UART_RTS|シリアル通信制御|予備（`uart0`）|
|`P0.21`|UART_CTS|シリアル通信制御|予備（`uart0`）|

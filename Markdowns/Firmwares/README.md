# ファームウェア開発用ライブラリー群

最終更新日：2024/4/12

## 概要

ファームウェア開発用のライブラリー群です。

## 機能

最終更新日現在、以下の機能を実装しています。

- TFT制御機能
- 管理機能
- FIDOプロトコル機能

### TFT制御機能

超小型TFTディスプレイを制御する機能を実装しています。<br>
詳細につきましては、<b>[Tiny TFT Library](../../Markdowns/Firmwares/TINYTFTLIB.md)</b>をご参照願います。

### 管理機能

下記の管理コマンドを実装しています。

- ペアリング解除要求
- Flash ROM情報照会
- バージョン情報照会
- 現在時刻設定
- 現在時刻照会

### FIDOプロトコル機能
[FIDOアライアンス](https://fidoalliance.org)制定プロトコルに基づいた以下の機能を実装しています。
- Bluetooth経由のデータ送受信
- FIDOコマンド体系に則ったコマンド実行

前述の管理コマンドは、FIDOにおけるベンダー固有コマンド（[Vendor specific commands](https://fidoalliance.org/specs/fido-v2.1-ps-20210615/fido-client-to-authenticator-protocol-v2.1-ps-errata-20220621.html#usb-vendor-specific-commands)）として実装されております。

最終更新日現在、FIDOアライアンス制定の[CTAP 2.1](https://fidoalliance.org/specs/fido-v2.1-ps-20210615/fido-client-to-authenticator-protocol-v2.1-ps-errata-20220621.html)、[U2F 1.2](https://web.archive.org/web/20220621122647/https://fidoalliance.org/specs/fido-u2f-v1.2-ps-20170411/)というプロトコルに準拠しています。<br>
ただし、本ライブラリーは、FIDOアライアンス認証を受けた物件ではございませんので、ご注意願います。

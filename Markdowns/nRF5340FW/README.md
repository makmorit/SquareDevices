# nRF5340ファームウェア

最終更新日：2024/4/5

## 概要

nRF5340基板上で稼働するファームウェアです。<br>
[nRF Connect SDK v2.5.2](https://developer.nordicsemi.com/nRF_Connect_SDK/doc/2.5.2/nrf/index.html)を使用し、開発しています。

## 搭載機能

最終更新日現在、ファームウェア更新機能／管理機能を搭載しております。

### ファームウェア更新機能
Bluetooth経由のファームウェア更新機能（DFU）を用意しています。<br>
nRF5340上のファームウェアを、[デスクトップツール](../../Markdowns/DesktopTools/README.md)により最終版に更新することができます。

### 管理機能

下記の管理コマンドを、デスクトップツールから実行することができます。

- ペアリング解除要求
- Flash ROM情報照会
- バージョン情報照会
- 現在時刻設定
- 現在時刻照会

## ファームウェア

nRF5340ファームウェアの更新イメージファイル最終版（Version `0.0.4`）は、フォルダー[`firmwares`](../../nRF5340FW/firmwares) に格納しています。

## 開発ドキュメント

### 開発環境構築手順

以下の手順書をご参照願います。

- <b>[nRF Connect SDKインストール手順書](../../Markdowns/nRF5340FW/NCSINST.md)</b>
- <b>[nRF Connect SDK動作確認手順書](../../Markdowns/nRF5340FW/NCSTEST.md)</b>

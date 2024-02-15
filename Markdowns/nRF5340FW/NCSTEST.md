# nRF Connect SDK動作確認手順書

最終更新日：2024/02/15

macOSにインストールされた「[nRF Connect SDK v2.5.2](https://developer.nordicsemi.com/nRF_Connect_SDK/doc/2.5.2/nrf/index.html)」の動作確認手順について掲載します。

## 使用したシステム

PC: iMac (Retina 5K, 27-inch, 2019)<br>
OS: macOS 12.7.2<br>
（サンプルアプリのビルド／書き込み環境として使用）

開発ボード: [nRF5340 DK](https://www.nordicsemi.com/Products/Development-hardware/nrf5340-dk)<br>
（サンプルアプリの書き込み先として使用）

スマートフォン: HUAWEI nova lite 2<br>
OS: Android 8.0.0<br>
（サンプルアプリの動作確認時に使用）

## 手順の概要

- <b>ソフトウェアのインストール</b><br>
本手順書で必要となる各種ソフトウェアを、macOSにインストールします。

- <b>サンプルアプリのビルド</b><br>
Nordic社から公開されているサンプルアプリ「[Peripheral UART](https://developer.nordicsemi.com/nRF_Connect_SDK/doc/2.5.2/nrf/samples/bluetooth/peripheral_uart/README.html)」を、nRF Connect SDKでビルドします。

- <b>サンプルアプリの書込み</b><br>
nRF5340 DKを初期化した後、ビルドしたサンプルアプリを、nRF5340 DKに書込みます。

- <b>サンプルアプリの動作確認</b><br>
Androidアプリ「nRF Connect」を使用し、nRF5340 DKに書き込んだ「Peripheral UART」が正常に動作することを確認します。

## サンプルアプリのビルド

Nordic社から公開されているサンプルアプリ「Peripheral UART」を、nRF Connect SDKでビルドします。

### サンプルアプリのコピー

nRF Connect SDKのサンプルアプリを、適宜フォルダーにコピーします。

```
bash-3.2$ cd ${HOME}/GitHub/SquareDevices/nRF5340FW/
bash-3.2$ cp -pr ${HOME}/opt/ncs_2.5.2/nrf/samples/bluetooth/peripheral_uart .
bash-3.2$ ls -al
total 24
:
drwxr-xr-x  17 makmorit  staff    544  2 12 11:36 peripheral_uart
:
bash-3.2$
```

### ビルド用スクリプトを配置

ビルド用スクリプト`westbuild.sh`を作成し、プロジェクトフォルダー配下に配置したのち、実行権限を付与します。<br>
（実行時のスクリプト`westbuild.sh`は<b>[こちら](scripts/westbuild.sh)</b>）

```
bash-3.2$ cd ${HOME}/GitHub/SquareDevices/nRF5340FW/peripheral_uart
bash-3.2$ ls -al
total 128
:
-rw-r--r--   1 makmorit  staff    882  2 15 12:02 westbuild.sh
bash-3.2$ chmod +x westbuild.sh
bash-3.2$ ls -al
total 128
:
-rwxr-xr-x   1 makmorit  staff    882  2 15 12:02 westbuild.sh
bash-3.2$

```

### ビルド実行

ビルド用スクリプト`westbuild.sh`を実行し、プロジェクトをビルド（コンパイル、リンク）します。<br>
（実行時のログ`westbuild.log`は<b>[こちら](logs/westbuild.log)</b>）

```
bash-3.2$ cd ${HOME}/GitHub/SquareDevices/nRF5340FW/peripheral_uart
bash-3.2$ ./westbuild.sh > westbuild.log 2>&1
bash-3.2$ echo $?
0
bash-3.2$
```

以上で、サンプルアプリのビルドは完了です。

## サンプルアプリの書込み

nRF5340 DKを初期化した後、ビルドしたサンプルアプリを、nRF5340 DKに書込みます。

### nRF5340の初期化

サンプルアプリを書き込みする前に、nRF5340のFlash ROMを初期化します。

[nRF Connect for Desktop](https://www.nordicsemi.com/Products/Development-tools/nrf-connect-for-desktop/download)のProgrammerというアプリを使用すると、nRF5340のFlash ROMに書き込まれているプログラムやデータ等が一括削除できます。<br>
手順につきましては、別ドキュメント「[nRF5340 DK初期化手順書](../../Markdowns/nRF5340FW/NRFDKINIT.md)」をご参照願います。

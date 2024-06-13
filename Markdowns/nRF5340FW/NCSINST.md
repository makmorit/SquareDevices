# nRF Connect SDKインストール手順書

最終更新日：2024/06/13

「[nRF Connect SDK v2.6.1](https://developer.nordicsemi.com/nRF_Connect_SDK/doc/2.6.1/nrf/index.html)」をmacOSにインストールする手順について掲載します。

## 使用したシステム

PC: iMac (Retina 5K, 27-inch, 2019)<br>
OS: macOS 12.7.2

## macOS環境の準備

下記リンク先の記述を参考に、各種コマンドをmacOS環境に導入します。<br>
https://developer.nordicsemi.com/nRF_Connect_SDK/doc/2.5.2/nrf/installation/installing.html#install-the-required-tools

以下のコマンドを実行します。（実行例は<b>[こちら](logs/install_brew.log)</b>）

```
brew install cmake ninja gperf python3 ccache qemu dtc wget libmagic
brew list --versions
```

## Python環境の準備

別途、Homebrew等によりインストールした<b>Python 3.8</b>を使用し、Python仮想環境を作成します。<br>
必要なPythonライブラリー（モジュール）は、全て仮想環境下にインストールします。

#### 仮想環境の作成

本例では、`${HOME}/opt/ncs_2.6.1`というフォルダーに、Pythonの仮想環境を作成するものとします。<br>
以下のコマンドを実行します。

```
cd ${HOME}/opt
python -m venv ncs_2.6.1
```

以下は実行例になります。

```
bash-3.2$ cd ${HOME}/opt
bash-3.2$ python -m venv ncs_2.6.1
bash-3.2$
```

#### 仮想環境に入る

仮想環境に入るためには、仮想環境フォルダーでコマンド`source bin/activate`を実行します。

```
bash-3.2$ cd ${HOME}/opt/ncs_2.6.1
bash-3.2$ source bin/activate
(ncs_2.6.1) bash-3.2$
```

`(ncs_2.6.1) bash-3.2$ `というコマンドプロンプト表示により、仮想環境に入ったことが確認できます。

#### 仮想環境から抜ける

仮想環境から通常のシェルに戻るためには、コマンド`deactivate`を実行します。

```
(ncs_2.6.1) bash-3.2$ deactivate
bash-3.2$
```

`bash-3.2$`というコマンドプロンプト表示により、仮想環境を抜け、通常のシェルに戻ったことが確認できます。

## westツールの更新

仮想環境に入り、最新のwestツールを取得します。<br>
以下のコマンドを実行します。（実行例は<b>[こちら](logs/install_west.log)</b>）

```
pip3 install west
```

## nRF Connect SDKのインストール

前述のwestツールを使用し、nRF Connect SDKのインストールを行います。<br>
こちらも、あらかじめ仮想環境に入った上で実施してください。

参考：https://developer.nordicsemi.com/nRF_Connect_SDK/doc/2.5.2/nrf/installation/installing.html#get-the-ncs-code

#### リポジトリーのチェックアウト

GitHubリポジトリーから「nRF Connect SDK v2.6.1」の全ファイルイメージをチェックアウトします。<br>
ターミナルから以下のコマンドを実行します。（実行例は<b>[こちら](logs/west.log)</b>）

```
west init -m https://github.com/nrfconnect/sdk-nrf --mr v2.6.1
west update
west zephyr-export
```

#### 依存ライブラリーの導入

nRF Connect SDKの依存ライブラリーを、前述の仮想環境にインストールします。<br>
以下のコマンドを実行します。（実行例は<b>[こちら](logs/pip3.log)</b>）

```
pip install -r zephyr/scripts/requirements.txt
pip install -r nrf/scripts/requirements.txt
pip install -r bootloader/mcuboot/scripts/requirements.txt
```

## Zephyr SDKのインストール

下記リンク先の記述を参考に、コンパイル、リンク等を実行するための各種コマンドをmacOS環境に導入します。<br>
https://developer.nordicsemi.com/nRF_Connect_SDK/doc/2.5.2/nrf/installation/installing.html#install-the-zephyr-sdk

#### SDKのダウンロード

Zephyr SDKのバンドルをダウンロードします。
以下のコマンドを実行します。（実行例は<b>[こちら](logs/zephyr_sdk_dl.log)</b>）

```
cd ${HOME}/Downloads/
wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.5/zephyr-sdk-0.16.5_macos-x86_64.tar.xz
wget -O - https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.5/sha256.sum | shasum --check --ignore-missing
```

#### SDKの導入

ダウンロードしたZephyr SDKのバンドルを解凍して導入します。
以下のコマンドを実行します。（実行例は<b>[こちら](logs/zephyr_sdk_inst.log)</b>）

```
cd ${HOME}/opt
tar xvf ${HOME}/Downloads/zephyr-sdk-0.16.5_macos-x86_64.tar.xz
```

#### SDKの設定

導入したZephyr SDKを利用できるようにするための設定スクリプトを実行します。
以下のコマンドを実行します。（実行例は<b>[こちら](logs/zephyr_sdk_setup.log)</b>）

```
cd ${HOME}/opt/zephyr-sdk-0.16.5
./setup.sh
```

以上で、nRF Connect SDKのインストールは完了です。

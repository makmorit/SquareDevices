# nRF Connect SDKインストール手順書

最終更新日：2024/02/12

「[nRF Connect SDK v2.5.2](https://developer.nordicsemi.com/nRF_Connect_SDK/doc/2.5.2/nrf/index.html)」をmacOSにインストールする手順について掲載します。

## 使用したシステム

PC: iMac (Retina 5K, 27-inch, 2019)<br>
OS: macOS 12.7.2

## 前提条件

まずは下記手順書により、各種ソフトウェアがインストールされていることを前提とします。<br>

- <b>[ARM GCCインストール手順](../../Markdowns/nRF5340FW/ARMGCCINST.md)</b><br>
コンパイル、リンク等を実行するためのコマンドラインツール群がインストールされます。

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

本例では、`${HOME}/opt/ncs_2.5.2`というフォルダーに、Pythonの仮想環境を作成するものとします。<br>
以下のコマンドを実行します。

```
cd ${HOME}/opt
python -m venv ncs_2.5.2
```

以下は実行例になります。

```
bash-3.2$ cd ${HOME}/opt
bash-3.2$ python -m venv ncs_2.5.2
bash-3.2$
```

#### 仮想環境に入る

仮想環境に入るためには、仮想環境フォルダーでコマンド`source bin/activate`を実行します。

```
bash-3.2$ cd ${HOME}/opt/ncs_2.5.2
bash-3.2$ source bin/activate
(ncs_2.5.2) bash-3.2$
```

`(ncs_2.5.2) bash-3.2$ `というコマンドプロンプト表示により、仮想環境に入ったことが確認できます。

#### 仮想環境から抜ける

仮想環境から通常のシェルに戻るためには、コマンド`deactivate`を実行します。

```
(ncs_2.5.2) bash-3.2$ deactivate
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

GitHubリポジトリーから「nRF Connect SDK v2.5.2」の全ファイルイメージをチェックアウトします。<br>
ターミナルから以下のコマンドを実行します。（実行例は<b>[こちら](logs/west.log)</b>）

```
west init -m https://github.com/nrfconnect/sdk-nrf --mr v2.5.2
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

以上で、nRF Connect SDKのインストールは完了です。

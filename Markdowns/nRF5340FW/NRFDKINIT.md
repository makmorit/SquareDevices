# nRF5340 DK初期化手順書

最終更新日：2024/02/15

[nRF5340 DK](https://www.nordicsemi.com/Products/Development-hardware/nrf5340-dk)のFlash ROMの初期化手順について掲載します。

[nRF Connect for Desktop](https://www.nordicsemi.com/Products/Development-tools/nrf-connect-for-desktop/download)のProgrammerというアプリを使用すると、nRF5340のFlash ROMに書き込まれているプログラムやデータ等が一括削除できます。

## nRF5340 DKに接続

まずはProgrammerを起動します。<br>
nRF Connect for Desktopを起動し、下図のアプリ一覧から「Programmer」を選択し「Open」をクリックします。

<img src="images/NRFDKINIT_01.jpg" width="400">

Programmerが起動します。<br>
画面左上部の「SELECT DEVICE」を実行します。

<img src="images/NRFDKINIT_02.jpg" width="400">

一覧にnRF5340 DKがリストされるので、nRF5340 DKを選択します。

<img src="images/NRFDKINIT_03.jpg" width="400">

nRF5340 DKと接続されます。<br>
その後、接続されたnRF5340 DKのFlash ROM内容の参照処理が自動的に開始されます。

<img src="images/NRFDKINIT_04.jpg" width="400">

下図のように、Flash ROM内容の参照結果が右側のグラフに表示されます。

<img src="images/NRFDKINIT_05.jpg" width="400">

これで、nRF5340 DKとの接続は完了となります。

## nRF5340 DKを初期化

Programmer画面左部メニューの「Erase all」を実行します。

<img src="images/NRFDKINIT_06.jpg" width="400">

初期化処理が開始し、nRF5340のFlash ROMに書き込まれているプログラムやデータ等が一括削除されます。

<img src="images/NRFDKINIT_07.jpg" width="400">

初期化処理が完了したら、その後、nRF5340 DKとの接続を解除します。<br>
画面左上部の三角印のアイコン「Disconnect device」をクリックします。

<img src="images/NRFDKINIT_08.jpg" width="400">

接続を解除したら「Quit nRF Connect for Desktop」をクリックし、Programmerを終了します。

<img src="images/NRFDKINIT_09.jpg" width="400">

以上で、nRF5340 DKの初期化は完了になります。

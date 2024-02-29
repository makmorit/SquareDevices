# インストール手順書

最終更新日：2024/2/29

## 概要
デスクトップツールをWindows環境にインストールする手順について掲載しています。

## インストール媒体の取得

[Windows版 デスクトップツール](../../../DesktopTools/dotNET/DesktopTool/dotNET_DesktopTool.zip)を、GitHubからダウンロード／解凍します。<br>
該当ページの「Download」ボタンをクリックすると、[dotNET_DesktopTool.zip](../../../DesktopTools/dotNET/DesktopTool/dotNET_DesktopTool.zip)がダウンロードできます。

<img src="images/INSTALL_01.jpg" width="640">

ダウンロードが完了したら、ダウンロードフォルダーを開きます。<br>
次に、ダウンロードしたファイル`dotNET_DesktopTool.zip`を解凍してください。

<img src="images/INSTALL_02.jpg" width="450">

解凍された`setup.exe`と`SetupWizard.msi`の２点のファイルが、インストール媒体になります。

<img src="images/INSTALL_03.jpg" width="450">

## インストールの実行

前述の実行ファイル`setup.exe`をダブルクリックして実行してください。

<img src="images/INSTALL_03.jpg" width="450">

最終更新日現在、アプリに署名がされていないため、ダウンロードしたプログラムを実行できない旨のダイアログが表示されます。<br>
「詳細情報」をクリックします。

<img src="images/INSTALL_04.jpg" width="300">

画面表示が変わり「実行」ボタンが表示されますので、その「実行」ボタンをクリックします。

<img src="images/INSTALL_05.jpg" width="300">

インストーラーが起動しますので、指示に従いインストールを進めます。

<img src="images/INSTALL_06.jpg" width="300">

インストールが正常に完了したら「閉じる」をクリックし、インストーラーを終了させます。

<img src="images/INSTALL_07.jpg" width="300">

Windowsのスタートメニューに、アイコン「SquareDevices Desktop Tool」が表示されることを確認します。<br>
アイコンを右クリックし、インストールされたデスクトップツールを実行します。

<img src="images/INSTALL_08.jpg" width="350">

「アプリがデバイスに変更を加えることを許可しますか？」というメッセージが表示されます。[注1]<br>
「はい」ボタンをクリックすると、ツールが起動します。

<img src="images/INSTALL_10.jpg" width="250">

デスクトップツールの画面が起動すれば、インストールは完了です。

<img src="assets01/0001.jpg" width="400">

[注1] Windows 10のバージョン「Windows 10 November 2019 Update」以降においては、管理者として実行されていないプログラムの場合、BLEデバイスとの直接的なBluetooth通信ができない仕様となったようです。Windows版デスクトップツールでは、BLEデバイスとの直接的なBluetooth通信が必要なため、管理者として実行させるようにしております。その影響で、ツール起動のたびに「アプリがデバイスに変更を加えることを許可しますか？」というメッセージが表示されてしまいますが（下図ご参照）、不具合ではありません。

<img src="images/INSTALL_09.jpg" width="200">

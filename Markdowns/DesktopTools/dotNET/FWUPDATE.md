# ファームウェア更新手順書

最終更新日：2024/4/22

## 概要

デスクトップツールを使用して、PC環境から、nRF5340基板のファームウェアを更新する手順について掲載しています。

## 手順

デスクトップツールの左側メニュー「ファームウェア更新」をクリックします。

<img src="images/FWUPDATE_01.jpg" width="280">

ファームウェア更新画面が表示されますので「実行」をクリックします。

<img src="images/FWUPDATE_02.jpg" width="280">

ファームウェア更新のための前処理が実行されるので、しばらく待ちます。

<img src="images/FWUPDATE_03.jpg" width="280">

ファームウェア更新処理を開始する前に、確認メッセージがポップアップ表示されます。<br>
「はい」ボタンをクリックすると、ファームウェア更新処理が開始されます。

<img src="images/FWUPDATE_04.jpg" width="280">

ファームウェア更新処理が開始されると、更新処理の進捗表示画面がポップアップ表示されます。

<img src="images/FWUPDATE_05.jpg" width="280">

ほどなく、デスクトップツールに同梱された、最新のファームウェア更新イメージデータが、nRF5340基板へ転送されます。

<img src="images/FWUPDATE_06.jpg" width="280">

ファームウェア更新イメージデータの転送が完了すると、転送されたファームウェアを反映するため、nRF5340基板が自動的に再始動されます。<br>
デスクトップツール側では、下図のようなメッセージを表示し、ファームウェア反映処理が完了するまで待機します。

<img src="images/FWUPDATE_07.jpg" width="280">

デスクトップツールは最後に、ファームウェアのバージョンを確認し、更新ファームウェアが正しく反映されたかどうかチェックします。<br>
チェックが正常であれば、ファームウェア更新が成功した旨のメッセージが表示されます。<br>
「閉じる」ボタンをクリックし、ファームウェア更新画面を閉じます。

<img src="images/FWUPDATE_08.jpg" width="280">

以上で、ファームウェア更新は完了となります。

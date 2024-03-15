# ペアリング手順書

最終更新日：2024/3/14

## 概要

デスクトップツールを使用して、PC環境にnRF5340基板をペアリングする手順について掲載しています。

## ペアリングの実行

デスクトップツールの左側メニュー「ペアリング実行」をクリックします。

<img src="images/BLEPAIR_01.jpg" width="400">

ツール画面右側に、ペアリング実行画面が表示されますので「実行」をクリックします。

<img src="images/BLEPAIR_02.jpg" width="400">

パスコード入力画面がポップアップ表示されます。<br>
nRF5340基板がTFTディスプレイに表示したパスコード（６桁の数字）を入力し「ペアリング実行」ボタンをクリックします。

<img src="images/BLEPAIR_03.jpg" width="400">

ペアリング処理が開始されますので、そのまま待ちます。<br>
ペアリング処理が正常終了すると、下図のようなメッセージが表示され、処理が成功したことを知らせます。

<img src="images/BLEPAIR_04.jpg" width="400">

WindowsのBluetooth設定画面を開き「SquareDevice53」が表示されている事を確認します。

<img src="images/BLEPAIR_05.jpg" width="480">

以上で、ペアリングの実行は完了です。

## ペアリング解除の実行

PC環境とnRF5340基板のペアリングを解除するには、ペアリング解除要求を実行します。<br>
デスクトップツールの左側メニュー「ペアリング解除要求」をクリックします。

<img src="images/BLEUNPAIR_01.jpg" width="400">

ツール画面右側に、ペアリング解除要求画面が表示されますので「実行」をクリックします。

<img src="images/BLEUNPAIR_02.jpg" width="400">

解除要求を待機するメッセージが、残り秒数を表示するバーと一緒にポップアップ表示されます。

<img src="images/BLEUNPAIR_03.jpg" width="400">

上図メッセージが表示されている間に、WindowsのBluetooth設定画面から「SquareDevice53」を選択します。<br>
「デバイスの削除」ボタンが表示されるので、ボタンをクリックします。

<img src="images/BLEUNPAIR_05.jpg" width="480">

確認メッセージがポップアップ表示されるので「はい」をクリックします。

<img src="images/BLEUNPAIR_06.jpg" width="480">

WindowsのBluetooth設定画面から「SquareDevice53」が消去され、nRF5340基板とのペアリングが解除されたことを確認します。

<img src="images/BLEUNPAIR_07.jpg" width="480">

一方、デスクトップツール側でも下図のようなメッセージが表示され、ペアリング解除要求処理が成功したことを知らせます。

<img src="images/BLEUNPAIR_04.jpg" width="400">

以上で、ペアリング解除の実行は完了です。

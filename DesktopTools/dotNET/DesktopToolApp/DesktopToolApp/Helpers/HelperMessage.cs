namespace DesktopTool
{
    internal class HelperMessage
    {
        // BLEペアリング
        public const string MSG_BLE_PARING_ERR_BT_STATUS_CANNOT_GET = "Bluetooth状態を確認できません。";
        public const string MSG_BLE_PARING_ERR_BT_OFF = "Bluetoothがオフになっています。Bluetoothをオンにしてください。";
        public const string MSG_BLE_PARING_ERR_TIMED_OUT = "ペアリング対象のBLEデバイスが停止している可能性があります。BLEデバイスの電源を入れ、PCのUSBポートから外してください。";
        public const string MSG_BLE_PARING_ERR_ALREADY_PAIRED = "ペアリング対象のBLEデバイスと既にペアリングされていたようです。WindowsのBluetooth環境設定画面から、デバイス「{0}」を削除した後、ペアリングを再実行してください。";
        public const string MSG_BLE_PARING_ERR_PROCESS = "BLEデバイスとのペアリング時にエラーが発生しました。";
        public const string MSG_BLE_PARING_ERR_UNKNOWN = "BLEデバイスとのペアリング時に不明なエラーが発生しました。";
    }
}

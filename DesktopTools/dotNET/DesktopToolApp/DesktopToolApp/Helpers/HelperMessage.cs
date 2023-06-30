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
        public const string MSG_BLE_PARING_ERR_CANCELED_BY_USER = "BLEデバイスとのペアリング実行をユーザーが中止しました。";

        // BLEサービス
        public const string MSG_BLE_U2F_NOTIFICATION_RETRY = "受信データ監視開始を再試行しています（{0}回目）";
        public const string MSG_BLE_U2F_NOTIFICATION_START = "受信データの監視を開始します。";
        public const string MSG_BLE_U2F_NOTIFICATION_FAILED = "BLEサービスからデータを受信できません。";
        public const string MSG_BLE_U2F_SERVICE_FINDING = "BLEサービス({0})を検索します。";
        public const string MSG_BLE_U2F_DEVICE_NOT_FOUND = "BLEサービスが動作するデバイスが見つかりません。";
        public const string MSG_BLE_U2F_SERVICE_NOT_FOUND = "BLEサービスが見つかりません。";
        public const string MSG_BLE_U2F_SERVICE_FOUND = "BLEサービスが見つかりました。";

        // トランスポート共通
        public const string MSG_REQUEST_SEND_FAILED = "リクエスト送信が失敗しました。";
        public const string MSG_REQUEST_SEND_FAILED_WITH_EXCEPTION = "リクエスト送信が失敗しました：{0}";
        public const string MSG_REQUEST_SEND_TIMED_OUT = "リクエスト送信がタイムアウトしました。";
        public const string MSG_RESPONSE_RECEIVE_FAILED_WITH_EXCEPTION = "レスポンス受信が失敗しました：{0}";

        // コマンド共通
        public const string MSG_ERROR_FUNCTION_IN_PAIRING_MODE = "ペアリングモードでは、ペアリング実行以外の機能は使用できません。ペアリングモードを解除してから、機能を再度実行してください。";
        public const string MSG_SCAN_BLE_DEVICE_SUCCESS = "対象のBLEデバイスがスキャンされました。";
        public const string MSG_CONNECT_BLE_DEVICE_FAILURE = "BLEデバイスの接続に失敗しました。";
        public const string MSG_CONNECT_BLE_DEVICE_SUCCESS = "BLEデバイスに接続しました。";
        public const string MSG_NOTIFY_DISCONNECT_BLE_DEVICE = "BLEデバイスからの切断を検知しました。接続を終了します。";
        public const string MSG_DISCONNECT_BLE_DEVICE = "BLEデバイスから切断しました。";
    }
}

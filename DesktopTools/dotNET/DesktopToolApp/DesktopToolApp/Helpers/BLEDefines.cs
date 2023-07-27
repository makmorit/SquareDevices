namespace DesktopTool
{
    internal class BLEDefines
    {
        // BLEサービスに関する定義
        public const string U2F_BLE_SERVICE_UUID_STR = "0000FFFD-0000-1000-8000-00805f9b34fb";
        public const string U2F_CONTROL_POINT_CHAR_UUID_STR = "F1D0FFF1-DEAA-ECEE-B42F-C9BA7ED623BB";
        public const string U2F_STATUS_CHAR_UUID_STR = "F1D0FFF2-DEAA-ECEE-B42F-C9BA7ED623BB";

        public const string BLE_SMP_SERVICE_UUID_STR = "8D53DC1D-1DB7-4CD3-868B-8A527460AA84";
        public const string BLE_SMP_CHARACT_UUID_STR = "DA2E7828-FBCE-4E01-AE9E-261174997C48";

        // BLEフレームに関する定数
        public const int U2F_BLE_INIT_HEADER_LEN = 3;
        public const int U2F_BLE_CONT_HEADER_LEN = 1;
        public const int U2F_BLE_FRAME_LEN = 64;

        public const int SMP_HEADER_SIZE = 8;

        // 性能関連
        public const int U2F_BLE_SERVICE_RESP_TIMEOUT_MSEC = 3000;

        // 定数
        public const uint WINDOWS_ERROR_NO_MORE_FILES = 0x80650012;
    }
}

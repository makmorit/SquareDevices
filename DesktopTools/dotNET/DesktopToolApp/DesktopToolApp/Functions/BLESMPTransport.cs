using static DesktopTool.BLEDefines;

namespace DesktopTool
{
    internal class BLESMPTransport : BLETransport
    {
        //
        // 接続処理
        //
        protected override void SetupBLEService(BLEPeripheralScannerParam parameter)
        {
            // 接続サービスを設定
            BLEServiceParam serviceParam = new BLEServiceParam(parameter, BLE_SMP_CHARACT_UUID_STR, BLE_SMP_CHARACT_UUID_STR);
            BLEService service = new BLEService();

            // サービスに接続
            ConnectBLEService(service, serviceParam);
        }
    }
}

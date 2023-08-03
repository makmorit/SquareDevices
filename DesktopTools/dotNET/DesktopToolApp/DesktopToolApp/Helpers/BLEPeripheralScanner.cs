using AppCommon;
using System;
using System.Linq;
using System.Threading.Tasks;
using Windows.Devices.Bluetooth.Advertisement;
using Windows.Devices.Radios;
using Windows.Storage.Streams;
using static DesktopTool.HelperMessage;

namespace DesktopTool
{
    internal class BLEPeripheralScannerParam
    {
        public Guid ServiceUUID { get; set; }
        public ulong BluetoothAddress { get; set; }
        public byte[] ServiceDataField { get; set; }
        public bool FIDOServiceDataFieldFound { get; set; }
        public bool BLEPeripheralFound { get; set; }
        public bool ConnectOnly { get; set; }

        public BLEPeripheralScannerParam(string serviceUUIDString)
        {
            ServiceUUID = new Guid(serviceUUIDString);
            BluetoothAddress = 0;
            ServiceDataField = Array.Empty<byte>();
            FIDOServiceDataFieldFound = false;
            BLEPeripheralFound = false;
            ConnectOnly = false;
        }
    }

    internal class BLEPeripheralScanner
    {
        // 上位クラスに対するイベント通知
        public delegate void HandlerOnBLEPeripheralFound(bool success, string errorMessage, BLEPeripheralScannerParam parameter);
        private event HandlerOnBLEPeripheralFound BLEPeripheralFound = null!;

        // 戻り先の関数を保持
        private HandlerOnBLEPeripheralFound HandlerRef = null!;

        // スキャン処理のパラメーターを保持
        private BLEPeripheralScannerParam Parameter = null!;

        // スキャンに使用するWatcherを保持
        private readonly BluetoothLEAdvertisementWatcher Watcher = null!;

        // コンストラクター
        public BLEPeripheralScanner()
        {
            // Watcherを初期化
            Watcher = new BluetoothLEAdvertisementWatcher();
            Watcher.Received += OnAdvertisementReceived;
        }

        public void DoProcess(BLEPeripheralScannerParam parameter, HandlerOnBLEPeripheralFound handler)
        {
            // パラメーターを保持
            Parameter = parameter;

            // 戻り先の関数を保持
            HandlerRef = handler;
            BLEPeripheralFound += HandlerRef;

            // BLEデバイスを検索
            ScanBLEPeripheral();
        }

        private void OnProcessTerminated(bool success, string errorMessage)
        {
            // スキャン結果情報、エラーメッセージを戻す
            BLEPeripheralFound(success, errorMessage, Parameter);

            // 呼出元クラスの関数コールバックを解除
            BLEPeripheralFound -= HandlerRef;
        }

        //
        // 内部処理
        //
        private async void ScanBLEPeripheral()
        {
            // Bluetoothがオンになっていることを確認
            bool bton = false;
            try {
                var radios = await Radio.GetRadiosAsync();
                foreach (var radio in radios) {
                    if (radio.Kind == RadioKind.Bluetooth) {
                        if (radio.State == RadioState.On) {
                            bton = true;
                            break;
                        }
                    }
                }
            } catch {
                // Bluetoothオン状態が確認できない場合は失敗を通知
                OnProcessTerminated(false, MSG_BLE_PARING_ERR_BT_STATUS_CANNOT_GET);
                return;
            }

            if (bton == false) {
                // Bluetoothがオンになっていない場合は失敗を通知
                OnProcessTerminated(false, MSG_BLE_PARING_ERR_BT_OFF);
                return;
            }

            // BLEデバイスからのアドバタイズ監視を開始
            WatchAdvertisement();
        }

        private async void WatchAdvertisement()
        {
            // BLEデバイスからのアドバタイズ監視を開始
            AppLogUtil.OutputLogDebug("Watch BLE device advertisement start");
            Parameter.BluetoothAddress = 0;
            Watcher.Start();

            // BLEデバイスがみつかるまで待機（最大10秒）
            for (int i = 0; i < 10 && Parameter.BluetoothAddress == 0; i++) {
                await Task.Run(() => System.Threading.Thread.Sleep(1000));
            }

            // BLEデバイスからのアドバタイズ監視を終了
            Watcher.Stop();
            AppLogUtil.OutputLogDebug("Watch BLE device advertisement end");

            if (Parameter.BluetoothAddress == 0) {
                // BLEデバイスが見つからなかった場合は失敗を通知
                OnProcessTerminated(false, MSG_BLE_PARING_ERR_TIMED_OUT);
                return;
            }

            // FIDOのサービスデータフィールドが存在する場合はフラグを設定
            byte[] expect = { 0xfd, 0xff, 0x80 };
            if (Parameter.ServiceDataField.Length == 3 && Parameter.ServiceDataField.SequenceEqual(expect)) {
                Parameter.FIDOServiceDataFieldFound = true;
            }

            // BLEデバイスが見つかった場合は成功を通知
            Parameter.BLEPeripheralFound = true;
            OnProcessTerminated(true, string.Empty);
        }

        private void OnAdvertisementReceived(BluetoothLEAdvertisementWatcher watcher, BluetoothLEAdvertisementReceivedEventArgs eventArgs)
        {
            // BLEデバイスが見つかったら、アドレス情報を保持し、画面スレッドに通知
            foreach (Guid g in eventArgs.Advertisement.ServiceUuids) {
                if (g.Equals(Parameter.ServiceUUID)) {
                    Parameter.BluetoothAddress = eventArgs.BluetoothAddress;
                    AppLogUtil.OutputLogDebug("BLE device found.");
                    // アドバタイズデータからサービスデータフィールドを抽出
                    Parameter.ServiceDataField = RetrieveServiceDataField(eventArgs.Advertisement);
                    break;
                }
            }
        }

        private static byte[] RetrieveServiceDataField(BluetoothLEAdvertisement advertisement)
        {
            // アドバタイズデータを走査
            byte[] serviceDataField = Array.Empty<byte>();
            foreach (BluetoothLEAdvertisementDataSection datasection in advertisement.DataSections) {
                // サービスデータフィールドの場合は格納領域に設定
                byte dataType = datasection.DataType;
                if (dataType == 0x16) {
                    serviceDataField = new byte[datasection.Data.Length];
                    using (DataReader reader = DataReader.FromBuffer(datasection.Data)) {
                        reader.ReadBytes(serviceDataField);
                        break;
                    }
                }
            }
            if (serviceDataField.Length == 0) {
                AppLogUtil.OutputLogDebug("Service data field not found");
            } else {
                string dump = AppLogUtil.DumpMessage(serviceDataField, serviceDataField.Length);
                AppLogUtil.OutputLogDebug(string.Format("Service data field found ({0} bytes) {1}", serviceDataField.Length, dump));
            }
            return serviceDataField;
        }
    }
}

using AppCommon;
using System;
using System.Threading.Tasks;
using Windows.Devices.Bluetooth;
using Windows.Devices.Bluetooth.GenericAttributeProfile;
using static DesktopTool.HelperMessage;

namespace DesktopTool
{
    internal class BLEServiceParam
    {
        public Guid ServiceUUID { get; set; }
        public Guid CharactForWriteUUID { get; set; }
        public Guid CharactForReadUUID { get; set; }
        public ulong BluetoothAddress { get; set; }

        public BLEServiceParam(BLEPeripheralScannerParam param)
        {
            ServiceUUID = param.ServiceUUID;
            CharactForWriteUUID = param.CharactForWriteUUID;
            CharactForReadUUID = param.CharactForReadUUID;
            BluetoothAddress = param.BluetoothAddress;
        }
    }

    internal class BLEService
    {
        //
        // BLE接続／送受信関連
        //
        // サービスをディスカバーできたデバイスを保持
        private BluetoothLEDevice BluetoothLEDevice = null!;
        private GattDeviceService BLEservice = null!;
        private GattCharacteristic U2FStatusChar = null!;

        // ステータスを保持
        private GattCommunicationStatus CommunicationStatus;

        public async Task<bool> StartCommunicate(BLEServiceParam parameter)
        {
            // Bluetoothアドレスが不正の場合は処理を実行しない
            if (parameter.BluetoothAddress == 0) {
                FreeResources();
                return false;
            }

            // サービスをディスカバー
            if (await DiscoverBLEService(parameter) == false) {
                FreeResources();
                return false;
            }

            //
            // データ受信監視を開始
            // リトライ上限は３回とする
            //
            int retry = 3;
            for (int k = 0; k < retry + 1; k++) {
                if (k > 0) {
                    AppLogUtil.OutputLogWarn(string.Format(MSG_BLE_U2F_NOTIFICATION_RETRY, k));
                    await Task.Run(() => System.Threading.Thread.Sleep(100));
                }

                if (await StartBLENotification(BLEservice, parameter)) {
                    AppLogUtil.OutputLogInfo(string.Format("{0}({1})", MSG_BLE_U2F_NOTIFICATION_START, BLEservice.Device.Name));
                    return true;
                }

                // 物理接続がない場合は再試行せず、明示的に接続オブジェクトを破棄
                if (CommunicationStatus == GattCommunicationStatus.Unreachable) {
                    StopCommunicate();
                    return false;
                }
            }

            // 接続されなかった場合は false
            AppLogUtil.OutputLogError(string.Format("{0}({1})", MSG_BLE_U2F_NOTIFICATION_FAILED, BLEservice.Device.Name));
            return false;
        }

        private async Task<bool> DiscoverBLEService(BLEServiceParam parameter)
        {
            try {
                AppLogUtil.OutputLogInfo(string.Format(MSG_BLE_U2F_SERVICE_FINDING, parameter.ServiceUUID));
                BluetoothLEDevice = await BluetoothLEDevice.FromBluetoothAddressAsync(parameter.BluetoothAddress);
                if (BluetoothLEDevice == null) {
                    AppLogUtil.OutputLogError(MSG_BLE_U2F_DEVICE_NOT_FOUND);
                    return false;
                }

                var gattServices = await BluetoothLEDevice.GetGattServicesAsync();
                foreach (var gattService in gattServices.Services) {
                    if (gattService.Uuid.Equals(parameter.ServiceUUID)) {
                        BLEservice = gattService;
                        AppLogUtil.OutputLogDebug(string.Format("  FIDO BLE service found [{0}]", gattService.Device.Name));
                    }
                }

                if (BLEservice == null) {
                    AppLogUtil.OutputLogError(MSG_BLE_U2F_SERVICE_NOT_FOUND);
                    return false;
                }

                // 接続・切断検知ができるようにする
                BluetoothLEDevice.ConnectionStatusChanged += BLEConnectionStatusChanged;

                AppLogUtil.OutputLogInfo(MSG_BLE_U2F_SERVICE_FOUND);
                return true;

            } catch (Exception e) {
                AppLogUtil.OutputLogError(string.Format("BLEService.DiscoverBLEService: {0}", e.Message));
                return false;
            }
        }

        private async Task<bool> StartBLENotification(GattDeviceService service, BLEServiceParam parameter)
        {
            // ステータスを初期化（戻りの有無を上位関数で判別できるようにするため）
            CommunicationStatus = GattCommunicationStatus.Success;

            try {
                U2FStatusChar = service.GetCharacteristics(parameter.CharactForWriteUUID)[0];

                CommunicationStatus = await U2FStatusChar.WriteClientCharacteristicConfigurationDescriptorAsync(
                    GattClientCharacteristicConfigurationDescriptorValue.Notify);
                if (CommunicationStatus != GattCommunicationStatus.Success) {
                    AppLogUtil.OutputLogDebug(string.Format("BLEService.StartBLENotification: GattCommunicationStatus={0}", CommunicationStatus));
                    return false;
                }

                // 監視開始したサービスを退避
                BLEservice = service;
                return true;

            } catch (Exception e) {
                AppLogUtil.OutputLogError(string.Format("BLEService.StartBLENotification: {0}", e.Message));
                return false;
            }
        }

        //
        // 切断処理
        //
        public void Disconnect()
        {
            // 接続ずみの場合はBLEデバイスを切断
            if (IsConnected()) {
                StopCommunicate();
            }
        }

        private void StopCommunicate()
        {
            try {
                if (BLEservice != null) {
                    BLEservice.Dispose();
                }
                if (BluetoothLEDevice != null) {
                    BluetoothLEDevice.ConnectionStatusChanged -= BLEConnectionStatusChanged;
                    BluetoothLEDevice.Dispose();
                }

            } catch (Exception e) {
                AppLogUtil.OutputLogError(string.Format("BLEService.StopCommunicate: {0}", e.Message));

            } finally {
                FreeResources();
            }
        }

        public bool IsConnected()
        {
            if (BluetoothLEDevice == null) {
                // 接続されていない場合は false
                return false;
            }

            if (BLEservice == null) {
                // データ受信ができない場合は false
                return false;
            }

            // BLE接続されている場合は true
            return true;
        }

        private void FreeResources()
        {
            // オブジェクトへの参照を解除
            BluetoothLEDevice = null!;
            BLEservice = null!;
            U2FStatusChar = null!;
        }

        public string ConnectedDeviceName()
        {
            if (BLEservice == null) {
                return string.Empty;
            } else {
                return BLEservice.Device.Name;
            }
        }

        //
        // BLE接続検知関連イベント
        //
        public delegate void HandlerOnConnectionStatusChanged(bool connected);
        private event HandlerOnConnectionStatusChanged OnConnectionStatusChanged = null!;

        private void BLEConnectionStatusChanged(BluetoothLEDevice sender, object args)
        {
            OnConnectionStatusChanged(sender.ConnectionStatus == BluetoothConnectionStatus.Connected);
        }
    }
}

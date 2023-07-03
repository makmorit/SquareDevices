using AppCommon;
using System;
using System.Threading.Tasks;
using Windows.Devices.Bluetooth;
using Windows.Devices.Bluetooth.GenericAttributeProfile;
using Windows.Storage.Streams;
using static DesktopTool.BLEDefines;
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
        // 応答タイムアウト監視用タイマー
        private readonly CommonTimer ResponseTimer = null!;

        public BLEService()
        {
            // 応答タイムアウト発生時のイベントを登録
            ResponseTimer = new CommonTimer("BLEService", 3000);
            ResponseTimer.CommandTimeoutEvent += OnResponseTimerElapsed;
            FreeResources();
        }

        //
        // BLE接続／送受信関連
        //
        // サービスをディスカバーできたデバイスを保持
        private BluetoothLEDevice BluetoothLEDevice = null!;
        private GattDeviceService BLEservice = null!;
        private GattCharacteristic U2FStatusChar = null!;
        private GattCharacteristic U2FControlPointChar = null!;

        // ステータスを保持
        private GattCommunicationStatus CommunicationStatus;

        //
        // BLE接続検知関連イベント
        //
        public delegate void ConnectionStatusChangedHandler(BLEService sender, bool connected);
        private event ConnectionStatusChangedHandler ConnectionStatusChanged = null!;

        private void BLEConnectionStatusChanged(BluetoothLEDevice sender, object args)
        {
            bool connected = (sender.ConnectionStatus == BluetoothConnectionStatus.Connected);
            AppLogUtil.OutputLogDebug(string.Format("Connection status changed: BLE device is {0}", connected ? "connected" : "disconnected"));

            if (ConnectionStatusChanged != null) {
                ConnectionStatusChanged(this, connected);
            }
        }

        public async Task<bool> StartCommunicate(BLEServiceParam parameter, ConnectionStatusChangedHandler handler)
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

            // 接続検知時のコールバックを設定
            ConnectionStatusChanged += handler;

            //
            // データ受信監視を開始
            // リトライ上限は３回とする
            //
            int retry = 3;
            for (int k = 0; k < retry + 1; k++) {
                if (k > 0) {
                    AppLogUtil.OutputLogDebug(string.Format(MSG_BLE_U2F_NOTIFICATION_RETRY, k));
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
            FreeResources();
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
                U2FControlPointChar = service.GetCharacteristics(parameter.CharactForReadUUID)[0];

                CommunicationStatus = await U2FStatusChar.WriteClientCharacteristicConfigurationDescriptorAsync(
                    GattClientCharacteristicConfigurationDescriptorValue.Notify);
                if (CommunicationStatus != GattCommunicationStatus.Success) {
                    AppLogUtil.OutputLogDebug(string.Format("BLEService.StartBLENotification: GattCommunicationStatus={0}", CommunicationStatus));
                    return false;
                }

                // BLEデバイスからの送信データを受信できるよう設定
                U2FStatusChar.ValueChanged += OnCharacteristicValueChanged;

                // 監視開始したサービスを退避
                BLEservice = service;
                return true;

            } catch (Exception e) {
                if ((uint)e.HResult != WINDOWS_ERROR_NO_MORE_FILES) {
                    AppLogUtil.OutputLogError(string.Format("BLEService.StartBLENotification: {0}", e.Message));
                }
                return false;
            }
        }

        //
        // 送受信関連イベント
        //
        public delegate void FrameReceivedHandler(BLEService sender, bool success, string errorMessage, byte[] frameBytes);
        private event FrameReceivedHandler FrameReceived = null!;

        public void RegisterFrameReceivedHandler(FrameReceivedHandler handler)
        {
            // コールバックを設定
            FrameReceived += handler;
        }

        public void UnregisterFrameReceivedHandler(FrameReceivedHandler handler)
        {
            // コールバック設定を解除
            FrameReceived -= handler;
        }

        private void OnFrameReceived(bool success, string errorMessage, byte[] frameBytes)
        {
            FrameReceived?.Invoke(this, success, errorMessage, frameBytes);
        }

        //
        // 送信処理
        // 
        public async void SendFrame(byte[] frameBytes)
        {
            if (BLEservice == null) {
                AppLogUtil.OutputLogDebug(string.Format("BLEService.SendFrame: service is null"));
                OnFrameReceived(false, MSG_REQUEST_SEND_FAILED, Array.Empty<byte>());
            }

            try {
                // リクエストデータを生成
                DataWriter writer = new DataWriter();
                for (int i = 0; i < frameBytes.Length; i++) {
                    writer.WriteByte(frameBytes[i]);
                }

                // リクエストを実行（U2F Control Pointに書込）
                if (U2FControlPointChar != null) {
                    GattCommunicationStatus result = await U2FControlPointChar.WriteValueAsync(writer.DetachBuffer(), GattWriteOption.WriteWithoutResponse);
                    if (result != GattCommunicationStatus.Success) {
                        OnFrameReceived(false, MSG_REQUEST_SEND_FAILED, Array.Empty<byte>());

                    } else {
                        // 応答タイムアウト監視開始
                        ResponseTimer.Start();
                    }

                } else {
                    AppLogUtil.OutputLogDebug(string.Format("BLEService.SendFrame: U2F control point characteristic is null"));
                    OnFrameReceived(false, MSG_REQUEST_SEND_FAILED, Array.Empty<byte>());
                }

            } catch (Exception e) {
                OnFrameReceived(false, string.Format(MSG_REQUEST_SEND_FAILED_WITH_EXCEPTION, e.Message), Array.Empty<byte>());
            }
        }

        //
        // 応答タイムアウト時の処理
        //
        private void OnResponseTimerElapsed(object sender, EventArgs e)
        {
            // 応答タイムアウトを通知
            OnFrameReceived(false, MSG_REQUEST_SEND_TIMED_OUT, Array.Empty<byte>());
        }

        //
        // 受信処理（コールバック）
        //
        private void OnCharacteristicValueChanged(GattCharacteristic sender, GattValueChangedEventArgs eventArgs)
        {
            // 応答タイムアウト監視終了
            ResponseTimer.Stop();

            try {
                // レスポンスを受領（U2F Statusを読込）
                uint len = eventArgs.CharacteristicValue.Length;
                byte[] frameBytes = new byte[len];
                DataReader.FromBuffer(eventArgs.CharacteristicValue).ReadBytes(frameBytes);

                // レスポンスを転送
                OnFrameReceived(true, string.Empty, frameBytes);

            } catch (Exception e) {
                OnFrameReceived(false, string.Format(MSG_RESPONSE_RECEIVE_FAILED_WITH_EXCEPTION, e.Message), Array.Empty<byte>());
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
                if (U2FStatusChar != null) {
                    U2FStatusChar.ValueChanged -= OnCharacteristicValueChanged;
                }
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
            U2FControlPointChar = null!;

            // コールバック解除
            ConnectionStatusChanged = null!;
        }

        public string ConnectedDeviceName()
        {
            if (BLEservice == null) {
                return string.Empty;
            } else {
                return BLEservice.Device.Name;
            }
        }
    }
}

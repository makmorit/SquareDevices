using AppCommon;
using System;
using System.Net;
using System.Security;
using Windows.Devices.Bluetooth;
using Windows.Devices.Enumeration;
using static DesktopTool.HelperMessage;

namespace DesktopTool
{
    internal class BLEPairingProcessParam
    {
        public ulong BluetoothAddress { get; set; }
        public bool CancelPairing { get; set; }
        public SecureString SecurePasscode { get; set; }

        // このクラスで設定
        public DevicePairingRequestedEventArgs DevicePairingRequester { get; set; }

        public BLEPairingProcessParam(ulong bluetoothAddress)
        {
            BluetoothAddress = bluetoothAddress;
            CancelPairing = false;
            SecurePasscode = new SecureString();
            DevicePairingRequester = null!;
        }
    }

    internal class BLEPairingProcess
    {
        // パラメーターを保持
        private BLEPairingProcessParam Parameter = null!;

        // 上位クラスに対するイベント通知
        public delegate void RequestPairingCodeHandler(BLEPairingProcessParam parameter);
        private event RequestPairingCodeHandler RequestPairingCode = null!;

        public delegate void NotifyCommandTerminateHandler(bool success, string errorMessage, BLEPairingProcessParam parameter);
        private event NotifyCommandTerminateHandler NotifyCommandTerminate = null!;

        //
        // 外部公開用
        //
        public void DoProcess(BLEPairingProcessParam param, RequestPairingCodeHandler requestPairingCode, NotifyCommandTerminateHandler notifyCommandTerminate)
        {
            // パラメーターの参照を保持
            Parameter = param;

            // 戻り先の関数を保持
            RequestPairingCode += requestPairingCode;
            NotifyCommandTerminate += notifyCommandTerminate;

            // ペアリング対象デバイスとペアリングを実行
            PairWithFIDOPeripheral(requestPairingCode != null);
        }

        //
        // ペアリング実行
        //
        private async void PairWithFIDOPeripheral(bool needPairingCode)
        {
            // 変数を初期化
            bool success = false;
            string errorMessage = string.Empty;

            try {
                // デバイス情報を取得
                BluetoothLEDevice? device = await BluetoothLEDevice.FromBluetoothAddressAsync(Parameter.BluetoothAddress);
                DeviceInformation deviceInfoForPair = device.DeviceInformation;

                // ペアリング実行
                deviceInfoForPair.Pairing.Custom.PairingRequested += CustomOnPairingRequested;
                DevicePairingResult result;
                if (needPairingCode) {
                    // パスキーが指定されている場合は、パスキーを使用
                    result = await deviceInfoForPair.Pairing.Custom.PairAsync(
                        DevicePairingKinds.ProvidePin, DevicePairingProtectionLevel.EncryptionAndAuthentication);

                } else {
                    // パスキーが指定されていない場合
                    result = await deviceInfoForPair.Pairing.Custom.PairAsync(
                        DevicePairingKinds.ConfirmOnly, DevicePairingProtectionLevel.Encryption);
                }
                deviceInfoForPair.Pairing.Custom.PairingRequested -= CustomOnPairingRequested;

                // ペアリングが正常終了したら処理完了
                if (Parameter.CancelPairing) {
                    AppLogUtil.OutputLogError("Pairing canceled by user");

                } else if (result.Status == DevicePairingResultStatus.Paired) {
                    success = true;
                    AppLogUtil.OutputLogDebug("Pairing with BLE device success");

                } else if (result.Status == DevicePairingResultStatus.AlreadyPaired) {
                    errorMessage = string.Format(MSG_BLE_PARING_ERR_ALREADY_PAIRED, deviceInfoForPair.Name);
                    AppLogUtil.OutputLogError("Already paired with BLE device");

                } else if (result.Status == DevicePairingResultStatus.Failed) {
                    errorMessage = MSG_BLE_PARING_ERR_PROCESS;
                    AppLogUtil.OutputLogError("Pairing with BLE device fail");

                } else {
                    errorMessage = MSG_BLE_PARING_ERR_UNKNOWN;
                    AppLogUtil.OutputLogError(string.Format("Pairing with BLE device fail: reason={0}", result.Status));
                }

                // BLEデバイスを解放
                device.Dispose();
                device = null;

            } catch (Exception e) {
                errorMessage = MSG_BLE_PARING_ERR_UNKNOWN;
                AppLogUtil.OutputLogError(string.Format("Pairing with BLE device fail: {0}", e.Message));
            }

            // 上位クラスに制御を戻す
            NotifyCommandTerminate(success, errorMessage, Parameter);
        }

        //
        // パスコード入力要求
        //
        private void CustomOnPairingRequested(DeviceInformationCustomPairing sender, DevicePairingRequestedEventArgs args)
        {
            if (args.PairingKind == DevicePairingKinds.ProvidePin) {
                Parameter.DevicePairingRequester = args;
                RequestPairingCode(Parameter);

            } else {
                args.Accept();
            }
        }

        public static void EnterPairingCode(BLEPairingProcessParam parameter)
        {
            if (parameter.CancelPairing == false && parameter.SecurePasscode != null) {
                // パスコードを取得して設定
                string passcode = new NetworkCredential(string.Empty, parameter.SecurePasscode).Password;
                parameter.DevicePairingRequester.Accept(passcode);
            }
        }
    }
}

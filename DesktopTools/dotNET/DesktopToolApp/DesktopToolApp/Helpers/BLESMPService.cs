using Windows.Devices.Bluetooth.GenericAttributeProfile;
using static DesktopTool.BLEDefines;

namespace DesktopTool
{
    internal class BLESMPService : BLEService
    {
        // 応答タイムアウトを設定
        protected override int TimeoutMsecsOfResponseTimer()
        {
            return SMP_BLE_SERVICE_RESP_TIMEOUT_MSEC;
        }

        //
        // 送信処理
        // 
        public override void SendFrame(byte[] frameBytes)
        {
            // 書込みオプションを設定
            GattWriteOption writeOption = GattWriteOption.WriteWithoutResponse;
            GattCharacteristic characteristicForSend = BLEservice.GetCharacteristics(Parameter.CharacteristicForSend)[0];
            if ((characteristicForSend.CharacteristicProperties & GattCharacteristicProperties.WriteWithoutResponse) == 0) {
                writeOption = GattWriteOption.WriteWithResponse;
            }

            // 送信
            SendFrame(characteristicForSend, writeOption, frameBytes);
        }
    }
}

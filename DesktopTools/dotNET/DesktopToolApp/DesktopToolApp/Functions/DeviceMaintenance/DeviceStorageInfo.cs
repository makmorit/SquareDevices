using AppCommon;
using System.Threading.Tasks;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class DeviceStorageInfo : ToolDoProcess
    {
        public DeviceStorageInfo(string menuItemName) : base(menuItemName) { }

        protected override void InvokeProcessOnSubThread()
        {
            Task task = Task.Run(RetrieveDeviceStorageInfo);
        }

        private void RetrieveDeviceStorageInfo()
        {
            // BLEデバイスに接続し、デバイスのストレージ情報を取得
            new DeviceStorage().Inquiry(NotifyResponseQueryHandler);
        }

        private void NotifyResponseQueryHandler(DeviceStorage sender, bool success, string errorMessage)
        {
            if (success == false) {
                // 失敗時はログ出力
                TerminateCommand(false, errorMessage);
                return;
            }

            // 空き容量テキストを編集
            FlashROMInfo flashROMInfo = sender.FlashROMInfo;
            string rateText;
            if (flashROMInfo.Rate < 0.0f) {
                rateText = MSG_FSTAT_NON_REMAINING_RATE;
            } else {
                rateText = string.Format(MSG_FSTAT_REMAINING_RATE, flashROMInfo.Rate);
            }

            // 破損状況テキストを編集
            string corruptText = flashROMInfo.Corrupt ? MSG_FSTAT_CORRUPTING_AREA_EXIST : MSG_FSTAT_CORRUPTING_AREA_NOT_EXIST;

            // Flash ROM情報文字列をログ出力
            string logText = string.Format(MSG_DEVICE_STORAGE_INFO_LOG_FORMAT, flashROMInfo.DeviceName, rateText, corruptText);
            AppLogUtil.OutputLogInfo(logText);

            // Flash ROM情報文字列を画面表示
            string dispText = string.Format(MSG_DEVICE_STORAGE_INFO_FORMAT, flashROMInfo.DeviceName, rateText, corruptText);
            FunctionUtil.DisplayTextOnApp(dispText, ViewModel.AppendStatusText);

            // 画面に制御を戻す
            TerminateCommand(true, string.Empty);
        }

        //
        // 終了処理
        //
        private void TerminateCommand(bool success, string message)
        {
            // 終了メッセージを画面表示／ログ出力
            if (message.Length > 0) {
                if (success) {
                    LogAndShowInfoMessage(message);
                } else {
                    LogAndShowErrorMessage(message);
                }
            }

            // 画面に制御を戻す
            ResumeProcess(success);
        }
    }
}

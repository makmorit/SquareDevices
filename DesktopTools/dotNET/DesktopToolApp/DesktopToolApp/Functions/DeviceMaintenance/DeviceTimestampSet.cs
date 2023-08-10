using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    internal class DeviceTimestampSet : ToolDoProcess
    {
        public DeviceTimestampSet(string menuItemName) : base(menuItemName) { }

        protected override void ShowPromptForStartProcess(ToolDoProcessViewModel model)
        {
            // プロンプトを表示し、Yesの場合だけ処理を行う
            if (DialogUtil.DisplayPromptPopup(FunctionUtil.GetMainWindow(), MSG_DEVICE_TIMESTAMP_SET_PROMPT, MSG_DEVICE_TIMESTAMP_SET_COMMENT)) {
                StartProcessInner(model);
            }
        }
    }
}

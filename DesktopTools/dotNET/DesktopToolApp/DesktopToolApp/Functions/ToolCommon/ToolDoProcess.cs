using System;
using System.Threading.Tasks;
using System.Windows;

namespace DesktopTool
{
    internal class ToolDoProcess
    {
        // このクラスのインスタンス
        public static ToolDoProcess _Instance = null!;

        public ToolDoProcess() { 
            _Instance = this;
        }

        public void ShowDoProcessView(string menuItemName)
        {
            // メイン画面右側の領域にビューを表示
            FunctionViewModel.SetActiveViewModel(ToolDoProcessViewModel.Instance);

            // タイトルを設定
            ToolDoProcessViewModel.Title = menuItemName;
        }

        //
        // コールバック関数
        //
        public static void StartProcess(string menuItemName)
        {
            // 画面のボタンを使用不可に設定
            ToolDoProcessViewModel.EnableButtonClick(false);

            Task task = Task.Run(() => {
                // 主処理を実行
                _Instance.InvokeProcessOnSubThread(menuItemName);
            });
        }

        public static void CloseDoProcessView()
        {
            // メイン画面右側の領域からビューを消す
            FunctionManager.HideFunctionView();
        }

        //
        // 内部処理
        //
        protected virtual void InvokeProcessOnSubThread(string menuItemName) 
        {
            ResumeProcess();
        }

        protected void ResumeProcess()
        {
            // 画面のボタンを使用可能に設定
            Application.Current.Dispatcher.Invoke(new Action(() => {
                ToolDoProcessViewModel.EnableButtonClick(true);
            }));
        }

        protected static void AppendStatusText(string text)
        {
            Application.Current.Dispatcher.Invoke(new Action(() => {
                ToolDoProcessView.AppendStatusText(text);
            }));
        }
    }
}

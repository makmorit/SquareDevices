using AppCommon;
using DesktopTool;
using System.Reflection;
using System.Threading;
using System.Windows;
using static DesktopTool.AppMessages;

namespace DesktopToolApp
{
    /// <summary>
    /// Interaction logic for App.xaml
    /// </summary>
    public partial class App : Application
    {
        // Mutex作成
        private readonly Mutex MutexRef = new Mutex(false, "DesktopToolApp");

        protected override void OnStartup(StartupEventArgs e)
        {
            // Mutexの所有権を要求
            if (MutexRef.WaitOne(0, false) == false) {
                MessageBox.Show(MSG_ERROR_DOUBLE_START, MSG_TOOL_TITLE);
                MutexRef.Close();
                Shutdown();
            }

            // ログ記録開始
            AppInfoUtil.NewInstance(Assembly.GetExecutingAssembly());
            AppLogUtil.StartLogging();
        }

        protected override void OnExit(ExitEventArgs e)
        {
            // TODO: 業務終了時の処理
            AppLogUtil.StopLogging();

            // Mutexを解放
            if (MutexRef != null) {
                MutexRef.ReleaseMutex();
                MutexRef.Close();
            }
            base.OnExit(e);
        }
    }
}

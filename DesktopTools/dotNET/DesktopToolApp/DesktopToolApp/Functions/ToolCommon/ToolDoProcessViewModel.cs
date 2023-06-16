using CommunityToolkit.Mvvm.Input;
using System.Windows.Input;

namespace DesktopTool
{
    internal class ToolDoProcessViewModel : ViewModelBase
    {
        // このクラスのインスタンス
        private static ToolDoProcessViewModel _Instance = new ToolDoProcessViewModel();
        private readonly RelayCommand _ButtonDoProcessClickedCommand;
        private readonly RelayCommand _ButtonCloseClickedCommand;
        private static string _Title = string.Empty;

        public ToolDoProcessViewModel()
        {
            _ButtonDoProcessClickedCommand = new RelayCommand(OnButtonDoProcessClicked);
            _ButtonCloseClickedCommand = new RelayCommand(OnButtonCloseClicked);
            _Instance = this;
        }

        public ICommand ButtonDoProcessClicked
        {
            get { return _ButtonDoProcessClickedCommand; }
        }

        public ICommand ButtonCloseClicked
        {
            get { return _ButtonCloseClickedCommand; }
        }

        public static string Title
        {
            get { return _Title; }
            set { _Title = value; }
        }

        public static ToolDoProcessViewModel Instance
        {
            get { return _Instance; }
        }

        //
        // 内部処理
        //
        private void OnButtonDoProcessClicked()
        {
        }

        private void OnButtonCloseClicked()
        {
            // サブ画面を領域から消す
            FunctionManager.HideFunctionView();
        }
    }
}

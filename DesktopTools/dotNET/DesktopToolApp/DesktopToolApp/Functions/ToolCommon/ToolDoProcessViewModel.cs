using CommunityToolkit.Mvvm.Input;
using System.Windows.Input;

namespace DesktopTool
{
    internal class ToolDoProcessViewModel : ViewModelBase
    {
        private readonly RelayCommand ButtonDoProcessClickedRelayCommand;
        private readonly RelayCommand ButtonCloseClickedRelayCommand;
        private string title = null!;
        private string statusText = null!;
        private bool buttonDoProcessIsEnabled;
        private bool buttonCloseIsEnabled;

        public ToolDoProcessViewModel()
        {
            ButtonDoProcessClickedRelayCommand = new RelayCommand(OnButtonDoProcessClicked);
            ButtonCloseClickedRelayCommand = new RelayCommand(OnButtonCloseClicked);
            Title = string.Empty;
            StatusText = string.Empty;
            ButtonDoProcessIsEnabled = true;
            ButtonCloseIsEnabled = true;
            try { ToolDoProcess.InitFunctionView(this); } catch { }
        }

        public ICommand ButtonDoProcessClicked
        {
            get { return ButtonDoProcessClickedRelayCommand; }
        }

        public ICommand ButtonCloseClicked
        {
            get { return ButtonCloseClickedRelayCommand; }
        }

        public string Title
        {
            get { return title; }
            set { title = value; NotifyPropertyChanged(nameof(Title)); }
        }

        public bool ButtonDoProcessIsEnabled
        {
            get { return buttonDoProcessIsEnabled; }
            set { buttonDoProcessIsEnabled = value; NotifyPropertyChanged(nameof(ButtonDoProcessIsEnabled)); }
        }

        public bool ButtonCloseIsEnabled
        {
            get { return buttonCloseIsEnabled; }
            set { buttonCloseIsEnabled = value; NotifyPropertyChanged(nameof(ButtonCloseIsEnabled)); }
        }

        public string StatusText
        {
            get { return statusText; }
            set { statusText = value; NotifyPropertyChanged(nameof(StatusText)); }
        }

        //
        // 内部処理
        //
        private void OnButtonDoProcessClicked()
        {
            ToolDoProcess.StartProcess(this);
        }

        private void OnButtonCloseClicked()
        {
            ToolDoProcess.CloseFunctionView(this);
        }

        //
        // 画面操作処理
        //
        public void ShowTitle(string text)
        {
            Title = text;
        }
    }
}

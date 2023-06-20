using CommunityToolkit.Mvvm.Input;
using System.Windows.Input;

namespace DesktopTool
{
    internal class ToolShowInfoViewModel : ViewModelBase
    {
        private readonly RelayCommand ButtonCloseClickedRelayCommand;
        private string title;
        private string caption;
        private string statusText;
        private bool buttonCloseIsEnabled;

        public ToolShowInfoViewModel()
        {
            ButtonCloseClickedRelayCommand = new RelayCommand(OnButtonCloseClicked);
            title = string.Empty;
            caption = string.Empty;
            statusText = string.Empty;
            buttonCloseIsEnabled = true;
            try { ToolShowInfo.InitFunctionView(this); } catch { }
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

        public string Caption
        {
            get { return caption; }
            set { caption = value; NotifyPropertyChanged(nameof(Caption)); }
        }

        public string StatusText
        {
            get { return statusText; }
            set { statusText = value; NotifyPropertyChanged(nameof(StatusText)); }
        }

        public bool ButtonCloseIsEnabled
        {
            get { return buttonCloseIsEnabled; }
            set { buttonCloseIsEnabled = value; NotifyPropertyChanged(nameof(ButtonCloseIsEnabled)); }
        }

        //
        // 内部処理
        //
        private void OnButtonCloseClicked()
        {
            ToolShowInfo.CloseFunctionView(this);
        }
    }
}

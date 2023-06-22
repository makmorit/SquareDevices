using CommunityToolkit.Mvvm.Input;
using System.Windows.Input;

namespace DesktopTool
{
    internal class ToolVersionInfoViewModel : ViewModelBase
    {
        private readonly RelayCommand ButtonOKClickedRelayCommand;
        private string toolName = null!;
        private string version = null!;
        private string copyright = null!;

        public ToolVersionInfoViewModel()
        {
            ButtonOKClickedRelayCommand = new RelayCommand(OnButtonOKClicked);
            ToolName = string.Empty;
            Version = string.Empty;
            Copyright = string.Empty;
            try { ToolVersionInfo.InitFunctionView(this); } catch { }
        }

        public ICommand ButtonOKClicked
        {
            get { return ButtonOKClickedRelayCommand; }
        }

        public string ToolName
        {
            get { return toolName; }
            set { toolName = value; NotifyPropertyChanged(nameof(ToolName)); }
        }

        public string Version
        {
            get { return version; }
            set { version = value; NotifyPropertyChanged(nameof(Version)); }
        }

        public string Copyright
        {
            get { return copyright; }
            set { copyright = value; NotifyPropertyChanged(nameof(Copyright)); }
        }

        //
        // 内部処理
        //
        private void OnButtonOKClicked()
        {
            ToolVersionInfo.CloseFunctionView();
        }
    }
}

using CommunityToolkit.Mvvm.Input;
using System.Windows.Input;

namespace DesktopTool
{
    internal class ToolVersionInfoViewModel : ViewModelBase
    {
        private readonly RelayCommand _ButtonOKClickedCommand;
        private string toolName;
        private string version;
        private string copyright; 

        public ToolVersionInfoViewModel()
        {
            _ButtonOKClickedCommand = new RelayCommand(OnButtonOKClicked);
            toolName = string.Empty;
            version = string.Empty;
            copyright = string.Empty;
            try { ToolVersionInfo.InitFunctionView(this); } catch { }
        }

        public ICommand ButtonOKClicked
        {
            get { return _ButtonOKClickedCommand; }
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

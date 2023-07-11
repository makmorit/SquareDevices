using CommunityToolkit.Mvvm.Input;
using System.Windows.Input;

namespace DesktopTool
{
    internal class FWUpdateProcessViewModel : ViewModelBase
    {
        private readonly RelayCommand ButtonCloseClickedRelayCommand;

        public FWUpdateProcessViewModel()
        {
            ButtonCloseClickedRelayCommand = new RelayCommand(OnButtonCloseClicked);
            try { FWUpdateProcess.InitView(this); } catch { }
        }

        public ICommand ButtonCloseClicked
        {
            get { return ButtonCloseClickedRelayCommand; }
        }

        //
        // 内部処理
        //
        private void OnButtonCloseClicked()
        {
            FWUpdateProcess.OnCancel(this);
        }
    }
}

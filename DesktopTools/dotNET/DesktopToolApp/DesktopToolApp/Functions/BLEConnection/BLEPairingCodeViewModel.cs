using CommunityToolkit.Mvvm.Input;
using System.Windows.Input;

namespace DesktopTool
{
    internal class BLEPairingCodeViewModel : ViewModelBase
    {
        private readonly RelayCommand ButtonPairingClickedRelayCommand;
        private readonly RelayCommand ButtonCloseClickedRelayCommand;

        public BLEPairingCodeViewModel()
        {
            ButtonPairingClickedRelayCommand = new RelayCommand(OnButtonPairingClicked);
            ButtonCloseClickedRelayCommand = new RelayCommand(OnButtonCloseClicked);
        }

        public ICommand ButtonPairingClicked
        {
            get { return ButtonPairingClickedRelayCommand; }
        }

        public ICommand ButtonCloseClicked
        {
            get { return ButtonCloseClickedRelayCommand; }
        }

        //
        // 内部処理
        //
        private void OnButtonPairingClicked()
        {
            BLEPairingCode.OnPairing(this);
        }

        private void OnButtonCloseClicked()
        {
            BLEPairingCode.OnCancel(this);
        }
    }
}

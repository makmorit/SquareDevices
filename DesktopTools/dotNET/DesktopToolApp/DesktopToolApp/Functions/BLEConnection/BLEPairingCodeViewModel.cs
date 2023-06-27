using CommunityToolkit.Mvvm.Input;
using System.Security;
using System.Windows.Input;

namespace DesktopTool
{
    internal class BLEPairingCodeViewModel : ViewModelBase
    {
        private readonly RelayCommand ButtonPairingClickedRelayCommand;
        private readonly RelayCommand ButtonCloseClickedRelayCommand;
        private SecureString passcode = null!;

        public BLEPairingCodeViewModel()
        {
            ButtonPairingClickedRelayCommand = new RelayCommand(OnButtonPairingClicked);
            ButtonCloseClickedRelayCommand = new RelayCommand(OnButtonCloseClicked);
            PassCode = new SecureString();
        }

        public ICommand ButtonPairingClicked
        {
            get { return ButtonPairingClickedRelayCommand; }
        }

        public ICommand ButtonCloseClicked
        {
            get { return ButtonCloseClickedRelayCommand; }
        }

        public SecureString PassCode
        {
            get { return passcode; }
            set { passcode = value; NotifyPropertyChanged(nameof(PassCode)); }
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

using System.Windows;
using System.Windows.Controls;

namespace DesktopTool
{
    /// <summary>
    /// BLEPairingCodeWindow.xaml の相互作用ロジック
    /// </summary>
    public partial class BLEPairingCodeWindow : Window
    {
        public BLEPairingCodeWindow()
        {
            InitializeComponent();
        }

        private void passwordBoxPasscode_PasswordChanged(object sender, RoutedEventArgs e)
        {
            if (DataContext == null) {
                return;
            }
            BLEPairingCodeViewModel dataContext = (BLEPairingCodeViewModel)DataContext;
            PasswordBox passwordBox = (PasswordBox)sender;
            dataContext.PassCode = passwordBox.SecurePassword;
        }
    }
}

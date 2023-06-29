using System;
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

        protected override void OnActivated(EventArgs e)
        {
            passwordBoxPasscode.Focus();
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

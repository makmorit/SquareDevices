using CommunityToolkit.Mvvm.Input;
using System.Windows.Input;

namespace DesktopTool
{
    internal class BLEUnpairRequestViewModel : ViewModelBase
    {
        private readonly RelayCommand ButtonCloseClickedRelayCommand;
        private string title = null!;

        public BLEUnpairRequestViewModel()
        {
            ButtonCloseClickedRelayCommand = new RelayCommand(OnButtonCloseClicked);
            Title = string.Empty;
            try { BLEUnpairRequest.InitView(this); } catch { }
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

        //
        // 内部処理
        //
        private void OnButtonCloseClicked()
        {
            BLEUnpairRequest.OnCancel(this);
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

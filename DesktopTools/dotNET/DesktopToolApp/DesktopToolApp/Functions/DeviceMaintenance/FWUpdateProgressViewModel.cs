using CommunityToolkit.Mvvm.Input;
using System.Windows.Input;

namespace DesktopTool
{
    internal class FWUpdateProgressViewModel : ViewModelBase
    {
        private readonly RelayCommand ButtonCloseClickedRelayCommand;
        private string title = null!;
        private string remaining = null!;
        private int level = 0;
        private int maxLevel = 0;

        public FWUpdateProgressViewModel()
        {
            ButtonCloseClickedRelayCommand = new RelayCommand(OnButtonCloseClicked);
            Title = string.Empty;
            Remaining = string.Empty;
            Level = 0;
            MaxLevel = 100;
            try { FWUpdateProgress.InitView(this); } catch { }
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

        public string Remaining
        {
            get { return remaining; }
            set { remaining = value; NotifyPropertyChanged(nameof(Remaining)); }
        }

        public int Level
        {
            get { return level; }
            set { level = value; NotifyPropertyChanged(nameof(Level)); }
        }

        public int MaxLevel
        {
            get { return maxLevel; }
            set { maxLevel = value; NotifyPropertyChanged(nameof(MaxLevel)); }
        }

        //
        // 内部処理
        //
        private void OnButtonCloseClicked()
        {
            FWUpdateProgress.OnCancel();
        }

        //
        // 画面操作処理
        //
        public void ShowTitle(string text)
        {
            Title = text;
        }

        public void ShowRemaining(string text)
        {
            Remaining = text;
        }

        public void SetLevel(int value)
        {
            Level = value;
        }

        public void SetMaxLevel(int value)
        {
            MaxLevel = value;
        }
    }
}

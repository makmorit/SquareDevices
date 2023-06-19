﻿using CommunityToolkit.Mvvm.Input;
using System.Windows.Input;

namespace DesktopTool
{
    internal class ToolDoProcessViewModel : ViewModelBase
    {
        // このクラスのインスタンス
        private static ToolDoProcessViewModel _Instance = new ToolDoProcessViewModel();
        private readonly RelayCommand _ButtonDoProcessClickedCommand;
        private readonly RelayCommand _ButtonCloseClickedCommand;
        private static string _Title = string.Empty;
        private bool buttonDoProcessIsEnabled;
        private bool buttonCloseIsEnabled;
        private string _StatusText = string.Empty;

        public ToolDoProcessViewModel()
        {
            _ButtonDoProcessClickedCommand = new RelayCommand(OnButtonDoProcessClicked);
            _ButtonCloseClickedCommand = new RelayCommand(OnButtonCloseClicked);
            buttonDoProcessIsEnabled = true;
            buttonCloseIsEnabled = true;
            _Instance = this;
        }

        public ICommand ButtonDoProcessClicked
        {
            get { return _ButtonDoProcessClickedCommand; }
        }

        public ICommand ButtonCloseClicked
        {
            get { return _ButtonCloseClickedCommand; }
        }

        public static string Title
        {
            get { return _Title; }
            set { _Title = value; }
        }

        public bool ButtonDoProcessIsEnabled
        {
            get { return buttonDoProcessIsEnabled; }
            set {
                buttonDoProcessIsEnabled = value;
                NotifyPropertyChanged(nameof(ButtonDoProcessIsEnabled));
            }
        }

        public bool ButtonCloseIsEnabled
        {
            get { return buttonCloseIsEnabled; }
            set {
                buttonCloseIsEnabled = value;
                NotifyPropertyChanged(nameof(ButtonCloseIsEnabled));
            }
        }

        public string StatusText
        {
            get { return _StatusText; }
            set {
                _StatusText = value; 
                NotifyPropertyChanged(nameof(StatusText));
            }
        }

        public static ToolDoProcessViewModel Instance
        {
            get { return _Instance; }
        }

        //
        // 内部処理
        //
        private void OnButtonDoProcessClicked()
        {
            ToolDoProcess.StartProcess(Title);
        }

        private void OnButtonCloseClicked()
        {
            StatusText = string.Empty;
            ToolDoProcess.CloseDoProcessView();
        }

        //
        // 外部公開用
        //
        public static void EnableButtonClick(bool b)
        {
            Instance.ButtonDoProcessIsEnabled = b;
            Instance.ButtonCloseIsEnabled = b;
        }
    }
}

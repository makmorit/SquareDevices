﻿using CommunityToolkit.Mvvm.Input;
using System.Windows.Input;

namespace DesktopTool
{
    internal class ToolDoProcessViewModel : ViewModelBase
    {
        // このクラスのインスタンス
        private static ToolDoProcessViewModel _Instance = new ToolDoProcessViewModel();
        private readonly RelayCommand ButtonDoProcessClickedRelayCommand;
        private readonly RelayCommand ButtonCloseClickedRelayCommand;
        private string title;
        private bool buttonDoProcessIsEnabled;
        private bool buttonCloseIsEnabled;
        private string statusText;

        public ToolDoProcessViewModel()
        {
            ButtonDoProcessClickedRelayCommand = new RelayCommand(OnButtonDoProcessClicked);
            ButtonCloseClickedRelayCommand = new RelayCommand(OnButtonCloseClicked);
            title = string.Empty;
            statusText = string.Empty;
            buttonDoProcessIsEnabled = true;
            buttonCloseIsEnabled = true;
            _Instance = this;
            try { ToolDoProcess.InitFunctionView(this); } catch { }
        }

        public ICommand ButtonDoProcessClicked
        {
            get { return ButtonDoProcessClickedRelayCommand; }
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

        public bool ButtonDoProcessIsEnabled
        {
            get { return buttonDoProcessIsEnabled; }
            set { buttonDoProcessIsEnabled = value; NotifyPropertyChanged(nameof(ButtonDoProcessIsEnabled)); }
        }

        public bool ButtonCloseIsEnabled
        {
            get { return buttonCloseIsEnabled; }
            set { buttonCloseIsEnabled = value; NotifyPropertyChanged(nameof(ButtonCloseIsEnabled)); }
        }

        public string StatusText
        {
            get { return statusText; }
            set { statusText = value; NotifyPropertyChanged(nameof(StatusText)); }
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
            ToolDoProcess.CloseFunctionView();
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
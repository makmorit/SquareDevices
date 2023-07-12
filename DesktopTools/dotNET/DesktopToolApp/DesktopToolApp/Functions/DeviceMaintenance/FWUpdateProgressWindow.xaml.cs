using DesktopTool.CommonWindow;
using System;
using System.Windows;

namespace DesktopTool
{
    /// <summary>
    /// FWUpdateProcessWindow.xaml の相互作用ロジック
    /// </summary>
    public partial class FWUpdateProgressWindow : Window
    {
        public FWUpdateProgressWindow()
        {
            InitializeComponent();
        }

        //
        // 閉じるボタンの無効化
        //
        protected override void OnSourceInitialized(EventArgs e)
        {
            base.OnSourceInitialized(e);
            CommonWindowUtil.DisableCloseWindowButton(this);
        }
    }
}

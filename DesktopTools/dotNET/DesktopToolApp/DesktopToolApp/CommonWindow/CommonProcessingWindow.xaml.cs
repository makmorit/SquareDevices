using System;
using System.Windows;

namespace DesktopTool.CommonWindow
{
    /// <summary>
    /// CommonProcessingWindow.xaml の相互作用ロジック
    /// </summary>
    public partial class CommonProcessingWindow : Window
    {
        public CommonProcessingWindow()
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

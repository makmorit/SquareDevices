using DesktopTool.CommonWindow;
using System;
using System.Windows;

namespace DesktopTool
{
    /// <summary>
    /// BLEUnpairRequestWindow.xaml の相互作用ロジック
    /// </summary>
    public partial class BLEUnpairRequestWindow : Window
    {
        public BLEUnpairRequestWindow()
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

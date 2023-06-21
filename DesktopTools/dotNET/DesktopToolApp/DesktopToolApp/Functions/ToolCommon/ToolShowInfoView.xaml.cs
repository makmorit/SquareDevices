using System.Windows.Controls;

namespace DesktopTool
{
    /// <summary>
    /// ToolShowInfo.xaml の相互作用ロジック
    /// </summary>
    public partial class ToolShowInfoView : UserControl
    {
        // このクラスのインスタンス
        private static ToolShowInfoView _Instance = null!;

        public ToolShowInfoView()
        {
            InitializeComponent();
            _Instance = this;
        }

        //
        // 外部公開用
        //
        public static void AppendStatusText(string messageText)
        {
            // 引数の文字列を、テキストボックス上に表示し改行
            _Instance.statusText.Text += messageText + "\r\n";

            // テキストボックスの現在位置を末尾に移動
            _Instance.statusText.ScrollToEnd();
        }
    }
}

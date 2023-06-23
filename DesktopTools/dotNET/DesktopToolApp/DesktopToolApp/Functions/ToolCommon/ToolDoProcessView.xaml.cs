using System.Windows.Controls;

namespace DesktopTool
{
    /// <summary>
    /// ToolDoProcessView.xaml の相互作用ロジック
    /// </summary>
    public partial class ToolDoProcessView : UserControl
    {
        // このクラスのインスタンス
        private static ToolDoProcessView _Instance = null!;

        public ToolDoProcessView()
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

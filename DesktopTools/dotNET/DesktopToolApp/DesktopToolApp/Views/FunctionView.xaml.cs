using System.Windows.Controls;

namespace DesktopTool
{
    /// <summary>
    /// FunctionView.xaml の相互作用ロジック
    /// </summary>
    public partial class FunctionView : UserControl
    {
        // このクラスのインスタンス
        private static FunctionView _Instance = null!;

        public FunctionView()
        {
            InitializeComponent();
            _Instance = this;
        }

        //
        // 外部公開用
        //
        public static void SetViewContent(UserControl userControl)
        {
            _Instance.ViewContent.Content = userControl;
        }
    }
}

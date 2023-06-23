namespace DesktopTool
{
    internal class FunctionViewModel : ViewModelBase
    {
        // このクラスのインスタンス
        private static FunctionViewModel Instance = null!;
        private bool contentControlVisibled;

        public FunctionViewModel()
        {
            contentControlVisibled = false;
            Instance = this;
        }

        public bool ContentControlVisibled
        {
            get { return contentControlVisibled; }
            set { 
                if (contentControlVisibled != value) {  
                    contentControlVisibled = value;
                    NotifyPropertyChanged(nameof(ContentControlVisibled));
                }
            }
        }

        //
        // 外部公開用
        //
        public static void ShowContentControl(bool b)
        {
            // コンテンツビューを表示／非表示化
            Instance.ContentControlVisibled = b;
        }
    }
}

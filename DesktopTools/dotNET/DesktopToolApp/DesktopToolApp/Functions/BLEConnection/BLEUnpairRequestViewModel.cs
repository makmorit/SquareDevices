namespace DesktopTool
{
    internal class BLEUnpairRequestViewModel : ViewModelBase
    {
        private string title = null!;

        public BLEUnpairRequestViewModel()
        {
            Title = string.Empty;
            try { BLEUnpairRequest.InitFunctionView(this); } catch { }
        }

        public string Title
        {
            get { return title; }
            set { title = value; NotifyPropertyChanged(nameof(Title)); }
        }

        //
        // 画面操作処理
        //
        public void ShowTitle(string text)
        {
            Title = text;
        }
    }
}

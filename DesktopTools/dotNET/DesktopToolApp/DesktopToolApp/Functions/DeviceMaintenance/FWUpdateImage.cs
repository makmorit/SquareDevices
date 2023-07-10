namespace DesktopTool
{
    internal class FWUpdateImage
    {
        // バージョン情報を保持
        public FWVersionData VersionData = null!;

        public FWUpdateImage(FWVersionData version)
        {
            VersionData = version;
        }

        //
        // ファームウェア更新イメージ取得処理
        //
        public delegate void UpdateImageRetrievedHandler(FWUpdateImage sender, bool success, string errorCaption, string errorMessage);
        private event UpdateImageRetrievedHandler OnUpdateImageRetrieved = null!;

        public void RetrieveImage(UpdateImageRetrievedHandler updateImageRetrievedHandler)
        {
            // コールバックを設定
            OnUpdateImageRetrieved += updateImageRetrievedHandler;

            // TODO: 仮の実装です。
            OnUpdateImageRetrieved?.Invoke(this, true, string.Empty, string.Empty);
            OnUpdateImageRetrieved = null!;
        }
    }
}

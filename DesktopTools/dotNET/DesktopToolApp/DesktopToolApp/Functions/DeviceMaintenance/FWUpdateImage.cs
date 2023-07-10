using AppCommon;
using System;
using System.IO;
using System.Reflection;
using static DesktopTool.FunctionMessage;

namespace DesktopTool
{
    public class FWUpdateImageData
    {
        //
        // nRF5340アプリケーションファームウェアのバイナリーイメージを保持。
        // .bin=512Kバイトと見積っています。
        //
        public byte[] NRF53AppBin = Array.Empty<byte>();
        public int NRF53AppBinSize { get; set; }

        // 更新イメージファイルのハッシュ値
        public byte[] SHA256Hash = new byte[32];

        // 更新イメージファイルのリソース名称
        public string UpdateImageResourceName;

        // 更新イメージファイルのバージョン文字列
        public string UpdateVersion;

        // リソース名称検索用キーワード
        public const string ResourceNamePrefix = "app_update.";
        public const string ResourceNameSuffix = ".bin";

        public FWUpdateImageData()
        {
            UpdateImageResourceName = string.Empty;
            UpdateVersion = string.Empty;
        }

        public static string ResourceName()
        {
            return string.Format("{0}.Resources.", AppInfoUtil.GetAppBundleNameString());
        }
    }

    internal class FWUpdateImage
    {
        // バージョン情報を保持
        public FWVersionData VersionData;

        // イメージデータを保持
        public FWUpdateImageData UpdateImageData;

        public FWUpdateImage(FWVersionData version)
        {
            VersionData = version;
            UpdateImageData = new FWUpdateImageData();
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

            // 基板名に対応するファームウェア更新イメージファイルから、バイナリーイメージを読込
            if (ReadFWUpdateImageFile(VersionData.HWRev) == false) {
                Terminate(false, MSG_FW_UPDATE_FUNC_NOT_AVAILABLE, MSG_FW_UPDATE_IMAGE_FILE_NOT_EXIST);
                return;
            }

            // ファームウェア更新イメージファイルから、更新バージョンを取得
            string UpdateVersion = GetUpdateVersionFromUpdateImage(VersionData.HWRev, UpdateImageData);

            // 更新イメージファイル名からバージョンが取得できていない場合は利用不可
            if (UpdateVersion.Equals("")) {
                Terminate(false, MSG_FW_UPDATE_FUNC_NOT_AVAILABLE, MSG_FW_UPDATE_VERSION_UNKNOWN);
                return;
            }

            // BLE経由で現在バージョンが取得できていない場合は利用不可
            string CurrentVersion = VersionData.FWRev;
            if (CurrentVersion.Equals("")) {
                Terminate(false, MSG_FW_UPDATE_FUNC_NOT_AVAILABLE, MSG_FW_UPDATE_CURRENT_VERSION_UNKNOWN);
                return;
            }

            // 現在バージョンが、更新イメージファイルのバージョンより新しい場合は利用不可
            int currentVersionDec = AppUtil.CalculateDecimalVersion(CurrentVersion);
            int updateVersionDec = AppUtil.CalculateDecimalVersion(UpdateVersion);
            if (currentVersionDec > updateVersionDec) {
                string informative = string.Format(MSG_FW_UPDATE_CURRENT_VERSION_ALREADY_NEW, CurrentVersion, UpdateVersion);
                Terminate(false, MSG_FW_UPDATE_FUNC_NOT_AVAILABLE, informative);
                return;
            }

            // 更新イメージのバージョン文字列を設定
            UpdateImageData.UpdateVersion = UpdateVersion;
            Terminate(true, string.Empty, string.Empty);
        }

        private void Terminate(bool success, string errorCaption, string errorMessage)
        {
            // 上位クラスに制御を戻す
            OnUpdateImageRetrieved?.Invoke(this, success, errorCaption, errorMessage);
            OnUpdateImageRetrieved = null!;
        }

        //
        // 内部処理
        //
        private bool ReadFWUpdateImageFile(string boardname)
        {
            // ファームウェア更新イメージファイル名を取得
            if (GetUpdateImageFileResourceName(boardname, UpdateImageData) == false) {
                return false;
            }

            // ファームウェア更新イメージ(.bin)を配列に読込
            if (ReadUpdateImage(UpdateImageData) == false) {
                return false;
            }

            // イメージからSHA-256ハッシュを抽出
            return ExtractImageHashSha256(UpdateImageData);
        }

        private bool ReadUpdateImage(FWUpdateImageData imageData)
        {
            // ファイルサイズをゼロクリア
            imageData.NRF53AppBinSize = 0;

            // リソースファイルを開く
            Assembly assembly = Assembly.GetExecutingAssembly();
            Stream? stream = assembly.GetManifestResourceStream(imageData.UpdateImageResourceName);
            if (stream == null) {
                return false;
            }

            try {
                // リソースファイルを配列に読込
                imageData.NRF53AppBin = new byte[stream.Length];
                imageData.NRF53AppBinSize = stream.Read(imageData.NRF53AppBin, 0, (int)stream.Length);

                // リソースファイルを閉じる
                stream.Close();

                // 読込長とバッファ長が異なる場合
                if (imageData.NRF53AppBinSize != imageData.NRF53AppBin.Length) {
                    AppLogUtil.OutputLogError(string.Format("FWUpdateImage.ReadUpdateImage: Read size {0} bytes, but image buffer size {1} bytes",
                        imageData.NRF53AppBinSize, imageData.NRF53AppBin.Length));
                    return false;
                }
                return true;

            } catch (Exception e) {
                AppLogUtil.OutputLogError(string.Format("FWUpdateImage.ReadUpdateImage: {0}", e.Message));
                return false;
            }
        }

        private bool GetUpdateImageFileResourceName(string boardname, FWUpdateImageData imageData)
        {
            // リソース名称を初期化
            imageData.UpdateImageResourceName = "";

            // このアプリケーションに同梱されているリソース名を取得
            Assembly myAssembly = Assembly.GetExecutingAssembly();
            string[] resnames = myAssembly.GetManifestResourceNames();
            foreach (string resName in resnames) {
                // nRF53用のイメージかどうか判定
                if (StartsWithResourceNameForNRF53(boardname, resName)) {
                    imageData.UpdateImageResourceName = resName;
                    return true;
                }
            }

            return false;
        }

        private static bool StartsWithResourceNameForNRF53(string boardname, string resName)
        {
            // リソース名が
            // "<bundleName>.Resources.app_update.<boardname>."
            // という名称で始まっている場合は、
            // ファームウェア更新イメージファイルと判定
            string prefix = string.Format("{0}{1}{2}.", FWUpdateImageData.ResourceName(), FWUpdateImageData.ResourceNamePrefix, boardname);
            return resName.StartsWith(prefix);
        }

        private bool ExtractImageHashSha256(FWUpdateImageData imageData)
        {
            // magicの値を抽出
            ulong magic = (ulong)AppUtil.ToInt32(imageData.NRF53AppBin, 0, false);

            // イメージヘッダー／データ長を抽出
            int image_header_size = AppUtil.ToInt32(imageData.NRF53AppBin, 8, false);
            int image_data_size = AppUtil.ToInt32(imageData.NRF53AppBin, 12, false);
            int image_size = image_header_size + image_data_size;

            // イメージヘッダーから、イメージTLVの開始位置を計算
            int tlv_info;
            if (magic == 0x96f3b83c) {
                tlv_info = image_size;
            } else {
                tlv_info = image_size + 4;
            }

            // イメージTLVからSHA-256ハッシュの開始位置を検出
            while (tlv_info < imageData.NRF53AppBinSize) {
                // タグ／長さを抽出
                int tag = AppUtil.ToInt16(imageData.NRF53AppBin, tlv_info, false);
                tlv_info += 2;
                int len = AppUtil.ToInt16(imageData.NRF53AppBin, tlv_info, false);
                tlv_info += 2;

                // SHA-256のタグであり、長さが32バイトであればデータをバッファにコピー
                if (tag == 0x10 && len == 0x20) {
                    Array.Copy(imageData.NRF53AppBin, tlv_info, imageData.SHA256Hash, 0, len);
                    return true;
                } else {
                    tlv_info += len;
                }
            }
            // SHA-256ハッシュが見つからなかった場合はエラー
            AppLogUtil.OutputLogError("FWUpdateImage.ExtractImageHashSha256: SHA-256 hash of image not found");
            return false;
        }

        private string GetUpdateVersionFromUpdateImage(string boardname, FWUpdateImageData imageData)
        {
            // ファームウェア更新イメージ名称から、更新バージョンを取得
            return ExtractUpdateVersion(imageData);
        }

        private string ExtractUpdateVersion(FWUpdateImageData imageData)
        {
            // バージョン文字列を初期化
            string resName = imageData.UpdateImageResourceName;
            string UpdateVersion = "";
            if (resName.Equals("")) {
                return UpdateVersion;
            }
            if (resName.EndsWith(FWUpdateImageData.ResourceNameSuffix) == false) {
                return UpdateVersion;
            }

            // リソース名称文字列から、バージョン文字列だけを抽出
            string replaced = resName.Replace(FWUpdateImageData.ResourceName(), "").Replace(FWUpdateImageData.ResourceNamePrefix, "").Replace(FWUpdateImageData.ResourceNameSuffix, "");
            string[] elem = replaced.Split('.');
            if (elem.Length != 4) {
                return UpdateVersion;
            }

            // 抽出後の文字列を、基板名とバージョン文字列に分ける
            // 例：PCA10095.0.0.1 --> PCA10095, 0.0.1
            string boardname = elem[0];
            UpdateVersion = string.Format("{0}.{1}.{2}", elem[1], elem[2], elem[3]);

            // ログ出力
            string fname = resName.Replace(FWUpdateImageData.ResourceName(), "");
            AppLogUtil.OutputLogDebug(string.Format("Firmware update image for nRF53: Firmware version {0}, board name {1}", UpdateVersion, boardname));
            AppLogUtil.OutputLogDebug(string.Format("Firmware update image for nRF53: {0}({1} bytes)", fname, imageData.NRF53AppBinSize));

            return UpdateVersion;
        }
    }
}

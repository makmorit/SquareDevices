﻿using AppCommon;
using PeterO.Cbor;
using System;

namespace DesktopTool
{
    internal class FWUpdateResultInfo
    {
        public byte Rc { get; set; }
        public UInt32 Off { get; set; }
    }

    internal class FWUpdateSlotInfo
    {
        public byte SlotNo { get; set; }
        public byte[] Hash { get; set; }
        public bool Active { get; set; }

        public FWUpdateSlotInfo()
        {
            Hash = new byte[0];
        }
    }

    internal class FWUpdateCBORDecoder
    {
        public FWUpdateResultInfo ResultInfo { get; set; }
        public FWUpdateSlotInfo[] SlotInfos { get; set; }

        public FWUpdateCBORDecoder()
        {
            // スロット照会情報を初期化
            SlotInfos = new FWUpdateSlotInfo[2];
            for (int i = 0; i < SlotInfos.Length; i++) {
                SlotInfos[i] = new FWUpdateSlotInfo();
            }

            // 転送結果情報を初期化
            ResultInfo = new FWUpdateResultInfo();
        }

        public bool DecodeSlotInfo(byte[] cborBytes)
        {
            // ルートのMapを抽出
            CBORObject slotInfoMap = CBORObject.DecodeFromBytes(cborBytes, CBOREncodeOptions.Default);

            // Map内を探索
            foreach (CBORObject slotInfoKey in slotInfoMap.Keys) {
                string keyStr = slotInfoKey.AsString();
                if (keyStr.Equals("images")) {
                    // "images"エントリーを抽出（配列）
                    if (ParseImageArray(slotInfoMap, slotInfoKey) == false) {
                        return false;
                    }
                }

                if (keyStr.Equals("rc")) {
                    // "images"がない場合は、代わりに"rc"を抽出
                    byte rc = 0;
                    if (ParseByteValue(slotInfoMap, slotInfoKey, ref rc) == false) {
                        return false;
                    }
                    ResultInfo.Rc = rc;
                }
            }
            return true;
        }

        public bool DecodeUploadResultInfo(byte[] cborBytes)
        {
            // ルートのMapを抽出
            CBORObject uploadResultInfoMap = CBORObject.DecodeFromBytes(cborBytes, CBOREncodeOptions.Default);

            // Map内を探索
            foreach (CBORObject uploadResultInfoKey in uploadResultInfoMap.Keys) {
                string keyStr = uploadResultInfoKey.AsString();
                if (keyStr.Equals("rc")) {
                    // "rc"エントリーを抽出（数値）
                    byte rc = 0;
                    if (ParseByteValue(uploadResultInfoMap, uploadResultInfoKey, ref rc) == false) {
                        return false;
                    }
                    ResultInfo.Rc = rc;
                }
                if (keyStr.Equals("off")) {
                    // "off"エントリーを抽出（数値）
                    UInt32 off = 0;
                    if (ParseUInt32Value(uploadResultInfoMap, uploadResultInfoKey, ref off) == false) {
                        return false;
                    }
                    ResultInfo.Off = off;
                }
            }
            return true;
        }

        private bool ParseImageArray(CBORObject map, CBORObject key)
        {
            // Mapから指定キーのエントリーを抽出
            CBORObject imageArray = map[key];
            if (imageArray == null) {
                AppLogUtil.OutputLogError(string.Format("ParseImageArray: {0} is null", key.AsString()));
                return false;
            }

            // 型をチェック
            if (imageArray.Type != CBORType.Array) {
                AppLogUtil.OutputLogError(string.Format("ParseImageArray: {0} is not CBORType.Array", key.AsString()));
                return false;
            }

            // 配列内を探索
            int idx = 0;
            foreach (CBORObject imageMap in imageArray.Values) {
                // 型をチェック
                if (imageMap.Type != CBORType.Map) {
                    AppLogUtil.OutputLogError(string.Format("ParseImageArray: idx[{0}] is not CBORType.Map", idx));
                    return false;
                }

                // 抽出する値を格納
                byte slotNo = 0;
                byte[] hash = new byte[0];
                bool active = false;

                // Map内を探索
                foreach (CBORObject imageKey in imageMap.Keys) {
                    string imageKeyStr = imageKey.AsString();
                    if (imageKeyStr.Equals("slot")) {
                        // "slot"エントリーを抽出（数値）
                        if (ParseByteValue(imageMap, imageKey, ref slotNo) == false) {
                            return false;
                        }
                        SlotInfos[slotNo].SlotNo = slotNo;
                    }

                    if (imageKeyStr.Equals("hash")) {
                        // "hash"エントリーを抽出（バイト配列）
                        if (ParseFixedBytesValue(imageMap, imageKey, ref hash) == false) {
                            return false;
                        }
                        SlotInfos[slotNo].Hash = hash;
                    }

                    if (imageKeyStr.Equals("active")) {
                        // "active"エントリーを抽出（bool）
                        if (ParseBooleanValue(imageMap, imageKey, ref active) == false) {
                            return false;
                        }
                        SlotInfos[slotNo].Active = active;
                    }
                }
                idx++;
            }

            return true;
        }

        private bool ParseByteValue(CBORObject map, CBORObject key, ref byte b)
        {
            // Mapから指定キーのエントリーを抽出
            CBORObject value = map[key];
            if (value == null) {
                AppLogUtil.OutputLogError(string.Format("ParseByteValue: {0} is null", key.AsString()));
                return false;
            }

            // 型をチェック
            if (value.Type != CBORType.Integer) {
                AppLogUtil.OutputLogError(string.Format("ParseByteValue: {0} is not CBORType.Number", key.AsString()));
                return false;
            }

            // 値を抽出
            b = value.ToObject<byte>();
            return true;
        }

        private bool ParseFixedBytesValue(CBORObject map, CBORObject key, ref byte[] b)
        {
            // Mapから指定キーのエントリーを抽出
            CBORObject value = map[key];
            if (value == null) {
                AppLogUtil.OutputLogError(string.Format("ParseFixedBytesValue: {0} is null", key.AsString()));
                return false;
            }

            // 型をチェック
            if (value.Type != CBORType.ByteString) {
                AppLogUtil.OutputLogError(string.Format("ParseFixedBytesValue: {0} is not CBORType.ByteString", key.AsString()));
                return false;
            }

            // 値を抽出
            b = value.GetByteString();
            return true;
        }

        private bool ParseBooleanValue(CBORObject map, CBORObject key, ref bool b)
        {
            // Mapから指定キーのエントリーを抽出
            CBORObject value = map[key];
            if (value == null) {
                AppLogUtil.OutputLogError(string.Format("ParseBooleanValue: {0} is null", key.AsString()));
                return false;
            }

            // 型をチェック
            if (value.Type != CBORType.Boolean) {
                AppLogUtil.OutputLogError(string.Format("ParseBooleanValue: {0} is not CBORType.Boolean", key.AsString()));
                return false;
            }

            // 値を抽出
            b = value.AsBoolean();
            return true;
        }

        private bool ParseUInt32Value(CBORObject map, CBORObject key, ref UInt32 ui)
        {
            // Mapから指定キーのエントリーを抽出
            CBORObject value = map[key];
            if (value == null) {
                AppLogUtil.OutputLogError(string.Format("ParseUInt32Value: {0} is null", key.AsString()));
                return false;
            }

            // 型をチェック
            if (value.Type != CBORType.Integer) {
                AppLogUtil.OutputLogError(string.Format("ParseUInt32Value: {0} is not CBORType.Number", key.AsString()));
                return false;
            }

            // 値を抽出
            ui = value.AsNumber().ToUInt32Checked();
            return true;
        }
    }
}

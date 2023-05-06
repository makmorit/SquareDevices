using System;
using System.Linq;
using System.Text.RegularExpressions;

namespace AppCommon
{
    public class AppUtil
    {
        // 
        // ユーティリティー
        //
        public static int CalculateDecimalVersion(string versionStr)
        {
            // バージョン文字列 "1.2.11" -> "010211" 形式に変換
            int decimalVersion = 0;
            foreach (string element in versionStr.Split('.')) {
                decimalVersion = decimalVersion * 100 + int.Parse(element);
            }
            return decimalVersion;
        }

        public static bool CompareBytes(byte[] src, byte[] dest, int size)
        {
            for (int i = 0; i < size; i++) {
                if (src[i] != dest[i]) {
                    return false;
                }
            }
            return true;
        }

        public static int ToInt32(byte[] value, int startIndex, bool changeEndian = false)
        {
            byte[] sub = GetSubArray(value, startIndex, 4);
            if (changeEndian == true) {
                sub = sub.Reverse().ToArray();
            }
            return BitConverter.ToInt32(sub, 0);
        }

        public static int ToInt16(byte[] value, int startIndex, bool changeEndian = false)
        {
            byte[] sub = GetSubArray(value, startIndex, 2);
            if (changeEndian == true) {
                sub = sub.Reverse().ToArray();
            }
            return BitConverter.ToInt16(sub, 0);
        }

        public static UInt32 ToUInt32(byte[] value, int startIndex, bool changeEndian = false)
        {
            byte[] sub = GetSubArray(value, startIndex, 4);
            if (changeEndian == true) {
                sub = sub.Reverse().ToArray();
            }
            return BitConverter.ToUInt32(sub, 0);
        }

        public static UInt16 ToUInt16(byte[] value, int startIndex, bool changeEndian = false)
        {
            byte[] sub = GetSubArray(value, startIndex, 2);
            if (changeEndian == true) {
                sub = sub.Reverse().ToArray();
            }
            return BitConverter.ToUInt16(sub, 0);
        }

        private static byte[] GetSubArray(byte[] src, int startIndex, int count)
        {
            byte[] dst = new byte[count];
            Array.Copy(src, startIndex, dst, 0, count);
            return dst;
        }

        public static void ConvertUint32ToLEBytes(UInt32 ui, byte[] b, int offset)
        {
            byte[] s = BitConverter.GetBytes(ui);
            for (int i = 0; i < s.Length; i++) {
                b[i + offset] = s[i];
            }
        }

        public static void ConvertUint16ToLEBytes(UInt16 ui, byte[] b, int offset)
        {
            byte[] s = BitConverter.GetBytes(ui);
            for (int i = 0; i < s.Length; i++) {
                b[i + offset] = s[i];
            }
        }

        public static void ConvertUint32ToBEBytes(UInt32 ui, byte[] b, int offset)
        {
            byte[] s = BitConverter.GetBytes(ui);
            for (int i = 0; i < s.Length; i++) {
                b[i + offset] = s[s.Length - 1 - i];
            }
        }

        public static void ConvertUint16ToBEBytes(UInt16 ui, byte[] b, int offset)
        {
            byte[] s = BitConverter.GetBytes(ui);
            for (int i = 0; i < s.Length; i++) {
                b[i + offset] = s[s.Length - 1 - i];
            }
        }

        public static string ReplaceCRLF(string src)
        {
            return new Regex("\r\n|\n").Replace(src, "");
        }
    }
}

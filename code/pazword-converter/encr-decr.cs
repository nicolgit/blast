using System;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Text;

namespace Blast.Models
{
    public class EncrDecr
    {
        public const int C_KEYSIZE = 24;
        public const int C_IVSIZE = 8;

        public TripleDESCryptoServiceProvider alg;

        public EncrDecr()
        {
            alg = new TripleDESCryptoServiceProvider();
        }

        public void buildKey(string key)
        {
            alg.GenerateKey();
            alg.GenerateIV();

            byte[] k = alg.Key;

            
            int i;
            for (i = 0; i < key.Length && i < C_KEYSIZE; i++)
            {
                k[i] = (byte)(key[i] & 0xFF);
            }
            alg.Key = k;
        }

        public byte[] Encrypt(string source, byte[] fullkey, byte[] iv)
        {
            byte[] bin = new byte[(2 * source.Length) + 16];
            byte[] bout = new byte[(2 * source.Length) + 16];
            System.IO.MemoryStream fout = new System.IO.MemoryStream(bout, 0, source.Length * 2 + 16, true, true);
            int i, j;

            fullkey = (byte[])fullkey.Clone();
            iv = (byte[])iv.Clone();

            // TEST (UNICODE): source="鯡鯢鯤鯥";

            // convert string to byte array
            for (i = j = 0; i < source.Length; i++, j += 2)
            {
                bin[j] = (byte)(source[i] & 0xFF);
                bin[j + 1] = (byte)((source[i] >> 8) & 0xFF);
            }

            CryptoStream encStream = new CryptoStream(fout, alg.CreateEncryptor(fullkey, iv), CryptoStreamMode.Write);
            encStream.Write(bin, 0, bin.Length);

            return bout;
        }

        public string Decrypt(byte[] source, byte[] fullkey, byte[] iv)
        {
            byte[] bout = new byte[source.Length];
            System.IO.MemoryStream fout = new System.IO.MemoryStream(bout, 0, source.Length, true, true);
            int i;

            fullkey = (byte[])fullkey.Clone();
            iv = (byte[])iv.Clone();

            CryptoStream decStream = new CryptoStream(fout, alg.CreateDecryptor(fullkey, iv), CryptoStreamMode.Write);

            decStream.Write(source, 0, source.Length);

            string output;

            // convert byte array to string
            output = "";
            for (i = 0; i < bout.Length; i += 2)
            {
                output += (char)(bout[i] + (bout[i + 1] << 8));
            }

            //return output;
            return output.Substring(0, output.IndexOf('\0'));
        }

        private const string C_HEX = "0123456789ABCDEF";
        public byte hex2byte(string sin)
        {
            return (byte)(C_HEX.LastIndexOf(sin[0]) * 16 + C_HEX.LastIndexOf(sin[1]));
        }
    }
}

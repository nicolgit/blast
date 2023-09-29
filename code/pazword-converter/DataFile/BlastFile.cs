using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Metadata;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace Blast.Model.DataFile
{
    public class BlastFile
    {
        private const string FF_PAZWORD = "PASSWORD-";
        private const string FF_BLAST01 = "BLAST01";
        private static string[] fileFormats = { FF_PAZWORD, FF_BLAST01 };

        public string Password { get; set; }

        public byte[] FileEncrypted { get; set; }
        public string FileReadable { get; set; }

        public BlastFile() { }

        /// <summary>
        /// try to decrypt FileEncrypted using FilePassword 
        /// 
        /// if it works
        ///     FileReadable contains the result in string format
        ///     returns blastDocument contains the result in blast format 
        /// </summary>
        public BlastDocument GetBlastDocument()
        {
            using (MemoryStream encryptedFileInMemory = new MemoryStream(FileEncrypted))
            {
                // Use the encryptedFileInMemory stream in a binary reader.
                using (BinaryReader br = new BinaryReader(encryptedFileInMemory, Encoding.UTF8))
                {
                    string fileTypeIdentifier;

                    // read 'PASSWORD-'
                    fileTypeIdentifier = br.ReadString();
                    if (string.IsNullOrEmpty(fileTypeIdentifier)) throw new Exceptions.BlastFileEmptyException();
                    switch (fileTypeIdentifier)
                    {
                        case FF_PAZWORD:
                            return parsePazwordFile(decryptPazwordFile (encryptedFileInMemory, fileTypeIdentifier, br));
                        case FF_BLAST01:
                            var salt = br.ReadBytes(8);
                            var iterations = br.ReadInt32();
                            var IV = br.ReadBytes(16);
                            var encryptedLoremLength = br.ReadInt32();
                            var encryptedLorem = br.ReadBytes(encryptedLoremLength);

                            var k1 = new Rfc2898DeriveBytes(this.Password, salt, iterations, HashAlgorithmName.SHA256);
                            var algorithm = Aes.Create();
                            algorithm.Key = k1.GetBytes(16);
                            algorithm.IV = IV;
                            algorithm.Mode = CipherMode.CBC;

                            string decryptedLorem = decryptBytes (algorithm, encryptedLorem);

                            // check if password is OK before
                            if (decryptedLorem == null || decryptedLorem.CompareTo(LOREM_TEXT) != 0)
                            {
                                throw new Exceptions.BlastFileWrongPasswordException();
                            }

                            StringBuilder jsonStringBuilder = new StringBuilder();
                            do
                            {
                                var encryptedBlockLength = br.ReadInt32 ();
                                var encryptedBlock = br.ReadBytes (encryptedBlockLength);

                                string decryptedBlock = decryptBytes(algorithm, encryptedBlock);

                                jsonStringBuilder.Append (decryptedBlock);
                            } while (br.BaseStream.Position != br.BaseStream.Length);

                            this.FileReadable = jsonStringBuilder.ToString ();

                            return JsonSerializer.Deserialize<BlastDocument>(FileReadable);
                        default:
                            throw new Exceptions.BlastFileFormatException();
                    }
                }
            }
        }

        /// <summary>
        /// encrypt document using FilePassword
        /// 
        /// if it works
        ///     FileReadable contains the document in string format
        ///     FileEncrypted contains the document encrypted
        /// </summary>
        /// <param name="document"></param>
        /// <returns>raise an exception in case of failure</returns>
        public void PutBlastDocument(BlastDocument document)
        {
            this.FileReadable = JsonSerializer.Serialize(document);

            //https://stackoverflow.com/questions/75988087/how-can-i-verify-that-the-key-and-iv-i-am-using-are-the-correct-ones
            //https://learn.microsoft.com/en-us/dotnet/api/system.security.cryptography.rfc2898derivebytes?view=net-7.0

            // Create a random salt.
            var salt = new byte[8];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(salt);
            }

            // Generate Key and IV
            int iterations = 1000;
            var k1 = new Rfc2898DeriveBytes(this.Password, salt, iterations, HashAlgorithmName.SHA256);
            
            var algorithm = Aes.Create();
            algorithm.Key = k1.GetBytes(16);
            algorithm.GenerateIV();
            algorithm.Mode = CipherMode.CBC;

            System.IO.MemoryStream outputStream = new System.IO.MemoryStream();
            System.IO.BinaryWriter outputWriter = new System.IO.BinaryWriter(outputStream, System.Text.Encoding.UTF8);

            // writes file type identifier
            outputWriter.Write(FF_BLAST01);

            // writes the crypt_iv in the file
            outputWriter.Write(salt);
            outputWriter.Write(iterations);
            outputWriter.Write(algorithm.IV);

            var encryptedString = encryptString(algorithm, LOREM_TEXT);

            outputWriter.Write(encryptedString.Length);
            outputWriter.Write(encryptedString);

            for (int i = 0; i < FileReadable.Length; i += BLOCK_SIZE)
            {
                if (i + BLOCK_SIZE <= FileReadable.Length)
                {
                    encryptedString = encryptString(algorithm, FileReadable.Substring(i, BLOCK_SIZE));
                    outputWriter.Write(encryptedString.Length);
                    outputWriter.Write(encryptedString);
                }
                else
                {
                    encryptedString = encryptString(algorithm, FileReadable.Substring(i));
                    outputWriter.Write(encryptedString.Length);
                    outputWriter.Write(encryptedString);
                }
            }

            outputWriter.Close();
            this.FileEncrypted = outputStream.ToArray();
            outputStream.Close();
        }

        #region PAZWORD FILE FORMAT READER
        private BlastDocument parsePazwordFile(string file)
        {
            var xdoc = XDocument.Parse(file);

            var pf = new BlastDocument();

            try
            {
                var info = xdoc.Root.Element("info");
                var guid = info.Attribute("guid").Value;
                var parse = Guid.Parse(guid);

                pf.Id = Guid.Parse(xdoc.Root.Element("info").Attribute("guid").Value);
                foreach (var node in xdoc.Root.Element("nodes").Elements("node"))
                {
                    var card = new Card();

                    card.Id = Guid.Parse(node.Attribute("guid").Value);
                    card.Title = node.Attribute("title").Value;
                    card.IsFavorite = node.Attribute("favorite") != null ? node.Attribute("favorite").Value.Equals("1") : false;
                    card.UsedCounter = node.Attribute("usedcounter") != null ? int.Parse(node.Attribute("usedcounter").Value) : 0;
                    card.Notes = "";

                    if (node.Element("moreinfo") != null)
                    {
                        foreach (var row in node.Element("moreinfo").Elements("line"))
                        {
                            card.Notes += row.Value + "\r\n";
                        }
                    }

                    foreach (var attr in node.Elements("attribute"))
                    {
                        Attribute attribute = new Attribute();

                        if (attr.Attribute("value").Value == "")
                        {
                            attribute.Type = AttributeType.TYPE_HEADER;
                        }
                        else
                        {
                            if (attr.Attribute("type") != null)
                            {
                                if (attr.Attribute("type").Value == "password")
                                {
                                    attribute.Type = AttributeType.TYPE_PASSWORD;
                                }
                                if (attr.Attribute("type").Value == "generic")
                                {
                                    attribute.Type = AttributeType.TYPE_STRING;
                                }
                                if (attr.Attribute("type").Value == "URL")
                                {
                                    attribute.Type = AttributeType.TYPE_URL;
                                }
                            }
                        }

                        attribute.Name = attr.Attribute("name").Value;
                        attribute.Value = attr.Attribute("value").Value;

                        card.Rows.Add(attribute);
                    }

                    pf.Cards.Add(card);
                }
            }
            catch
            {


            }

            return pf;
        }
        private string decryptPazwordFile(MemoryStream encryptedFileInMemory, string fileTypeIdentifier, BinaryReader br)
        {
            TripleDES algorithm = TripleDES.Create();

            byte[] crypt_key; // public key for encrypted doc
            byte[] crypt_iv;  // init vector for encrypted doc

            crypt_key = new byte[algorithm.Key.Length];
            crypt_iv = new byte[algorithm.IV.Length];

            // use password as crypto KEY 
            int i;
            for (i = 0; i < Password.Length && i < algorithm.Key.Length; i++)
                crypt_key[i] = (byte)(Password[i] & 0xFF);

            byte[] data = new byte[encryptedFileInMemory.Length - (fileTypeIdentifier.Length + 1) - (algorithm.Key.Length - i) - algorithm.IV.Length];

            // read remaining crypto key
            for (; i < algorithm.Key.Length; i++)
                crypt_key[i] = br.ReadByte();

            // read crypt-iv
            br.Read(crypt_iv, 0, algorithm.IV.Length);

            // read encrypted VerifyText
            byte[] data_test = new byte[C_VERIFYTEXT_LEGACY.Length * 2 + 16];
            br.Read(data_test, 0, C_VERIFYTEXT_LEGACY.Length * 2 + 16);

            string decrypted = decryptBytesLegacy(algorithm, data_test, crypt_key, crypt_iv);
            string verifyText = C_VERIFYTEXT_LEGACY;

            StringBuilder readableFileString = new StringBuilder(10000);

            int compare = decrypted.CompareTo(verifyText);
            if (compare != 0)
            {
                throw new Exceptions.BlastFileWrongPasswordException();
            }

            // password is correct, returning readable file
            byte[] data_frag = new byte[C_BLOCKSIZE_LEGACY * 2 + 16];
            int realSize;

            while ((realSize = br.Read(data_frag, 0, C_BLOCKSIZE_LEGACY * 2 + 16)) > 0)
            {
                int olds = readableFileString.Length;

                string element = decryptBytesLegacy(algorithm, data_frag, crypt_key, crypt_iv);

                readableFileString.Append(element, 0, element.Length);
            }

            FileReadable = readableFileString.ToString();

            return FileReadable;
        }
        #endregion

        #region ENCRYPTION-DECRIPTION STUFF
        private const int C_BLOCKSIZE_LEGACY = 2000;
        private const string C_VERIFYTEXT_LEGACY = "Era invevitabile: l'odore delle mandorle amare gli ricordava sempre il destino degli amori contrastati. Il dottor Juvenal Urbino lo sentì appena entrato nella casa ancora in penombra, dove era accorso d'urgenza per occuparsi di un caso che per lui aveva cessato di essere urgente da molti anni. Il rifugiato antillano Jeremiah de Saint-Amour, invalido di guerra, foto- grafo di bambini e il suo avversario di scacchi più pietoso, si era messo in salvo dai tormenti della memoria con un suffumigio di cianuro di oro.";

        private const int BLOCK_SIZE = 12000;
        private const string LOREM_TEXT = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

        private static byte[] encryptString(SymmetricAlgorithm algorithm, string stringToEncrypt)
        {
            byte[] utf = new System.Text.UTF8Encoding(false).GetBytes(stringToEncrypt);
            var encrypted = algorithm.EncryptCbc(utf, algorithm.IV);
            return encrypted;
        }

        private string decryptBytes (SymmetricAlgorithm algorithm, byte[] bytesToDecrypt) 
        {
            var decrypted = algorithm.DecryptCbc(bytesToDecrypt, algorithm.IV);

            if (decrypted == null) return null;

            string decryptedString = new UTF8Encoding(false).GetString(decrypted);
            return decryptedString;
        }

        private static string decryptBytesLegacy(SymmetricAlgorithm algorithm, byte[] source, byte[] fullKey, byte[] iv)
        {
            byte[] bout = new byte[source.Length];
            MemoryStream memoryStream = new MemoryStream(bout, 0, source.Length, true, true);
            int i;

            fullKey = (byte[])fullKey.Clone();
            iv = (byte[])iv.Clone();

            CryptoStream decStream = new CryptoStream(memoryStream, algorithm.CreateDecryptor(fullKey, iv), CryptoStreamMode.Write);

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
        #endregion
    }

}


using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace Blast.Models
{
    public class PazDocumentLegacy
    {

        #region PRIVATE
        private const string NEWDOCUMENTNAME = "NewDocument.pz";
        private const string FILEEXTENSION = ".pz";
        private const string PASSWORD_PROTECTED = "PASSWORD-";

        // string used to verify if the password is correct.
        // Da: "L'amore ai tempi del colera - Gabriel Garcia Marquez"
        private const string C_VERIFYTEXT = "Era invevitabile: l'odore delle mandorle amare gli ricordava " +
            "sempre il destino degli amori contrastati. Il dottor Juvenal " +
            "Urbino lo sent� appena entrato nella casa ancora in penombra, " +
            "dove era accorso d'urgenza per occuparsi di un caso che per lui " +
            "aveva cessato di essere urgente da molti anni. Il rifugiato " +
            "antillano Jeremiah de Saint-Amour, invalido di guerra, foto- " +
            "grafo di bambini e il suo avversario di scacchi pi� pietoso, si era " +
            "messo in salvo dai tormenti della memoria con un suffumigio di " +
            "cianuro di oro.";
        private const int C_BLOCKSIZE = 2000;

        // XML Tags
        private const string TAG_TITLE = "title";
        private const string TAG_GUID = "guid";
        private const string TAG_PARENTGUID = "parent";
        private const string TAG_TIMESTAMP = "timestamp";
        private const string TAG_USEDTIME = "usedtime";
        private const string TAG_USEDCOUNTER = "usedcounter";
        private const string TAG_FAVORITE = "favorite";
        private const string TAG_ICON = "icon";
        private const string TAG_FILEVERSION = "fileversion";

        
        private System.Xml.XmlDocument xmlDoc;
        
        private string szFullfile;

        private string unlockPassword; // password used to encript/decrypt xml file
        private byte[] crypt_key; // public key for encrypted doc
        private byte[] crypt_iv;  // init vectory for encrypted doc
        #endregion

        #region PUBLIC
        public string FileName { get; set; }
        public bool BackupOnExit { get; set; }
        public bool BackupNoPassword { get; set; }
        public bool Changed { get; set; }

        public PazDocumentLegacy()
        {
            DocNew();
        }

        public void DocNew()
        {
            szFullfile = null;
            FileName = PazDocumentLegacy.NEWDOCUMENTNAME;
            crypt_iv = crypt_key = null;
            unlockPassword = null;
            Changed = false;
            xmlDoc = new System.Xml.XmlDocument();

            System.Resources.ResourceManager rm = new System.Resources.ResourceManager("Client.net.clientRes", System.Reflection.Assembly.GetExecutingAssembly());
            xmlDoc.LoadXml(rm.GetString("newDocument"));
            SetNewDocumentGUID();
            checkXMLValidity();
        }

        public bool DocLoad(string fileName)
        {
            DocNew();
            load();
            return true;
        }

        public bool DocSave()
        {
            save();
            return true;
        }


        /// <summary>
        /// For an XMLnode, change value for an attribute.
        /// Ff the attribute doesn't existit an error is raised
        /// </summary>
        /// <param name="node">XmlNode where find attribute</param>
        /// <param name="attribute">attribute name</param>
        /// <param name="value">new value</param>
        public void SetAttributeByName(System.Xml.XmlNode node, string attribute, string value)
        {
            int i, max;
            bool found;

            max = node.Attributes.Count;
            found = false;
            for (i = 0; i < max; i++)
            {
                if (node.Attributes.Item(i).Name == attribute)
                {
                    found = true;
                    node.Attributes.Item(i).Value = value;
                }
            }

            if (!found)
            {
                System.Xml.XmlElement elem = (System.Xml.XmlElement)node;
                elem.SetAttribute(attribute, value);
            }
        }


        /// <summary>
        /// return attribute value named "attribute" if exists. return null otherwise
        /// </summary>
        /// <param name="node">node where find</param>
        /// <param name="attribute">attribute to retrieve</param>
        /// <returns></returns>
        public string GetAttributeByName(System.Xml.XmlNode node, string attribute)
        {
            int i, max;

            max = node.Attributes.Count;
            for (i = 0; i < max; i++)
            {
                if (node.Attributes.Item(i).Name == attribute)
                    return node.Attributes.Item(i).Value;
            }

            return "";
        }


        /// <summary>
        /// Append xml into 'text' string after node 'parent' in root/nodes
        /// </summary>
        /// <param name="text">xml string to insert</param>
        /// <param name="parent">xmlnode parent under root/nodes</param>
        public void Text2Xml(string text, System.Xml.XmlNode parent)
        {
            System.Xml.XmlNode xmlParent = FindXmlNodeByGuid(GetAttributeByName(parent, PazDocumentLegacy.TAG_GUID));

            System.Xml.XmlDocumentFragment frag = xmlDoc.CreateDocumentFragment();
            frag.InnerXml = text;

            parent.ParentNode.InsertAfter(frag, parent);
        }

        /// <summary>
        /// SelectXmlNode of an item of selected guid
        /// </summary>
        /// <param name="guid">guid to find</param>
        /// <returns>XmlNode if exist otherwise null...</returns>
        public System.Xml.XmlNode FindXmlNodeByGuid(string guid)
        {
            System.Xml.XmlElement root = xmlDoc.DocumentElement;
            string s = "/root/nodes/node[@" + PazDocumentLegacy.TAG_GUID + "='" + guid + "']";

            return root.SelectSingleNode(s);
        }

        public System.Xml.XmlNode GetNodesItem()
        {
            System.Xml.XmlElement root = xmlDoc.DocumentElement;
            string s = "/root/nodes";

            return root.SelectSingleNode(s);
        }

        /// <summary>
        /// SelectXmlNodes of an item of selected parentguid
        /// </summary>
        /// <param name="guid">parent guid to find</param>
        /// <returns>XmlNodes if exista otherwise null...</returns>
        public System.Xml.XmlNodeList FindXmlNodeByParentGuid(string guid)
        {
            System.Xml.XmlElement root = xmlDoc.DocumentElement;
            string s = "/root/nodes/node[@" + PazDocumentLegacy.TAG_PARENTGUID + "='" + guid + "']";

            return root.SelectNodes(s);
        }

        #endregion

        public string GetMorefield(string guid)
        {
            System.Xml.XmlElement root = xmlDoc.DocumentElement;
            string s = "/root/nodes/node[@" + PazDocumentLegacy.TAG_GUID + "='" + guid + "']/moreinfo";

            if (root.SelectNodes(s).Count > 0)
            {
                //return root.SelectNodes(s).Item(0).InnerText;
                string more = "";
                foreach (System.Xml.XmlNode xLine in root.SelectNodes(s).Item(0).ChildNodes)
                {
                    more += xLine.InnerText;

                    if (xLine != root.SelectNodes(s).Item(0).ChildNodes.Item(root.SelectNodes(s).Item(0).ChildNodes.Count - 1))
                    {
                        more += "\r\n";
                    }
                }

                return more;
            }
            else
                return "";
        }

        public void SetMorefield(string guid, string[] value)
        {
            System.Xml.XmlElement root = xmlDoc.DocumentElement;
            string s = "/root/nodes/node[@" + PazDocumentLegacy.TAG_GUID + "='" + guid + "']/moreinfo";

            System.Xml.XmlNode xMore;

            System.Xml.XmlNodeList xnl = root.SelectNodes(s);
            if (xnl.Count > 0)
            {
                xMore = root.SelectNodes(s).Item(0);
                //root.SelectNodes(s).Item(0).InnerText= value;
            }
            else
            {
                System.Xml.XmlNode node = FindXmlNodeByGuid(guid);
                xMore = xmlDoc.CreateElement("moreinfo");
                //nodemore.InnerText = value;
                //node.AppendChild (nodemore);
                node.AppendChild(xMore);
            }

            xMore.InnerXml = "";

            foreach (string line in value)
            {
                System.Xml.XmlNode xLine = xmlDoc.CreateElement("line");
                xLine.InnerText = line;
                xMore.AppendChild(xLine);
            }

        }

        /// <summary>
        /// Get outher XML of node of selected guid
        /// </summary>
        /// <param name="guid">guid of xml to retrieve</param>
        /// <param name="recursive">if true retrive all childs nested</param>
        /// <returns></returns>
        public string GetXMLfromGUID(string guid, bool recursive)
        {
            string xml;
            System.Xml.XmlNode node = FindXmlNodeByGuid(guid);

            xml = node.OuterXml;
            if (recursive)
            {
                System.Xml.XmlNodeList nodes = FindXmlNodeByParentGuid(GetAttributeByName(node, PazDocumentLegacy.TAG_GUID));

                foreach (System.Xml.XmlNode nd in nodes)
                {
                    xml += GetXMLfromGUID(GetAttributeByName(nd, PazDocumentLegacy.TAG_GUID), true);
                }
            }
            return xml;
        }

        //doc.removeItemByGUID (treenodeSource.Tag.ToString());
        /// <summary>
        /// remove item of selected 'GUID' and all its child recursivly
        /// </summary>
        /// <param name="guidRoot">string containig 'GUID' to delete</param>
        public void removeItemByGUID(string guidRoot)
        {
            System.Xml.XmlNode node = FindXmlNodeByGuid(guidRoot);

            // remove childs first
            System.Xml.XmlNodeList nodes = FindXmlNodeByParentGuid(GetAttributeByName(node, PazDocumentLegacy.TAG_GUID));

            foreach (System.Xml.XmlNode nd in nodes)
            {
                removeItemByGUID(GetAttributeByName(nd, PazDocumentLegacy.TAG_GUID));
            }

            // remove node
            node.ParentNode.RemoveChild(node);
        }

        public void replaceItemNode(string newxml)
        {
            System.Xml.XmlDocumentFragment fragdoc = xmlDoc.CreateDocumentFragment();
            fragdoc.InnerXml = newxml;

            string guid = GetAttributeByName(fragdoc.FirstChild, PazDocumentLegacy.TAG_GUID);
            System.Xml.XmlNode node = FindXmlNodeByGuid(guid);

            node.ParentNode.ReplaceChild(fragdoc.FirstChild, node);
        }

        public void InsertAfter(string xmlString, System.Xml.XmlNode xParentItem)
        {
            System.Xml.XmlDocumentFragment fragdoc = xmlDoc.CreateDocumentFragment();
            fragdoc.InnerXml = xmlString;

            if (xParentItem != null)
                xParentItem.ParentNode.InsertAfter(fragdoc, xParentItem);
            else
            {
                System.Xml.XmlNode nodes = GetNodesItem();
                nodes.AppendChild(fragdoc);

            }
        }

        private void SetNewDocumentGUID()
        {
            System.Xml.XmlElement root = xmlDoc.DocumentElement;
            string s = "/root/info";

            System.Xml.XmlElement info = (System.Xml.XmlElement)root.SelectSingleNode(s);

            info.SetAttribute("guid", Guid.NewGuid().ToString());
        }

        private void load()
        {
            if (FileName != NEWDOCUMENTNAME)
            {
                System.IO.TextReader sr = new System.IO.StreamReader(FileName, System.Text.Encoding.UTF8);

                szFullfile = sr.ReadToEnd();
                sr.Close();
                if (szFullfile.Substring(1, PASSWORD_PROTECTED.Length) == PASSWORD_PROTECTED)
                {
                    // file is password protected
                    // NOP!
                }
                else
                {
                    xmlDoc.LoadXml(szFullfile);
                    checkXMLValidity();
                    szFullfile = null;
                }
            }
        }

        /// <summary>
        /// check xmlDoc validity seeking an element
        /// </summary>
        private void checkXMLValidity()
        {
            System.Xml.XmlElement root = xmlDoc.DocumentElement;
            string s = "/root/info";

            System.Xml.XmlNode node = root.SelectSingleNode(s);
            s = GetAttributeByName(node, TAG_FILEVERSION);

            switch (s)
            {
                case "1":
                    _Upgrade_1_2();
                    checkXMLValidity();

                    // scompattare moreinfo in pi� linee
                    // aggiornare fileversion su "2"
                    // modificare "newDocument" nelle risorse (fileversion=2)
                    // modificare template "card-default"

                    break;
                case "2":
                    _Upgrade_2_3();
                    checkXMLValidity();

                    /// il campo "used counter" � allineato a destra
                    /// con un casino di spazi davanti :)

                    break;
                case "3":
                    // nothing
                    break;
                default:
                    throw new System.Exception("checkXMLValidity: Invalid File Version");
            }
        }

        public bool TryPassword(string password)
        {
            bool bRet = false;
            unlockPassword = password;
            string tmp;

            EncrDecr ed;
            ed = new EncrDecr();

            crypt_key = new byte[EncrDecr.C_KEYSIZE];
            crypt_iv = new byte[EncrDecr.C_IVSIZE];

            System.IO.FileStream fs = new System.IO.FileStream(FileName, System.IO.FileMode.Open);
            System.IO.BinaryReader br = new System.IO.BinaryReader(fs, System.Text.Encoding.UTF8);

            // read 'PASSWORD-'
            tmp = br.ReadString();

            // set password
            int i;
            for (i = 0; i < unlockPassword.Length && i < EncrDecr.C_KEYSIZE; i++)
                crypt_key[i] = (byte)(unlockPassword[i] & 0xFF);

            byte[] data = new Byte[fs.Length - (tmp.Length + 1) - (EncrDecr.C_KEYSIZE - i) - EncrDecr.C_IVSIZE];

            // read crypt-key
            for (; i < EncrDecr.C_KEYSIZE; i++)
                crypt_key[i] = br.ReadByte();

            // read crypt-iv
            br.Read(crypt_iv, 0, EncrDecr.C_IVSIZE);

            // read VerifyText
            byte[] data_test = new Byte[C_VERIFYTEXT.Length * 2 + 16];
            br.Read(data_test, 0, C_VERIFYTEXT.Length * 2 + 16);


            if (ed.Decrypt(data_test, crypt_key, crypt_iv).CompareTo(C_VERIFYTEXT) != 0)
            {
                unlockPassword = "";
                bRet = false;
            }
            else
            {
                byte[] data_frag = new Byte[C_BLOCKSIZE * 2 + 16];
                int realsize;
                System.Text.StringBuilder xml = new System.Text.StringBuilder(10000);

                while ((realsize = br.Read(data_frag, 0, C_BLOCKSIZE * 2 + 16)) > 0)
                {
                    int olds = xml.Length;
                    ed = new EncrDecr();

                    string element = ed.Decrypt(data_frag, crypt_key, crypt_iv);

                    xml.Append(element, 0, element.Length);
                }

                xmlDoc.LoadXml(xml.ToString());
                this.szFullfile = null;
                bRet = true;
            }

            checkXMLValidity();

            br.Close();
            fs.Close();
            return bRet;
        }

        private void save()
        {
            string strBackupFileName = FileName.Replace(FILEEXTENSION, DateTime.Now.ToString("yyyyMMdd") + Guid.NewGuid().ToString() + FILEEXTENSION);

            if (unlockPassword == null)
            {
                // backup copy save
                if (BackupOnExit)
                    xmlDoc.Save(strBackupFileName);

                xmlDoc.Save(FileName);
            }
            else
            {
                // backup copy save
                if (BackupOnExit)
                {
                    if (BackupNoPassword)
                        xmlDoc.Save(strBackupFileName);
                    else
                        save_encrypted(strBackupFileName);
                }
                save_encrypted(FileName);
            }
        }

        private void save_encrypted(string szFileName)
        {
            EncrDecr ed;
            System.IO.FileStream fs = new System.IO.FileStream(szFileName, System.IO.FileMode.Create);
            System.IO.BinaryWriter sw = new System.IO.BinaryWriter(fs, System.Text.Encoding.UTF8);

            sw.Write(PASSWORD_PROTECTED);

            int i, l;
            string tmp;
            for (i = unlockPassword.Length; i < EncrDecr.C_KEYSIZE; i++)
                sw.Write(crypt_key[i]);
            //sw.Write(crypt_key);

            sw.Write(crypt_iv);

            ed = new EncrDecr();
            sw.Write(ed.Encrypt(C_VERIFYTEXT, crypt_key, crypt_iv));

            tmp = xmlDoc.OuterXml;
            l = tmp.Length;
            for (i = 0; i < l; i += C_BLOCKSIZE)
            {
                if (i + C_BLOCKSIZE <= l)
                {
                    ed = new EncrDecr();
                    sw.Write(ed.Encrypt(tmp.Substring(i, C_BLOCKSIZE), crypt_key, crypt_iv));
                }
                else
                {
                    ed = new EncrDecr();
                    sw.Write(ed.Encrypt(tmp.Substring(i), crypt_key, crypt_iv));
                }
            }

            sw.Close();
            fs.Close();
        }

        /// <summary>
        /// renew all guids of xmlString
        /// </summary>
        /// <param name="xmlString"></param>
        /// <returns></returns>
        public string RefreshAllGuids(ref string xmlString)
        {
            System.Xml.XmlDocumentFragment fragdoc = xmlDoc.CreateDocumentFragment();
            fragdoc.InnerXml = xmlString;

            System.Collections.IEnumerator ie = fragdoc.ChildNodes.GetEnumerator();
            System.Collections.SortedList listGUID = new System.Collections.SortedList();

            string strFirstGUID = null;
            xmlString = "";
            while (ie.MoveNext())
            {
                System.Xml.XmlNode node = (System.Xml.XmlNode)ie.Current;

                string OldGUID = GetAttributeByName(node, PazDocumentLegacy.TAG_GUID);
                string NewGUID = Guid.NewGuid().ToString();
                string ParentGUID = GetAttributeByName(node, PazDocumentLegacy.TAG_PARENTGUID);

                if (strFirstGUID == null)
                {
                    strFirstGUID = NewGUID;
                }

                listGUID.Add(OldGUID, NewGUID);

                if (listGUID.Contains(ParentGUID))
                {
                    SetAttributeByName(node, PazDocumentLegacy.TAG_PARENTGUID, (string)listGUID.GetByIndex(listGUID.IndexOfKey(ParentGUID)));
                }

                SetAttributeByName(node, PazDocumentLegacy.TAG_GUID, NewGUID);
                SetAttributeByName(node, PazDocumentLegacy.TAG_TIMESTAMP, DateTime.Now.Ticks.ToString());
                xmlString += node.OuterXml;
            }

            return strFirstGUID;
        }

        /// <summary>
        /// Set card's Lastusertime to now and increment used counter
        /// </summary>
        /// <param name="guid"></param>
        public void SetLastusedTime(string guid)
        {
            System.Xml.XmlNode node = FindXmlNodeByGuid(guid);
            SetAttributeByName(node, PazDocumentLegacy.TAG_USEDTIME, DateTime.Now.Ticks.ToString());

            string uc = (System.Convert.ToInt32("0" + GetAttributeByName(node, PazDocumentLegacy.TAG_USEDCOUNTER).Trim()) + 1).ToString();
            SetAttributeByName(node, PazDocumentLegacy.TAG_USEDCOUNTER, String.Format("{0,10}", uc));

            SetAttributeByName(node, PazDocumentLegacy.TAG_TIMESTAMP, DateTime.Now.Ticks.ToString());
        }

        /// <summary>
        /// remove 'tag' attribute from all nodes
        /// </summary>
        /// <param name="tag"></param>
        public void removetag(string tag)
        {
            System.Xml.XmlNodeList nodes = GetNodesItem().ChildNodes;
            System.Collections.IEnumerator ie = nodes.GetEnumerator();

            while (ie.MoveNext())
            {
                System.Xml.XmlNode node = (System.Xml.XmlNode)ie.Current;
                SetAttributeByName(node, tag, "");
            }
        }

        private void _Upgrade_1_2()
        {
            // upgrade from version 1 to 2 pazWordFile
            /// il campo more info diventa da una linea ad n lineee
            /// la versione passa da 1 ad 2

            System.Xml.XmlElement root = xmlDoc.DocumentElement;
            string s = "/root/nodes/node/moreinfo";

            foreach (System.Xml.XmlNode xMore in root.SelectNodes(s))
            {
                string morein = xMore.InnerText;
                string[] linein = morein.Split('\n');

                xMore.InnerXml = "";
                foreach (string line in linein)
                {
                    string[] line2 = line.Split('\r');
                    System.Xml.XmlNode xLine = xmlDoc.CreateElement("line");
                    xLine.InnerText = line2[0];
                    xMore.AppendChild(xLine);
                }
            }

            s = "/root/info";
            System.Xml.XmlNode node = root.SelectSingleNode(s);
            SetAttributeByName(node, TAG_FILEVERSION, "2");
        }

        private void _Upgrade_2_3()
        {
            // upgrade from version 2 to 3 pazWordFile
            /// il campo used count diventa "000000000000" (spazi!)
            /// la versione passa da 2 a 3

            System.Xml.XmlElement root = xmlDoc.DocumentElement;
            string s = "/root/nodes/node";

            foreach (System.Xml.XmlNode xNode in root.SelectNodes(s))
            {
                String uc = GetAttributeByName(xNode, PazDocumentLegacy.TAG_USEDCOUNTER);

                if (uc != "")
                {
                    uc = String.Format("{0,10}", uc);
                    SetAttributeByName(xNode, PazDocumentLegacy.TAG_USEDCOUNTER, uc);
                }
            }

            s = "/root/info";
            System.Xml.XmlNode node = root.SelectSingleNode(s);
            SetAttributeByName(node, TAG_FILEVERSION, "3");
        }
    }
}

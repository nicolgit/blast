using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using static System.Net.Mime.MediaTypeNames;

namespace Blast.Model.DataFile
{
    public class Card
    {
        public Card()
        {
            Id = Guid.NewGuid();
            Tags = new List<string>();
            Rows = new List<Attribute>();
        }

        public Guid Id { get; set; }
        public string Title { get; set; }
        public string Notes { get; set; }
        public bool IsFavorite { get; set; }
        public DateTime LastUpdateDateTime { get; set; }
        public DateTime LastOpenedDateTime { get; set; }
        public int UsedCounter { get; set; }
        public List<string> Tags { get; set; }
        public List<Attribute> Rows { get; set; }

        public override string ToString()
        {
            StringBuilder sb = new StringBuilder();

            sb.Append(Title);
            sb.Append(" ");
            sb.Append(Notes);
            
            foreach (var tag in Tags)
            {
                sb.Append(tag);
                sb.Append(" ");
            }

            foreach (var row in Rows)
            {
                switch (row.Type)
                {
                    case AttributeType.TYPE_PASSWORD:
                        // do not search by password value
                        break;
                    case AttributeType.TYPE_HEADER:
                        sb.Append(row.Name);
                        break;
                    default:
                    case AttributeType.TYPE_URL:
                        sb.Append(row.Value);
                        break;
                    case AttributeType.TYPE_STRING:
                        sb.Append($"{row.Name} {row.Value}");
                        break;
                }
                sb.Append(" ");
            }

            return sb.ToString();
        }

        public enum AdvancedSearchResult { NotFound, InTitle, InBody };

        public AdvancedSearchResult AdvancedSearch (string text)
        {
            var words = text.Split(" ");
            var result = AdvancedSearchResult.NotFound;

            foreach (var word in words)
            {
                if (word.Length > 0)
                {
                    var tempResult = this.ContainsWord(word);

                    if (tempResult == AdvancedSearchResult.NotFound)
                    {
                        return AdvancedSearchResult.NotFound;
                    }

                    if (tempResult == AdvancedSearchResult.InTitle || result == AdvancedSearchResult.InTitle)
                    {
                        result = AdvancedSearchResult.InTitle;
                    }
                    else
                    {
                        result = AdvancedSearchResult.InBody;
                    }
                }
            }

            return result;
        }

        public AdvancedSearchResult ContainsWord(string s)
        {
            s = RemoveDiacritics(s);

            if (this.Title != null)
            {
                if (RemoveDiacritics(this.Title).Contains(s, StringComparison.InvariantCultureIgnoreCase))
                    return AdvancedSearchResult.InTitle;
            }

            var me = RemoveDiacritics(this.ToString());
            return me.Contains(s, StringComparison.InvariantCultureIgnoreCase) ? AdvancedSearchResult.InBody : AdvancedSearchResult.NotFound;
        }

        // https://stackoverflow.com/questions/249087/how-do-i-remove-diacritics-accents-from-a-string-in-net
        string RemoveDiacritics(string text)
        {
            var normalizedString = text.Normalize(NormalizationForm.FormD);
            var stringBuilder = new StringBuilder();

            foreach (var c in normalizedString)
            {
                var unicodeCategory = CharUnicodeInfo.GetUnicodeCategory(c);
                if (unicodeCategory != UnicodeCategory.NonSpacingMark)
                {
                    stringBuilder.Append(c);
                }
            }

            return stringBuilder.ToString().Normalize(NormalizationForm.FormC);
        }
    }
}

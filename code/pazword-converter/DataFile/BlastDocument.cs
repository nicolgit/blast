using System;
using System.Collections.Generic;
using System.Text;

namespace Blast.Model.DataFile
{
    public class BlastDocument
    {
        public BlastDocument()
        {
            Id = Guid.NewGuid();
            Version = 10;
            Cards = new List<Card>();
        }

        public Guid Id { get; set; }
        public int Version { get; set; }

        public List<Card> Cards { get; set; }
    }
}

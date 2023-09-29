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

            var card1 = new Card();
            card1.Title = "lorem ipsut dixit";

            var card2 = new Card();
            card1.Title = "consectetur adipiscing elit";

            Cards.Add(card1);
            Cards.Add(card2);
        }

        public Guid Id { get; set; }
        public int Version { get; set; }

        public List<Card> Cards { get; set; }
    }
}

using System;
using System.Collections.Generic;
using System.Reflection;
using System.Text;

namespace Blast.Model.DataFile
{
    public class Attribute
    {
        public Attribute( AttributeType type = AttributeType.TYPE_STRING)
        {
            Type = type; 
        }

        public string Name { get; set; }
        public string Value { get; set; }
        public AttributeType Type { get; set; }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Blast.Model.Exceptions
{
    public class BlastExceptionBase : Exception { }

    public class BlastFileEmptyException: BlastExceptionBase { }
    public class BlastFileFormatException: BlastExceptionBase { }
    public class BlastFileWrongPasswordException: BlastExceptionBase { }
}

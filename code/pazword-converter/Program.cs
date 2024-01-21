

using System.Security.Cryptography;
using Blast.Model.DataFile;
using Blast.Model.Exceptions;

class PazwordConverterApp
{
    static void Main(string[] args)
    {
        if (args.Length != 2 && args.Length != 3)
        {
            Console.WriteLine("This command line utility converts Pazword's file to thenew blast format");
            Console.WriteLine("Usage: pazword-converter <input file> <output file>");
            Console.WriteLine("Example: pazword-converter input.pz output.blast [--no-password]");
            return;
        }   

        var inputFile = args[0];
        var outputFile = args[1];
        bool noPassword = args.Length == 3 && args[2] == "--no-password";

        if (! File.Exists(inputFile))
            {
                Console.WriteLine($"Input file {inputFile} does not exist.");
            }   


        Console.WriteLine($"Converting {inputFile} to {outputFile}...");

        var bytes = System.IO.File.ReadAllBytes(inputFile);

        BlastFile blastFile = new BlastFile();
        BlastDocument document;
        try
        {
            

            Console.WriteLine("Enter password:");
            //var password = Console.ReadLine();
            var password = string.Empty;
            while (true)
            {
                var key = Console.ReadKey(true);
                if (key.Key == ConsoleKey.Enter)
                    break;
                password += key.KeyChar;
                Console.Write("*");
            }

            if (password == null) 
                {
                    Console.WriteLine("Password cannot be null");
                    return;
                }
            blastFile.Password = password;

            blastFile.FileEncrypted = bytes;

            document = blastFile.GetBlastDocument();
        }
        catch (Exception e) when (  e is CryptographicException ||
                                    e is BlastFileWrongPasswordException )
        {
            Console.WriteLine("WRONG Password");
            return;
        }
        catch (Exception e)
        {
            Console.WriteLine($"Unexpected Exception {e.GetType().ToString()} {e.Message}");
            return;
        }

        blastFile.PutBlastDocument(document);

        if(noPassword)
            System.IO.File.WriteAllText(outputFile, blastFile.FileReadable);
        else
            System.IO.File.WriteAllBytes(outputFile, blastFile.FileEncrypted);
        
        Console.WriteLine("Completed successfully.");
    }
}
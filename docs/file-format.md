# .blast File Format Specification

.blast is the Blast 1.0 file format, which is used for storing user data (user names, passwords, URLs, etc.). 

This specification defines the latest version (10) of the .blast file format.

Some general notes on the KDBX file format and this specification:

* Integers are stored in little-endian byte order, i.e. the least significant byte is stored first. For example, the integer 0x12345678 is stored as the byte sequence (0x78, 0x56, 0x34, 0x12).

# overall structure

Blast overall file structure is shown below

![blast file format](blast-file-format.png)

*salt* and *iterations* values are used to generate the 256 bit Key Array using the 

```
String password = "xxxxxx";

var pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
pbkdf2.init(Pbkdf2Parameters(salt, iterations, 32)); // 32 * 8 = 256 bits key (AES256)
Uint8List key = pbkdf2.process(Uint8List.fromList(password.codeUnits));

```

Data block is decoded using  256-bit AES (Advanced Encryption Standard)

```
final cipher = PaddedBlockCipher("AES/CBC/PKCS7");
final ivParams = ParametersWithIV(KeyParameter(key), iv);
cipher.init(false, PaddedBlockCipherParameters(ivParams, null)); // false = encrypt

var loremEncrypted = binary.sublist(offset);
Uint8List output = Uint8List(0);

try {
    output = cipher.process(loremEncrypted);
} catch (e) {
    // Wrong password => Invalid argument(s): Invalid or corrupted pad block
    throw BlastWrongPasswordException();
}

String loremDecrypted = utf8.decode(output);
```


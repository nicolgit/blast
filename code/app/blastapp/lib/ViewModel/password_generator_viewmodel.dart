import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

enum GeneratorTypes {
  guid,
  text,
  numeric,
  wikiword;
}

class PasswordGeneratorViewModel extends ChangeNotifier {
  final BuildContext context;
  GeneratorTypes _generatorType = GeneratorTypes.guid; // Default to GUID
  bool _isRunning = false;
  Timer? _backgroundTimer;
  String _password = 'Generated password will appear here';
  int _textLength = 10;
  int _wordCount = 2; // Default to 2 words
  List<String> _words = []; // Will be populated from API
  String _selectedLanguage = 'en'; // Default to English

  // Private language mapping for Wikidata entity IDs
  final Map<String, String> _languageMap = {
    'en': 'Q1860', // English
    'it': 'Q652', // Italian
    'fr': 'Q150', // French
    'de': 'Q188', // German
    'es': 'Q1321', // Spanish
    'pt': 'Q5146', // Portuguese
    'nl': 'Q7411', // Dutch
  };

  PasswordGeneratorViewModel(this.context) {
    _startBackgroundProcess();
  }

  GeneratorTypes get generatorType => _generatorType;
  bool get isRunning => _isRunning;
  String get password => _password;
  int get textLength => _textLength;
  int get wordCount => _wordCount;
  String get selectedLanguage => _selectedLanguage;

  // Get available languages for the UI
  Map<String, String> get availableLanguages => {
        'en': 'English',
        'it': 'Italian',
        'fr': 'French',
        'de': 'German',
        'es': 'Spanish',
        'pt': 'Portuguese',
        'nl': 'Dutch',
      };

  void setGeneratorType(GeneratorTypes type) {
    if (_generatorType != type) {
      _generatorType = type;
      notifyListeners();
    }
  }

  void setPassword(String newPassword) {
    if (_password != newPassword) {
      _password = newPassword;
      notifyListeners();
    }
  }

  void setTextLength(int length) {
    if (_textLength != length && length >= 5 && length <= 20) {
      _textLength = length;
      notifyListeners();
    }
  }

  void setWordCount(int count) {
    if (_wordCount != count && count >= 1 && count <= 4) {
      _wordCount = count;
      notifyListeners();
    }
  }

  void setSelectedLanguage(String language) {
    if (_selectedLanguage != language && _languageMap.containsKey(language)) {
      _selectedLanguage = language;
      // Clear existing words so they get repopulated with new language
      _words.clear();
      notifyListeners();
    }
  }

  String _generateGuid() {
    final random = Random();
    final chars = '0123456789abcdef';

    String generateSegment(int length) {
      return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
    }

    return '${generateSegment(8)}-${generateSegment(4)}-${generateSegment(4)}-${generateSegment(4)}-${generateSegment(12)}';
  }

  String _generateTextPassword() {
    final random = Random();
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const digits = '0123456789';
    const special = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    final allChars = lowercase + uppercase + digits + special;
    final passwordLength = _textLength;

    // Ensure at least one character from each category if length allows
    String password = '';
    if (passwordLength >= 4) {
      password += lowercase[random.nextInt(lowercase.length)];
      password += uppercase[random.nextInt(uppercase.length)];
      password += digits[random.nextInt(digits.length)];
      password += special[random.nextInt(special.length)];
    }

    // Fill the rest with random characters
    for (int i = password.length; i < passwordLength; i++) {
      password += allChars[random.nextInt(allChars.length)];
    }

    // Shuffle the password to randomize the order
    List<String> passwordList = password.split('');
    passwordList.shuffle(random);

    return passwordList.join();
  }

  String _generateNumericPassword() {
    final random = Random();
    const digits = '0123456789';
    final passwordLength = _textLength;

    String password = '';
    for (int i = 0; i < passwordLength; i++) {
      password += digits[random.nextInt(digits.length)];
    }

    return password;
  }

  Future<String> _generateWikiWordPassword() async {
    // Populate words from API when starting (only if not already populated)
    if (_words.isEmpty) {
      await _populateWordsFromAPI();
    }

    final random = Random();

    final specialChars = ['!', '@', '#', '\$', '%', '&', '*', '+', '=', '?'];
    final separators = ['', '-', '_', ' '];

    // Use the user-selected word count
    List<String> selectedWords = [];

    for (int i = 0; i < _wordCount; i++) {
      String word = _words[random.nextInt(_words.length)];

      // Random capitalization for each word
      int capitalizationType = random.nextInt(3);
      switch (capitalizationType) {
        case 0: // all lowercase
          word = word.toLowerCase();
          break;
        case 1: // first char only uppercase
          word = word[0].toUpperCase() + word.substring(1).toLowerCase();
          break;
        case 2: // all uppercase
          word = word.toUpperCase();
          break;
      }

      selectedWords.add(word);
    }

    // Random word separator
    String separator = separators[random.nextInt(separators.length)];
    String wordsText = selectedWords.join(separator);

    // Generate random number (1-999)
    int number = random.nextInt(999) + 1;
    String numberText = number.toString();

    // Randomly decide number position (true = beginning, false = end)
    bool numberAtBegin = random.nextBool();

    // Random special character
    String specialChar = specialChars[random.nextInt(specialChars.length)];

    // Randomly decide special character position (true = beginning, false = end)
    bool specialAtBegin = random.nextBool();

    // Build the password
    String password = '';

    if (specialAtBegin) {
      password += specialChar;
    }

    if (numberAtBegin) {
      password += numberText + (separator.isEmpty ? '' : separator) + wordsText;
    } else {
      password += wordsText + (separator.isEmpty ? '' : separator) + numberText;
    }

    if (!specialAtBegin) {
      password += specialChar;
    }

    return password;
  }

  Future<List<String>> _wikiPopulate(String language, int size) async {
    try {
      // Default to English if language not supported
      String languageEntityId = _languageMap[language] ?? 'Q1860';

      // Construct SPARQL query for random lexical entries
      String sparqlQuery = '''
        SELECT ?lemma ?lemmaLabel
        WHERE {
          ?lemma a ontolex:LexicalEntry ;
                 dct:language wd:$languageEntityId ;
                 wikibase:lemma ?lemmaLabel .
        }
        ORDER BY RAND()
        LIMIT $size
      ''';

      // Construct the SPARQL endpoint URL with query parameter
      final url = Uri.https('query.wikidata.org', '/sparql', {
        'query': sparqlQuery,
      });

      // Make the HTTP request with proper headers
      final response = await http.get(url, headers: {
        'Accept': 'application/sparql-results+json',
        'User-Agent': 'BlastApp/1.0 (password generator)',
      });

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> bindings = data['results']['bindings'];

        // Extract lemmas and clean them for use as words
        List<String> words = [];
        for (var binding in bindings) {
          if (binding['lemmaLabel'] != null && binding['lemmaLabel']['value'] != null) {
            String lemma = binding['lemmaLabel']['value'] as String;

            // Clean the lemma - remove special characters, spaces, etc.
            // First normalize accents and special characters to ASCII
            lemma = _normalizeToAscii(lemma);
            // Then keep only alphabetic characters and make it a single word
            lemma = lemma.replaceAll(RegExp(r'[^a-zA-Z]'), '');

            // Only add if it's a reasonable word (3+ characters, not empty)
            if (lemma.isNotEmpty && lemma.length >= 3 && lemma.length <= 12) {
              // Capitalize first letter
              lemma = lemma[0].toUpperCase() + lemma.substring(1).toLowerCase();
              words.add(lemma);
            }
          }
        }

        return words;
      } else {
        debugPrint('Wikidata SPARQL API error: ${response.statusCode} - ${response.body}');
        // Fallback if API fails
        return _getFallbackWords();
      }
    } catch (e) {
      // Fallback if network error or parsing fails
      debugPrint('Wikidata SPARQL API error: $e');
      return _getFallbackWords();
    }
  }

  /// Normalizes accented and special characters to their ASCII equivalents
  String _normalizeToAscii(String text) {
    // Map of accented characters to their ASCII equivalents
    const accentMap = {
      'À': 'A',
      'Á': 'A',
      'Â': 'A',
      'Ã': 'A',
      'Ä': 'A',
      'Å': 'A',
      'Æ': 'AE',
      'Ç': 'C',
      'È': 'E',
      'É': 'E',
      'Ê': 'E',
      'Ë': 'E',
      'Ì': 'I',
      'Í': 'I',
      'Î': 'I',
      'Ï': 'I',
      'Ð': 'D',
      'Ñ': 'N',
      'Ò': 'O',
      'Ó': 'O',
      'Ô': 'O',
      'Õ': 'O',
      'Ö': 'O',
      'Ø': 'O',
      'Ù': 'U',
      'Ú': 'U',
      'Û': 'U',
      'Ü': 'U',
      'Ý': 'Y',
      'Þ': 'TH',
      'ß': 'ss',
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'å': 'a',
      'æ': 'ae',
      'ç': 'c',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'ì': 'i',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'ð': 'd',
      'ñ': 'n',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ø': 'o',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ü': 'u',
      'ý': 'y',
      'þ': 'th',
      'ÿ': 'y'
    };

    String result = text;
    accentMap.forEach((accented, ascii) {
      result = result.replaceAll(accented, ascii);
    });
    return result;
  }

  List<String> _getFallbackWords() {
    final fallbackWords = ['unable', 'to', 'connect', 'wikidata', 'api'];
    return fallbackWords;
  }

  Future<void> _populateWordsFromAPI() async {
    try {
      // Fetch a larger set of words (50) from Wikidata SPARQL API using selected language
      _words = await _wikiPopulate(_selectedLanguage, 50);
      debugPrint(
          'Successfully populated ${_words.length} words from Wikidata SPARQL API (language: $_selectedLanguage)');
    } catch (e) {
      debugPrint('Failed to populate words from API: $e');
      // _words remains empty, fallback will be used in generator
    }
  }

  Future<void> _startBackgroundProcess() async {
    _isRunning = true;

    _backgroundTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (!_isRunning) {
        timer.cancel();
        return;
      }
      // Background process logic goes here
      // This runs every 500ms
      await refreshPassword();
      debugPrint('Background process tick: ${DateTime.now()}');
    });
  }

  void _stopBackgroundProcess() {
    _isRunning = false;
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
  }

  void startGenerator() {
    if (!_isRunning) {
      _startBackgroundProcess();
      notifyListeners();
    }
  }

  void stopGenerator() {
    if (_isRunning) {
      _stopBackgroundProcess();
      notifyListeners();
    }
  }

  Future<void> refreshPassword() async {
    // Generate a single new password based on current generator type
    if (_generatorType == GeneratorTypes.guid) {
      setPassword(_generateGuid());
    } else if (_generatorType == GeneratorTypes.text) {
      setPassword(_generateTextPassword());
    } else if (_generatorType == GeneratorTypes.numeric) {
      setPassword(_generateNumericPassword());
    } else if (_generatorType == GeneratorTypes.wikiword) {
      setPassword(await _generateWikiWordPassword());
    }
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _password));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void closeCommand() {
    _stopBackgroundProcess();
    context.router.maybePop();
  }

  @override
  void dispose() {
    _stopBackgroundProcess();
    super.dispose();
  }
}

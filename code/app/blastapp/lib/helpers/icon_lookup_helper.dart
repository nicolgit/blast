import 'package:http/http.dart' as http;

class BrandInfo {
  final String brandName;
  final String brandSlug;

  const BrandInfo(this.brandName, this.brandSlug);

  String get url => 'https://cdn.simpleicons.org/$brandSlug/white';
  String get urlDark => 'https://cdn.simpleicons.org/$brandSlug/black';
}

class IconLookupHelper {
  static final IconLookupHelper _instance = IconLookupHelper._internal();

  factory IconLookupHelper() {
    return _instance;
  }

  IconLookupHelper._internal();

  List<BrandInfo> _brands = [];
  bool _isLoaded = false;

  String _extractBetweenBackticks(String text) {
    final startIndex = text.indexOf('`');
    if (startIndex == -1) return '';

    final endIndex = text.indexOf('`', startIndex + 1);
    if (endIndex == -1) return '';

    return text.substring(startIndex + 1, endIndex);
  }

  Future<void> _loadBrands() async {
    if (_isLoaded) return;

    try {
      final response = await http.get(
        Uri.parse('https://raw.githubusercontent.com/simple-icons/simple-icons/refs/heads/develop/slugs.md'),
      );

      if (response.statusCode == 200) {
        final lines = response.body.split('\n');
        final brandList = <BrandInfo>[];

        for (var line in lines) {
          line = line.trim();
          if (line.isEmpty || !line.startsWith('|')) {
            continue;
          }

          final parts = line.split('|').map((e) => e.trim()).toList();
          if (parts.length == 4 && parts[1].isNotEmpty && parts[2].isNotEmpty) {
            final brandName = _extractBetweenBackticks(parts[1]);
            final brandSlug = _extractBetweenBackticks(parts[2]);
            if (brandName.isNotEmpty && brandSlug.isNotEmpty) {
              brandList.add(BrandInfo(brandName, brandSlug));
            }
          }
        }

        _brands = brandList;
        _isLoaded = true;
      }
    } catch (e) {
      // Handle error silently, keep empty list
      _isLoaded = true;
    }
  }

  Future<List<BrandInfo>> get brands async {
    await _loadBrands();
    return _brands;
  }

  static Future<List<BrandInfo>> search(String text) async {
    final instance = IconLookupHelper();
    await instance._loadBrands();

    final searchText = text.toLowerCase();
    final results = <BrandInfo>[];

    for (var brand in instance._brands) {
      if (brand.brandName.toLowerCase().contains(searchText) || brand.brandSlug.toLowerCase().contains(searchText)) {
        results.add(brand);
      }
    }

    return results;
  }
}

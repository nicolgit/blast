import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/change_icon_viewmodel.dart';
import 'package:blastapp/helpers/icon_lookup_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

@RoutePage()
class ChangeIconView extends StatefulWidget {
  const ChangeIconView({super.key});

  @override
  State<ChangeIconView> createState() => _ChangeIconViewState();
}

class _ChangeIconViewState extends State<ChangeIconView> {
  final TextEditingController _searchController = TextEditingController();
  List<BrandInfo> _allBrands = [];
  List<BrandInfo> _filteredBrands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBrands();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBrands() async {
    final brands = await IconLookupHelper().brands;
    setState(() {
      _allBrands = brands;
      _filteredBrands = brands;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBrands = _allBrands;
      } else {
        _filteredBrands = _allBrands
            .where((brand) =>
                brand.brandName.toLowerCase().contains(query) || brand.brandSlug.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChangeIconViewModel(context),
      child: Consumer<ChangeIconViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  late ThemeData _theme;

  Widget _buildScaffold(BuildContext context, ChangeIconViewModel vm) {
    _theme = Theme.of(context);

    return Container(
        color: _theme.colorScheme.surface,
        child: SafeArea(
            child: Scaffold(
                backgroundColor: _theme.colorScheme.surface,
                body: Column(children: [
                  AppBar(
                    title: const Text("Change Icon"),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Close',
                        onPressed: () => vm.closeCommand(),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      style: _theme.textTheme.bodyMedium?.copyWith(
                        color: _theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search icons...',
                        hintStyle: _theme.textTheme.bodyMedium?.copyWith(
                          color: _theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(Icons.search, color: _theme.colorScheme.onSurface),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: _theme.colorScheme.onSurface),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: _theme.colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: _theme.colorScheme.primary, width: 2.0),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredBrands.isEmpty
                            ? Center(
                                child: Text(
                                  'No icons found',
                                  style: _theme.textTheme.bodyMedium?.copyWith(
                                    color: _theme.colorScheme.onSurface,
                                  ),
                                ),
                              )
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  final crossAxisCount = (constraints.maxWidth / 180).floor().clamp(2, 10);
                                  return GridView.builder(
                                    padding: const EdgeInsets.all(16.0),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 16.0,
                                      mainAxisSpacing: 16.0,
                                      childAspectRatio: 0.8,
                                    ),
                                    itemCount: _filteredBrands.length,
                                    itemBuilder: (context, index) {
                                      final brand = _filteredBrands[index];
                                      return _buildIconCard(brand, vm);
                                    },
                                  );
                                },
                              ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Icons from simpleicons.org',
                      style: _theme.textTheme.bodySmall?.copyWith(
                        color: _theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ]))));
  }

  Widget _buildIconCard(BrandInfo brand, ChangeIconViewModel vm) {
    final iconUrl = _theme.brightness == Brightness.dark ? brand.urlDark : brand.url;

    return InkWell(
      onTap: () => vm.selectIcon(brand.brandSlug),
      child: Card(
        elevation: 2,
        color: _theme.colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 128,
                height: 128,
                child: FutureBuilder<String?>(
                  future: _fetchSvgData(iconUrl),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                      return Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: _theme.colorScheme.onSurface.withOpacity(0.3),
                      );
                    }

                    return SvgPicture.string(
                      snapshot.data!,
                      fit: BoxFit.contain,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                brand.brandName,
                style: _theme.textTheme.bodySmall?.copyWith(
                  color: _theme.colorScheme.onPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _fetchSvgData(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('Timeout'),
          );

      if (response.statusCode == 200) {
        return response.body;
      }
      return null;
    } catch (e) {
      // Silently handle network errors
      return null;
    }
  }
}

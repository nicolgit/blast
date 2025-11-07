import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/choose_storage_viewmodel.dart';
import 'package:blastapp/blastwidget/blast_widgetfactory.dart';
import 'package:blastmodel/Cloud/cloud.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ChooseStorageView extends StatefulWidget {
  const ChooseStorageView({super.key});

  @override
  State<StatefulWidget> createState() => _ChooseStorageViewState();
}

class _ChooseStorageViewState extends State<ChooseStorageView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChooseStorageViewModel(context),
      child: Consumer<ChooseStorageViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  late BlastWidgetFactory _widgetFactory;

  Widget _buildScaffold(BuildContext context, ChooseStorageViewModel vm) {
    _widgetFactory = BlastWidgetFactory(context);

    return Container(
        color: _widgetFactory.theme.colorScheme.surface,
        child: SafeArea(
            child: Scaffold(
          backgroundColor: _widgetFactory.theme.colorScheme.surface,
          body: Column(
            children: [
              AppBar(
                title: const Text("Choose the storage for your Blast file"),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Center(
                    child: FutureBuilder<List<Cloud>>(
                      future: vm.supportedClouds(),
                      builder: (context, cloudList) {
                        return Container(
                            constraints: BoxConstraints(maxWidth: 600),
                            child: _buildCloudList(cloudList.data ?? [], vm));
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        )));
  }

  Widget _buildCloudList(List<Cloud> cloudList, ChooseStorageViewModel vm) {
    if (cloudList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 64,
              color: _widgetFactory.theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "No storage providers available",
              style: _widgetFactory.textTheme.titleMedium?.copyWith(
                color: _widgetFactory.theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Text(
            "Select your preferred cloud storage",
            style: _widgetFactory.textTheme.titleSmall?.copyWith(
              color: _widgetFactory.theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
        ...cloudList.asMap().entries.map((entry) {
          final index = entry.key;
          final cloud = entry.value;

          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Material(
                borderRadius: BorderRadius.circular(16),
                elevation: 0,
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _widgetFactory.theme.colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _widgetFactory.theme.colorScheme.surface,
                        _widgetFactory.theme.colorScheme.surface.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => vm.goToChooseFile(cloud),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Cloud provider icon with modern styling
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: _widgetFactory.theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                              border: Border.all(
                                color: _widgetFactory.theme.colorScheme.primary.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Image.asset(
                                "assets/storage/${cloud.id}.png",
                                width: 40,
                                height: 40,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.cloud,
                                    size: 32,
                                    color: _widgetFactory.theme.colorScheme.primary,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Cloud provider details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cloud.name,
                                  style: _widgetFactory.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _widgetFactory.theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  cloud.description,
                                  style: _widgetFactory.textTheme.bodyMedium?.copyWith(
                                    color: _widgetFactory.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Modern arrow indicator
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: _widgetFactory.theme.colorScheme.primary.withValues(alpha: 0.1),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: _widgetFactory.theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }
}

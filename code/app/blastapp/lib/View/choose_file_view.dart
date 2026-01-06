import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/choose_file_viewmodel.dart';
import 'package:blastapp/blastwidget/blast_widgetfactory.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ChooseFileView extends StatefulWidget {
  const ChooseFileView({super.key});

  @override
  State<StatefulWidget> createState() => _ChooseFileViewState();
}

class _ChooseFileViewState extends State<ChooseFileView> {
  _ChooseFileViewState();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChooseFileViewModel(context),
      child: Consumer<ChooseFileViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  late BlastWidgetFactory _widgetFactory;

  Widget _buildScaffold(BuildContext context, ChooseFileViewModel vm) {
    _widgetFactory = BlastWidgetFactory(context);

    return Container(
        color: _widgetFactory.theme.colorScheme.surface,
        child: SafeArea(
            child: Scaffold(
                backgroundColor: _widgetFactory.theme.colorScheme.surface,
                floatingActionButton: Tooltip(
                    message: 'create a new file',
                    textStyle: _widgetFactory.textTooltip.labelSmall,
                    child: FloatingActionButton(
                      onPressed: () {
                        vm.newFileCommand();
                      },
                      child: const Icon(Icons.note_add),
                    )),
                body: Center(
                  child: Column(
                    children: [
                      AppBar(
                        title: const Text("Choose a file"),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: ElevatedButton.icon(
                                onPressed: () {
                                  vm.upDirectoryCommand();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _widgetFactory.theme.colorScheme.primary,
                                  foregroundColor: _widgetFactory.theme.colorScheme.onPrimary,
                                ),
                                icon: Icon(
                                  Icons.drive_folder_upload,
                                  size: 24,
                                ),
                                label: Text('go up')),
                          ),
                          if (vm.shouldShowGoToFolderButton)
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: FutureBuilder<String>(
                                  future: vm.currentPath,
                                  builder: (context, currentPath) {
                                    return Tooltip(
                                        message: 'go to folder',
                                        textStyle: _widgetFactory.textTooltip.labelSmall,
                                        child: ElevatedButton.icon(
                                            onPressed: () {
                                              vm.goToFolderCommand();
                                            },
                                            style: IconButton.styleFrom(
                                              backgroundColor: _widgetFactory.theme.colorScheme.primary,
                                              foregroundColor: _widgetFactory.theme.colorScheme.onPrimary,
                                            ),
                                            icon: Icon(
                                              Icons.folder_open,
                                              size: 20,
                                              color: _widgetFactory.theme.colorScheme.onPrimary,
                                            ),
                                            label: Text('go to folder')));
                                  }),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: FutureBuilder<String>(
                                future: vm.currentPath,
                                builder: (context, currentPath) {
                                  return Tooltip(
                                      message: 'copy current path to clipboard',
                                      textStyle: _widgetFactory.textTooltip.labelSmall,
                                      child: IconButton(
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(text: currentPath.data ?? ""));
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                content: Text("current path copied to clipboard!",
                                                    style: _widgetFactory.textTooltip.labelSmall)));
                                          },
                                          style: IconButton.styleFrom(
                                            backgroundColor: _widgetFactory.theme.colorScheme.secondary,
                                            foregroundColor: _widgetFactory.theme.colorScheme.onSecondary,
                                          ),
                                          icon: Icon(
                                            Icons.copy,
                                            size: 20,
                                            color: _widgetFactory.theme.colorScheme.onSecondary,
                                          )));
                                }),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: FutureBuilder<String>(
                                future: vm.currentPath,
                                builder: (context, currentPath) => Text(
                                  currentPath.data ?? "",
                                  style: _widgetFactory.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      FutureBuilder<List<CloudObject>>(
                          future: vm.getFiles(),
                          builder: (context, listFiles) {
                            return Expanded(
                              child: Container(
                                child: _buildfileList(listFiles.data ?? [], vm),
                              ),
                            );
                          }),
                    ],
                  ),
                ))));
  }

  Widget _buildfileList(List<CloudObject> listFiles, ChooseFileViewModel vm) {
    if (vm.isLoading) {
      context.loaderOverlay.show();
    } else {
      context.loaderOverlay.hide();
    }

    if (listFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 64,
              color: _widgetFactory.theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              "No files found",
              style: _widgetFactory.textTheme.headlineSmall?.copyWith(
                color: _widgetFactory.theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This folder is empty",
              style: _widgetFactory.textTheme.bodyMedium?.copyWith(
                color: _widgetFactory.theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 800, // Maximum width per item
        crossAxisSpacing: 16,
        mainAxisSpacing: 12,
        mainAxisExtent: 120, // Dynamic height that scales with content
      ),
      itemCount: listFiles.length,
      itemBuilder: (context, index) {
        return _buildModernFileItem(listFiles[index], vm, index);
      },
    );
  }

  Widget _buildModernFileItem(CloudObject fileObject, ChooseFileViewModel vm, int index) {
    String name = fileObject.name;
    String path = fileObject.path;
    bool isDirectory = fileObject.isDirectory;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            // Add haptic feedback
            HapticFeedback.lightImpact();

            await vm.selectItem(fileObject).catchError((error) {
              String errorMessage = "Unable to open selected file: ${error.toString()}";

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: _widgetFactory.theme.colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            });
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: _widgetFactory.theme.colorScheme.surfaceContainerLow,
              border: Border.all(
                color: _widgetFactory.theme.colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Modern icon container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _getIconBackgroundColor(fileObject),
                  ),
                  child: Center(
                    child: _getModernIcon(fileObject),
                  ),
                ),
                const SizedBox(width: 16),
                // File info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: _widgetFactory.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _widgetFactory.theme.colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isDirectory ? Icons.folder_outlined : Icons.description_outlined,
                            size: 14,
                            color: _widgetFactory.theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              path,
                              style: _widgetFactory.textTheme.bodySmall?.copyWith(
                                color: _widgetFactory.theme.colorScheme.outline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (!isDirectory) ...[
                        const SizedBox(height: 4),
                        _buildFileTypeChip(fileObject),
                      ],
                    ],
                  ),
                ),
                // Arrow indicator
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _widgetFactory.theme.colorScheme.surfaceContainerHigh,
                  ),
                  child: Icon(
                    isDirectory ? Icons.arrow_forward_ios : Icons.open_in_new,
                    size: 16,
                    color: _widgetFactory.theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getModernIcon(CloudObject fileObject) {
    if (fileObject.isDirectory) {
      return Icon(
        Icons.folder_rounded,
        size: 28,
        color: _widgetFactory.theme.colorScheme.primary,
      );
    } else {
      if (fileObject.name.endsWith(".blast")) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            "assets/general/app-icon.png",
            width: 28,
            height: 28,
            fit: BoxFit.cover,
          ),
        );
      } else {
        return Icon(
          Icons.description_rounded,
          size: 28,
          color: _widgetFactory.theme.colorScheme.secondary,
        );
      }
    }
  }

  Color _getIconBackgroundColor(CloudObject fileObject) {
    if (fileObject.isDirectory) {
      return _widgetFactory.theme.colorScheme.primaryContainer;
    } else if (fileObject.name.endsWith(".blast")) {
      return _widgetFactory.theme.colorScheme.tertiaryContainer;
    } else {
      return _widgetFactory.theme.colorScheme.secondaryContainer;
    }
  }

  Widget _buildFileTypeChip(CloudObject fileObject) {
    String extension = fileObject.name.split('.').last.toUpperCase();
    if (extension == fileObject.name.toUpperCase()) {
      extension = "FILE";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: _widgetFactory.theme.colorScheme.surfaceContainerHighest,
      ),
      child: Text(
        extension,
        style: _widgetFactory.textTheme.labelSmall?.copyWith(
          color: _widgetFactory.theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

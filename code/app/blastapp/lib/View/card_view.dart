import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/card_viewmodel.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastapp/blastwidget/blast_markdown_text.dart';
import 'package:blastapp/blastwidget/blast_widgetfactory.dart';
import 'package:blastapp/blastwidget/blast_attribute_row.dart';
import 'package:blastapp/blastwidget/file_changed_banner.dart';
import 'package:blastapp/helpers/blast_attribute_edit_dialogs.dart';
import 'package:blastapp/helpers/notes_input_dialog.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:blastapp/blastwidget/blast_card_icon.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:humanizer/humanizer.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; //for date formate locale

@RoutePage()
class CardView extends StatefulWidget {
  const CardView({super.key, required this.card});
  final BlastCard card;

  @override
  State<StatefulWidget> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  @override
  Widget build(BuildContext context) {
    final card = widget.card; // this is the card passed in from the CardsBrowserView

    return ChangeNotifierProvider(
      create: (context) => CardViewModel(context, card),
      child: Consumer<CardViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  late BlastWidgetFactory _widgetFactory;

  Widget _buildScaffold(BuildContext context, CardViewModel vm) {
    _widgetFactory = BlastWidgetFactory(context);
    //_theme = Theme.of(context);
    //_textTheme = _theme.textTheme.apply(bodyColor: _theme.colorScheme.onSurface);

    return SafeArea(
        child: Scaffold(
            backgroundColor: _widgetFactory.viewBackgroundColor(),
            appBar: AppBar(
              title: Text(vm.currentCard.title != null ? vm.currentCard.title! : "No Title"),
              actions: [
                Row(
                  children: [
                    const Text('Edit Mode'),
                    Switch(
                      value: vm.editMode,
                      onChanged: (value) {
                        vm.toggleEditMode(value);
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'advanced edit',
                  style: IconButton.styleFrom(
                    backgroundColor: _widgetFactory.theme.colorScheme.tertiaryContainer,
                    foregroundColor: _widgetFactory.theme.colorScheme.onTertiaryContainer,
                    side: BorderSide(color: _widgetFactory.theme.colorScheme.primary),
                  ),
                  onPressed: () {
                    vm.editCommand();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Quit',
                  onPressed: () {
                    vm.closeCommand();
                  },
                ),
              ],
            ),
            body: Column(children: [
              Expanded(
                  child: SingleChildScrollView(
                      child: Center(
                          child: Column(children: [
                const SizedBox(height: 16),
                if (vm.editMode)
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      BlastCardIcon(card: vm.currentCard, size: 128),
                      Positioned(
                        right: -12,
                        bottom: -12,
                        child: Tooltip(
                          message: 'Change icon',
                          child: GestureDetector(
                            onTap: () => vm.changeDocumentIcon(),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _widgetFactory.theme.colorScheme.tertiaryContainer,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _widgetFactory.theme.colorScheme.outline,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 36,
                                color: _widgetFactory.theme.colorScheme.onTertiaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  BlastCardIcon(card: vm.currentCard, size: 128),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        icon: vm.currentCard.isFavorite
                            ? Icon(
                                Icons.star,
                                color: Colors.amber,
                              )
                            : Icon(Icons.star_border, color: _widgetFactory.theme.colorScheme.primary),
                        tooltip: "toggle favorite",
                        onPressed: () {
                          vm.toggleFavorite();
                        }),
                    Center(
                        child: Text(vm.currentCard.title != null ? vm.currentCard.title! : "",
                            textAlign: TextAlign.center,
                            style: _widgetFactory.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold))),
                    const SizedBox(width: 6),
                    if (vm.editMode)
                      IconButton.outlined(
                        icon: const Icon(Icons.edit, size: 18),
                        tooltip: 'Edit title',
                        style: IconButton.styleFrom(
                          backgroundColor: _widgetFactory.theme.colorScheme.tertiaryContainer,
                          foregroundColor: _widgetFactory.theme.colorScheme.onTertiaryContainer,
                          side: BorderSide(color: _widgetFactory.theme.colorScheme.primary),
                        ),
                        onPressed: () async {
                          final controller = TextEditingController(text: vm.currentCard.title ?? "");
                          final newTitle = await showDialog<String>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Edit title',
                                  style: _widgetFactory.textTheme.headlineSmall!
                                      .copyWith(color: _widgetFactory.theme.colorScheme.onSurface)),
                              content: TextField(
                                controller: controller,
                                autofocus: true,
                                style: _widgetFactory.textTheme.bodyMedium!
                                    .copyWith(color: _widgetFactory.theme.colorScheme.onSurface),
                                decoration: const InputDecoration(hintText: 'Card title'),
                                onSubmitted: (value) => Navigator.pop(context, value),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, controller.text),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          if (newTitle != null) {
                            vm.updateTitle(newTitle);
                          }
                        },
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: ValueListenableBuilder<int>(
                    valueListenable: vm.timeTextNotifier,
                    builder: (context, _, __) => Text(
                      "updated on ${DateFormat.yMMMEd().format(vm.currentCard.lastUpdateDateTime)}, used ${vm.currentCard.usedCounter} times, last time ${vm.currentCard.lastUpdateDateTime.difference(DateTime.now()).toApproximateTime()}",
                      style: _widgetFactory.textTheme.labelSmall,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _rowOfTags(vm.currentCard.tags, vm),
                const SizedBox(height: 12),
                FutureBuilder<List<BlastAttribute>>(
                    future: vm.getRows(),
                    builder: (context, cardsList) {
                      return Container(
                        child: _buildAttributesList(cardsList.data ?? [], vm),
                      );
                    }),
              ])))),
              FileChangedBanner(
                isFileChangedFuture: vm.isFileChangedAsync(),
                onSavePressed: () async {
                  if (await vm.saveCommand()) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("file saved successfully!"),
                      ));
                    }
                  }
                },
              ),
            ])));
  }

  Column _buildAttributesList(List<BlastAttribute> cardsList, CardViewModel vm) {
    BlastAttributeRow buildRow(int index) => BlastAttributeRow(
          key: ValueKey(cardsList[index]),
          attribute: cardsList[index],
          index: index,
          toggleShowPassword: vm.toggleShowPassword,
          isPasswordRowVisible: vm.isPasswordRowVisible,
          copyToClipboard: vm.copyToClipboard,
          showFieldView: vm.showFieldView,
          openUrl: vm.openUrl,
          editMode: vm.editMode,
          editField: (attribute) {
            if (attribute.type == BlastAttributeType.typeHeader) {
              BlastAttributeEditDialogs.showEditHeaderDialog(context, attribute, vm);
            } else if (attribute.type == BlastAttributeType.typePassword) {
              BlastAttributeEditDialogs.showEditPasswordFieldDialog(context, attribute, vm);
            } else {
              BlastAttributeEditDialogs.showEditFieldDialog(context, attribute, vm);
            }
          },
          deleteField: (attribute) {
            BlastAttributeEditDialogs.showDeleteFieldDialog(context, attribute, vm);
          },
          generatePassword: (attribute) async {
            final String? generated =
                await context.router.push(PasswordGeneratorRoute(allowCopyToClipboard: false, returnsValue: true));
            if (generated != null && generated.isNotEmpty) {
              vm.setGeneratedPassword(attribute, generated);
            }
          },
        );

    final Widget rowsWidget = vm.editMode
        ? ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: vm.reorderAttributes,
            children: [
              for (int i = 0; i < cardsList.length; i++) buildRow(i),
            ],
          )
        : Column(
            children: [
              for (int i = 0; i < cardsList.length; i++) buildRow(i),
            ],
          );

    final List<Widget> extras = [];

    if (vm.editMode) {
      extras.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Wrap(
          spacing: 8,
          alignment: WrapAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                final attr = BlastAttribute.withParams('+Field', '', BlastAttributeType.typeString);
                vm.addAttribute(attr);
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: _widgetFactory.theme.colorScheme.tertiaryContainer,
                foregroundColor: _widgetFactory.theme.colorScheme.onTertiaryContainer,
                side: BorderSide(color: _widgetFactory.theme.colorScheme.primary),
              ),
              icon: const Icon(Icons.description, size: 16),
              label: const Text('Value'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                final attr = BlastAttribute.withParams('+Password', '', BlastAttributeType.typePassword);
                vm.addAttribute(attr);
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: _widgetFactory.theme.colorScheme.tertiaryContainer,
                foregroundColor: _widgetFactory.theme.colorScheme.onTertiaryContainer,
                side: BorderSide(color: _widgetFactory.theme.colorScheme.primary),
              ),
              icon: const Icon(Icons.lock, size: 16),
              label: const Text('Password'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                final attr = BlastAttribute.withParams('+Title', '', BlastAttributeType.typeHeader);
                vm.addAttribute(attr);
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: _widgetFactory.theme.colorScheme.tertiaryContainer,
                foregroundColor: _widgetFactory.theme.colorScheme.onTertiaryContainer,
                side: BorderSide(color: _widgetFactory.theme.colorScheme.primary),
              ),
              icon: const Icon(Icons.title, size: 16),
              label: const Text('Title'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                final attr = BlastAttribute.withParams('+URL', '', BlastAttributeType.typeURL);
                vm.addAttribute(attr);
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: _widgetFactory.theme.colorScheme.tertiaryContainer,
                foregroundColor: _widgetFactory.theme.colorScheme.onTertiaryContainer,
                side: BorderSide(color: _widgetFactory.theme.colorScheme.primary),
              ),
              icon: const Icon(Icons.link, size: 16),
              label: const Text('URL'),
            ),
          ],
        ),
      ));
    }

    if (vm.currentCard.notes != null) {
      extras.add(_showNotes(vm.currentCard.notes!, vm));
    }

    extras.add(Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FilledButton.icon(
        onPressed: () => vm.showJsonDataDialog(context),
        style: FilledButton.styleFrom(
          backgroundColor: _widgetFactory.theme.colorScheme.primaryContainer,
          foregroundColor: _widgetFactory.theme.colorScheme.onPrimaryContainer,
        ),
        icon: const Icon(Icons.data_object),
        label: const Text('JSON data'),
      ),
    ));

    return Column(children: [rowsWidget, ...extras]);
  }

  Widget _rowOfTags(List<String> tags, CardViewModel vm) {
    List<Widget> rowItems = [];
    for (var tag in tags) {
      rowItems.add(_widgetFactory.blastTag(tag));
    }

    final noTagsPlaceholder = tags.isEmpty
        ? Text(
            '(no tags)',
            style: _widgetFactory.textTheme.bodyMedium!.copyWith(
              fontStyle: FontStyle.italic,
              color: _widgetFactory.theme.colorScheme.onSurface,
            ),
          )
        : null;

    final wrap = tags.isEmpty
        ? (noTagsPlaceholder ?? const SizedBox.shrink())
        : Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            alignment: WrapAlignment.center,
            children: rowItems,
          );

    if (!vm.editMode) return wrap;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: wrap),
        const SizedBox(width: 6),
        IconButton.outlined(
          icon: const Icon(Icons.edit, size: 18),
          tooltip: 'Edit tags',
          style: IconButton.styleFrom(
            backgroundColor: _widgetFactory.theme.colorScheme.tertiaryContainer,
            foregroundColor: _widgetFactory.theme.colorScheme.onTertiaryContainer,
            side: BorderSide(color: _widgetFactory.theme.colorScheme.primary),
          ),
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (ctx) => MultiSelectDialog(
                title: Text('Select tags',
                    style: _widgetFactory.textTheme.headlineMedium!
                        .copyWith(color: _widgetFactory.theme.colorScheme.onPrimaryContainer)),
                items: vm.allTags.map((e) => MultiSelectItem(e, e)).toList(),
                initialValue: vm.currentCard.tags,
                onConfirm: (values) {
                  vm.updateTags(List<String>.from(values));
                },
                listType: MultiSelectListType.CHIP,
                selectedColor: _widgetFactory.theme.colorScheme.primary,
                unselectedColor: _widgetFactory.theme.colorScheme.surface,
                selectedItemsTextStyle:
                    _widgetFactory.textTheme.labelSmall!.copyWith(color: _widgetFactory.theme.colorScheme.onPrimary),
              ),
            );
          },
        ),
        const SizedBox(width: 6),
        IconButton.outlined(
          icon: const Icon(Icons.add, size: 18),
          tooltip: 'Add custom tag',
          style: IconButton.styleFrom(
            backgroundColor: _widgetFactory.theme.colorScheme.tertiaryContainer,
            foregroundColor: _widgetFactory.theme.colorScheme.onTertiaryContainer,
            side: BorderSide(color: _widgetFactory.theme.colorScheme.primary),
          ),
          onPressed: () async {
            final controller = TextEditingController();
            final newTag = await showDialog<String>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('Add custom tag', style: TextStyle(color: _widgetFactory.theme.colorScheme.onSurface)),
                content: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Tag name'),
                  onSubmitted: (value) => Navigator.of(ctx).pop(value),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(controller.text),
                    child: const Text('Add'),
                  ),
                ],
              ),
            );
            if (newTag != null && newTag.trim().isNotEmpty) {
              final updatedTags = [...vm.currentCard.tags, newTag.trim()];
              vm.updateTags(updatedTags);
            }
          },
        ),
      ],
    );
  }

  Widget _showNotes(String notes, CardViewModel vm) {
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
            child: Container(
                constraints: const BoxConstraints(maxWidth: 600, minWidth: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: _widgetFactory.theme.colorScheme.secondaryContainer,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(vm.editMode ? "Notes (some markdown is ok)" : "Notes",
                            style: _widgetFactory.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        if (!vm.editMode)
                          IconButton(
                            icon: Icon(Icons.copy, size: 18, color: _widgetFactory.theme.colorScheme.primary),
                            tooltip: 'Copy notes to clipboard',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: notes));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Notes copied to clipboard!"),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        if (vm.editMode)
                          Padding(
                            padding: const EdgeInsets.all(3),
                            child: IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              tooltip: 'Edit notes',
                              style: IconButton.styleFrom(
                                backgroundColor: _widgetFactory.theme.colorScheme.tertiaryContainer,
                                foregroundColor: _widgetFactory.theme.colorScheme.onTertiaryContainer,
                                side: BorderSide(color: _widgetFactory.theme.colorScheme.primary),
                              ),
                              onPressed: () async {
                                final newNotes = await NotesInputDialog.show(context, notes);
                                vm.updateNotes(newNotes);
                              },
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: BlastMarkdownText(
                        text: notes,
                        style: _widgetFactory.textTheme.bodyMedium,
                        styleHeader: _widgetFactory.textTheme.titleMedium!.copyWith(
                          color: _widgetFactory.theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ))));
  }
}

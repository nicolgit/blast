import 'package:flutter/material.dart';
import 'package:blastapp/blastwidget/blast_widgetfactory.dart';

class FileChangedBanner extends StatelessWidget {
  final Future<bool> isFileChangedFuture;
  final VoidCallback onSavePressed;

  const FileChangedBanner({
    super.key,
    required this.isFileChangedFuture,
    required this.onSavePressed,
  });

  @override
  Widget build(BuildContext context) {
    final widgetFactory = BlastWidgetFactory(context);

    return FutureBuilder<bool>(
      future: isFileChangedFuture,
      builder: (context, isFileChanged) {
        return Visibility(
          visible: isFileChanged.data ?? false,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            color: widgetFactory.theme.colorScheme.error,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('file changed, click',
                    style:
                        widgetFactory.textTheme.labelSmall!.copyWith(color: widgetFactory.theme.colorScheme.onError)),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
                    child: FilledButton(
                      onPressed: onSavePressed,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 24),
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('here', style: widgetFactory.textTheme.labelSmall!.copyWith(color: widgetFactory.theme.colorScheme.onPrimary)),
                    )),
                Text('to save',
                    style:
                        widgetFactory.textTheme.labelSmall!.copyWith(color: widgetFactory.theme.colorScheme.onError)),
              ],
            ),
          ),
        );
      },
    );
  }
}

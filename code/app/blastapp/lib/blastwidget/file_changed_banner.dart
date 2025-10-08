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
            color: widgetFactory.theme.colorScheme.error,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('file changed, click',
                    style:
                        widgetFactory.textTheme.labelSmall!.copyWith(color: widgetFactory.theme.colorScheme.onError)),
                Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: FilledButton(
                      onPressed: onSavePressed,
                      child: Text('here', style: widgetFactory.textTheme.labelSmall),
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

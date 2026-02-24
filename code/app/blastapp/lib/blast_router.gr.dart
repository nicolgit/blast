// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'blast_router.dart';

/// generated route for
/// [CardEditView]
class CardEditRoute extends PageRouteInfo<CardEditRouteArgs> {
  CardEditRoute({Key? key, BlastCard? card, List<PageRouteInfo>? children})
      : super(
          CardEditRoute.name,
          args: CardEditRouteArgs(key: key, card: card),
          initialChildren: children,
        );

  static const String name = 'CardEditRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CardEditRouteArgs>(
        orElse: () => const CardEditRouteArgs(),
      );
      return CardEditView(key: args.key, card: args.card);
    },
  );
}

class CardEditRouteArgs {
  const CardEditRouteArgs({this.key, this.card});

  final Key? key;

  final BlastCard? card;

  @override
  String toString() {
    return 'CardEditRouteArgs{key: $key, card: $card}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CardEditRouteArgs) return false;
    return key == other.key && card == other.card;
  }

  @override
  int get hashCode => key.hashCode ^ card.hashCode;
}

/// generated route for
/// [CardFileInfoView]
class CardFileInfoRoute extends PageRouteInfo<void> {
  const CardFileInfoRoute({List<PageRouteInfo>? children})
      : super(CardFileInfoRoute.name, initialChildren: children);

  static const String name = 'CardFileInfoRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CardFileInfoView();
    },
  );
}

/// generated route for
/// [CardView]
class CardRoute extends PageRouteInfo<CardRouteArgs> {
  CardRoute({Key? key, required BlastCard card, List<PageRouteInfo>? children})
      : super(
          CardRoute.name,
          args: CardRouteArgs(key: key, card: card),
          initialChildren: children,
        );

  static const String name = 'CardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CardRouteArgs>();
      return CardView(key: args.key, card: args.card);
    },
  );
}

class CardRouteArgs {
  const CardRouteArgs({this.key, required this.card});

  final Key? key;

  final BlastCard card;

  @override
  String toString() {
    return 'CardRouteArgs{key: $key, card: $card}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CardRouteArgs) return false;
    return key == other.key && card == other.card;
  }

  @override
  int get hashCode => key.hashCode ^ card.hashCode;
}

/// generated route for
/// [CardsBrowserView]
class CardsBrowserRoute extends PageRouteInfo<void> {
  const CardsBrowserRoute({List<PageRouteInfo>? children})
      : super(CardsBrowserRoute.name, initialChildren: children);

  static const String name = 'CardsBrowserRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CardsBrowserView();
    },
  );
}

/// generated route for
/// [ChangeIconView]
class ChangeIconRoute extends PageRouteInfo<void> {
  const ChangeIconRoute({List<PageRouteInfo>? children})
      : super(ChangeIconRoute.name, initialChildren: children);

  static const String name = 'ChangeIconRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChangeIconView();
    },
  );
}

/// generated route for
/// [ChangePasswordView]
class ChangePasswordRoute extends PageRouteInfo<void> {
  const ChangePasswordRoute({List<PageRouteInfo>? children})
      : super(ChangePasswordRoute.name, initialChildren: children);

  static const String name = 'ChangePasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChangePasswordView();
    },
  );
}

/// generated route for
/// [ChooseFileView]
class ChooseFileRoute extends PageRouteInfo<void> {
  const ChooseFileRoute({List<PageRouteInfo>? children})
      : super(ChooseFileRoute.name, initialChildren: children);

  static const String name = 'ChooseFileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChooseFileView();
    },
  );
}

/// generated route for
/// [ChooseStorageView]
class ChooseStorageRoute extends PageRouteInfo<void> {
  const ChooseStorageRoute({List<PageRouteInfo>? children})
      : super(ChooseStorageRoute.name, initialChildren: children);

  static const String name = 'ChooseStorageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChooseStorageView();
    },
  );
}

/// generated route for
/// [CreatePasswordView]
class CreatePasswordRoute extends PageRouteInfo<CreatePasswordRouteArgs> {
  CreatePasswordRoute({
    Key? key,
    required String path,
    List<PageRouteInfo>? children,
  }) : super(
          CreatePasswordRoute.name,
          args: CreatePasswordRouteArgs(key: key, path: path),
          initialChildren: children,
        );

  static const String name = 'CreatePasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreatePasswordRouteArgs>();
      return CreatePasswordView(key: args.key, path: args.path);
    },
  );
}

class CreatePasswordRouteArgs {
  const CreatePasswordRouteArgs({this.key, required this.path});

  final Key? key;

  final String path;

  @override
  String toString() {
    return 'CreatePasswordRouteArgs{key: $key, path: $path}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreatePasswordRouteArgs) return false;
    return key == other.key && path == other.path;
  }

  @override
  int get hashCode => key.hashCode ^ path.hashCode;
}

/// generated route for
/// [EulaView]
class EulaRoute extends PageRouteInfo<void> {
  const EulaRoute({List<PageRouteInfo>? children})
      : super(EulaRoute.name, initialChildren: children);

  static const String name = 'EulaRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EulaView();
    },
  );
}

/// generated route for
/// [FieldView]
class FieldRoute extends PageRouteInfo<FieldRouteArgs> {
  FieldRoute({Key? key, required String value, List<PageRouteInfo>? children})
      : super(
          FieldRoute.name,
          args: FieldRouteArgs(key: key, value: value),
          initialChildren: children,
        );

  static const String name = 'FieldRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FieldRouteArgs>();
      return FieldView(key: args.key, value: args.value);
    },
  );
}

class FieldRouteArgs {
  const FieldRouteArgs({this.key, required this.value});

  final Key? key;

  final String value;

  @override
  String toString() {
    return 'FieldRouteArgs{key: $key, value: $value}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FieldRouteArgs) return false;
    return key == other.key && value == other.value;
  }

  @override
  int get hashCode => key.hashCode ^ value.hashCode;
}

/// generated route for
/// [ImporterView]
class ImporterRoute extends PageRouteInfo<void> {
  const ImporterRoute({List<PageRouteInfo>? children})
      : super(ImporterRoute.name, initialChildren: children);

  static const String name = 'ImporterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ImporterView();
    },
  );
}

/// generated route for
/// [PasswordGeneratorView]
class PasswordGeneratorRoute extends PageRouteInfo<PasswordGeneratorRouteArgs> {
  PasswordGeneratorRoute({
    Key? key,
    required bool allowCopyToClipboard,
    required bool returnsValue,
    List<PageRouteInfo>? children,
  }) : super(
          PasswordGeneratorRoute.name,
          args: PasswordGeneratorRouteArgs(
            key: key,
            allowCopyToClipboard: allowCopyToClipboard,
            returnsValue: returnsValue,
          ),
          initialChildren: children,
        );

  static const String name = 'PasswordGeneratorRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PasswordGeneratorRouteArgs>();
      return PasswordGeneratorView(
        key: args.key,
        allowCopyToClipboard: args.allowCopyToClipboard,
        returnsValue: args.returnsValue,
      );
    },
  );
}

class PasswordGeneratorRouteArgs {
  const PasswordGeneratorRouteArgs({
    this.key,
    required this.allowCopyToClipboard,
    required this.returnsValue,
  });

  final Key? key;

  final bool allowCopyToClipboard;

  final bool returnsValue;

  @override
  String toString() {
    return 'PasswordGeneratorRouteArgs{key: $key, allowCopyToClipboard: $allowCopyToClipboard, returnsValue: $returnsValue}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PasswordGeneratorRouteArgs) return false;
    return key == other.key &&
        allowCopyToClipboard == other.allowCopyToClipboard &&
        returnsValue == other.returnsValue;
  }

  @override
  int get hashCode =>
      key.hashCode ^ allowCopyToClipboard.hashCode ^ returnsValue.hashCode;
}

/// generated route for
/// [ScannerView]
class ScannerRoute extends PageRouteInfo<void> {
  const ScannerRoute({List<PageRouteInfo>? children})
      : super(ScannerRoute.name, initialChildren: children);

  static const String name = 'ScannerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ScannerView();
    },
  );
}

/// generated route for
/// [SettingsView]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
      : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsView();
    },
  );
}

/// generated route for
/// [SplashView]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
      : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashView();
    },
  );
}

/// generated route for
/// [TypePasswordView]
class TypePasswordRoute extends PageRouteInfo<TypePasswordRouteArgs> {
  TypePasswordRoute({
    Key? key,
    bool forceSkipBiometricQuestion = false,
    List<PageRouteInfo>? children,
  }) : super(
          TypePasswordRoute.name,
          args: TypePasswordRouteArgs(
            key: key,
            forceSkipBiometricQuestion: forceSkipBiometricQuestion,
          ),
          initialChildren: children,
        );

  static const String name = 'TypePasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TypePasswordRouteArgs>(
        orElse: () => const TypePasswordRouteArgs(),
      );
      return TypePasswordView(
        key: args.key,
        forceSkipBiometricQuestion: args.forceSkipBiometricQuestion,
      );
    },
  );
}

class TypePasswordRouteArgs {
  const TypePasswordRouteArgs({
    this.key,
    this.forceSkipBiometricQuestion = false,
  });

  final Key? key;

  final bool forceSkipBiometricQuestion;

  @override
  String toString() {
    return 'TypePasswordRouteArgs{key: $key, forceSkipBiometricQuestion: $forceSkipBiometricQuestion}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TypePasswordRouteArgs) return false;
    return key == other.key &&
        forceSkipBiometricQuestion == other.forceSkipBiometricQuestion;
  }

  @override
  int get hashCode => key.hashCode ^ forceSkipBiometricQuestion.hashCode;
}

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
class CreatePasswordRoute extends PageRouteInfo<void> {
  const CreatePasswordRoute({List<PageRouteInfo>? children})
      : super(CreatePasswordRoute.name, initialChildren: children);

  static const String name = 'CreatePasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CreatePasswordView();
    },
  );
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
class PasswordGeneratorRoute extends PageRouteInfo<void> {
  const PasswordGeneratorRoute({List<PageRouteInfo>? children})
      : super(PasswordGeneratorRoute.name, initialChildren: children);

  static const String name = 'PasswordGeneratorRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PasswordGeneratorView();
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
class TypePasswordRoute extends PageRouteInfo<void> {
  const TypePasswordRoute({List<PageRouteInfo>? children})
      : super(TypePasswordRoute.name, initialChildren: children);

  static const String name = 'TypePasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TypePasswordView();
    },
  );
}

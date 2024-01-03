// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'blast_router.dart';

abstract class _$BlastRouter extends RootStackRouter {
  // ignore: unused_element
  _$BlastRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    CardRoute.name: (routeData) {
      final args = routeData.argsAs<CardRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CardView(
          key: args.key,
          card: args.card,
        ),
      );
    },
    CardsBrowserRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CardsBrowserView(),
      );
    },
    ChooseFileRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ChooseFileView(),
      );
    },
    ChooseStorageRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ChooseStorageView(),
      );
    },
    CreatePasswordRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CreatePasswordView(),
      );
    },
    EulaRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const EulaView(),
      );
    },
    SplashRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SplashView(),
      );
    },
    TypePasswordRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TypePasswordView(),
      );
    },
  };
}

/// generated route for
/// [CardView]
class CardRoute extends PageRouteInfo<CardRouteArgs> {
  CardRoute({
    Key? key,
    required BlastCard card,
    List<PageRouteInfo>? children,
  }) : super(
          CardRoute.name,
          args: CardRouteArgs(
            key: key,
            card: card,
          ),
          initialChildren: children,
        );

  static const String name = 'CardRoute';

  static const PageInfo<CardRouteArgs> page = PageInfo<CardRouteArgs>(name);
}

class CardRouteArgs {
  const CardRouteArgs({
    this.key,
    required this.card,
  });

  final Key? key;

  final BlastCard card;

  @override
  String toString() {
    return 'CardRouteArgs{key: $key, card: $card}';
  }
}

/// generated route for
/// [CardsBrowserView]
class CardsBrowserRoute extends PageRouteInfo<void> {
  const CardsBrowserRoute({List<PageRouteInfo>? children})
      : super(
          CardsBrowserRoute.name,
          initialChildren: children,
        );

  static const String name = 'CardsBrowserRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ChooseFileView]
class ChooseFileRoute extends PageRouteInfo<void> {
  const ChooseFileRoute({List<PageRouteInfo>? children})
      : super(
          ChooseFileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ChooseFileRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ChooseStorageView]
class ChooseStorageRoute extends PageRouteInfo<void> {
  const ChooseStorageRoute({List<PageRouteInfo>? children})
      : super(
          ChooseStorageRoute.name,
          initialChildren: children,
        );

  static const String name = 'ChooseStorageRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CreatePasswordView]
class CreatePasswordRoute extends PageRouteInfo<void> {
  const CreatePasswordRoute({List<PageRouteInfo>? children})
      : super(
          CreatePasswordRoute.name,
          initialChildren: children,
        );

  static const String name = 'CreatePasswordRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [EulaView]
class EulaRoute extends PageRouteInfo<void> {
  const EulaRoute({List<PageRouteInfo>? children})
      : super(
          EulaRoute.name,
          initialChildren: children,
        );

  static const String name = 'EulaRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SplashView]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TypePasswordView]
class TypePasswordRoute extends PageRouteInfo<void> {
  const TypePasswordRoute({List<PageRouteInfo>? children})
      : super(
          TypePasswordRoute.name,
          initialChildren: children,
        );

  static const String name = 'TypePasswordRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

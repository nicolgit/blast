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
    ChooseFileRoute.name: (routeData) {
      final args = routeData.argsAs<ChooseFileRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ChooseFileView(
          key: args.key,
          cloud: args.cloud,
        ),
      );
    },
    ChooseStorageRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ChooseStorageView(),
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
  };
}

/// generated route for
/// [ChooseFileView]
class ChooseFileRoute extends PageRouteInfo<ChooseFileRouteArgs> {
  ChooseFileRoute({
    Key? key,
    required Cloud cloud,
    List<PageRouteInfo>? children,
  }) : super(
          ChooseFileRoute.name,
          args: ChooseFileRouteArgs(
            key: key,
            cloud: cloud,
          ),
          initialChildren: children,
        );

  static const String name = 'ChooseFileRoute';

  static const PageInfo<ChooseFileRouteArgs> page =
      PageInfo<ChooseFileRouteArgs>(name);
}

class ChooseFileRouteArgs {
  const ChooseFileRouteArgs({
    this.key,
    required this.cloud,
  });

  final Key? key;

  final Cloud cloud;

  @override
  String toString() {
    return 'ChooseFileRouteArgs{key: $key, cloud: $cloud}';
  }
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

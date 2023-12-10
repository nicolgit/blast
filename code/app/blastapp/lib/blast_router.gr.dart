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
  };
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

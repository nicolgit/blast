import 'package:auto_route/auto_route.dart';
import 'package:blastapp/eula_view.dart';
import 'package:blastapp/splash_view.dart';
part 'blast_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'View,Route')
class BlastRouter extends _$BlastRouter {
  @override
  List<AutoRoute> get routes => [
        // add your routes here
        AutoRoute (page: SplashRoute.page, initial: true),
        AutoRoute (page: EulaRoute.page)
      ];
}
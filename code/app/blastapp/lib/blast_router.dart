import 'package:auto_route/auto_route.dart';
import 'package:blastapp/View/choose_file_view.dart';
import 'package:blastapp/View/choose_storage_view.dart';
import 'package:blastapp/View/eula_view.dart';
import 'package:blastapp/View/splash_view.dart';
import 'package:blastmodel/Cloud/cloud.dart';
import 'package:flutter/material.dart';
part 'blast_router.gr.dart';

// https://pub.dev/packages/auto_route
// Generete route classes with command: flutter packages pub run build_runner build

@AutoRouterConfig(replaceInRouteName: 'View,Route')
class BlastRouter extends _$BlastRouter {
  @override
  List<AutoRoute> get routes => [
        // add your routes here
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: EulaRoute.page),
        AutoRoute(page: ChooseStorageRoute.page),
        AutoRoute(page: ChooseFileRoute.page)
      ];
}

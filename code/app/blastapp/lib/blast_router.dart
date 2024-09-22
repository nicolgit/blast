import 'package:auto_route/auto_route.dart';
import 'package:blastapp/View/card_edit_view.dart';
import 'package:blastapp/View/card_view.dart';
import 'package:blastapp/View/cards_browser_view.dart';
import 'package:blastapp/View/choose_file_view.dart';
import 'package:blastapp/View/card_file_info_view.dart';
import 'package:blastapp/View/choose_storage_view.dart';
import 'package:blastapp/View/create_password_view.dart';
import 'package:blastapp/View/eula_view.dart';
import 'package:blastapp/View/importer_view.dart';
import 'package:blastapp/View/splash_view.dart';
import 'package:blastapp/View/field_view.dart';
import 'package:blastapp/View/type_password_view.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter/rendering.dart';
part 'blast_router.gr.dart';

// https://pub.dev/packages/auto_route
// Generate route classes with command: dart run build_runner build
@AutoRouterConfig(replaceInRouteName: 'View,Route')
class BlastRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        // add your routes here
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: EulaRoute.page),
        AutoRoute(page: ChooseStorageRoute.page),
        AutoRoute(page: ChooseFileRoute.page),
        AutoRoute(page: CreatePasswordRoute.page),
        AutoRoute(page: TypePasswordRoute.page),
        AutoRoute(page: CardsBrowserRoute.page),
        AutoRoute(page: CardRoute.page),
        AutoRoute(page: CardEditRoute.page),
        AutoRoute(page: FieldRoute.page),
        AutoRoute(page: ImporterRoute.page),
        AutoRoute(page: CardFileInfoRoute.page),
      ];
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:blastapp/View/choose_storage_view.dart';
import 'package:blastapp/ViewModel/type_password_viewmodel.dart';
import 'package:blastapp/helpers/biometric_helper.dart';
import 'package:blastapp/helpers/currentfile_helper.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';
import 'package:blastmodel/Cloud/dropbox_cloud.dart';
import 'package:blastmodel/blastfile.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Folder extends DropboxFolderCloud {
  @override
  Future<CloudFile> getFile(String id) async =>
      CloudFile(data: Uint8List(0), lastModified: DateTime.utc(2026), id: id);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  final settings = SettingService();
  const channel = MethodChannel('biometric_storage');
  String? biometricPayload;

  setUp(() async {
    await settings.setAskForBiometricAuth(true);
    await settings.setBiometricAuthEnabled(true);
    biometricPayload = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.arguments['name'], 'blastvault');
      switch (call.method) {
        case 'init':
          return true;
        case 'write':
          biometricPayload = call.arguments['content'] as String;
          return null;
        case 'read':
          return biometricPayload;
        default:
          fail('Unexpected biometric operation: ${call.method}');
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    CurrentFileService().reset();
  });

  testWidgets('storage picker distinguishes both Dropbox providers and bundles their ID-based icons', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: ChooseStorageView()));
    await tester.pumpAndSettle();
    expect(find.text('Dropbox full access'), findsOneWidget);
    expect(find.text('Dropbox app folder'), findsOneWidget);
    expect(find.textContaining('preview'), findsNothing);
    for (final id in ['DROPBOX', 'DROPBOXFOLDER']) {
      final path = 'assets/storage/$id.png';
      expect(find.byWidgetPredicate((widget) => widget is Image && widget.image == AssetImage(path)), findsOneWidget);
      expect((await rootBundle.load(path)).lengthInBytes, greaterThan(0));
      CurrentFileService().currentFileInfo = BlastFile(cloudId: id, fileName: 'vault.blast', fileUrl: '/vault.blast');
      expect(TypePasswordViewModel().cloudIcon, path);
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('biometric credentials are bound to their Dropbox provider in both directions', () async {
    for (final id in ['DROPBOX', 'DROPBOXFOLDER']) {
      final cloud = await settings.getCloudStorageById(id);
      CurrentFileService().setCloud(cloud);
      cloud.cachedCredentials = '$id-mock-cache';
      await BiometricHelper.saveData('mock-vault-password');
      expect(jsonDecode(biometricPayload!)['CloudId'], id);
      final matching = await BiometricHelper.readData(id);
      expect(matching!.cloudCredentials, '$id-mock-cache');
      expect(matching.password, 'mock-vault-password');
      expect(await BiometricHelper.readData(id == 'DROPBOX' ? 'DROPBOXFOLDER' : 'DROPBOX'), isNull);
      cloud.cachedCredentials = null;
    }
  });

  test('legacy biometric payloads remain compatible but cannot authorize the new provider', () async {
    biometricPayload = jsonEncode({'Password': 'legacy-password', 'CloudCredentials': 'legacy-mock-cache'});
    expect((await BiometricHelper.readData('DROPBOX'))!.cloudCredentials, 'legacy-mock-cache');
    expect(await BiometricHelper.readData('DROPBOXFOLDER'), isNull);
  });

  test('recent-file loading uses the folder provider and only its biometric cache for identical paths', () async {
    final originalClouds = settings.cloudStorages;
    final full = DropboxCloud()..cachedCredentials = 'full-mock-cache';
    final folder = _Folder()..cachedCredentials = 'folder-mock-cache';
    settings.cloudStorages = [full, folder];
    addTearDown(() => settings.cloudStorages = originalClouds);
    final file = BlastFile(cloudId: folder.id, fileName: 'vault.blast', fileUrl: '/vault.blast');

    CurrentFileService().setCloud(folder);
    await BiometricHelper.saveData('mock-vault-password');
    final data = await BiometricHelper.readData(file.cloudId);
    await CurrentFileHelper.load(file, data!.cloudCredentials);
    expect(CurrentFileService().cloud, same(folder));
    expect(CurrentFileService().currentFileInfo!.cloudId, 'DROPBOXFOLDER');
    expect(CurrentFileService().currentFileInfo!.fileUrl, '/vault.blast');
    expect(folder.cachedCredentials, 'folder-mock-cache');
    expect(full.cachedCredentials, 'full-mock-cache');

    CurrentFileService().setCloud(full);
    await BiometricHelper.saveData('mock-vault-password');
    final mismatched = await BiometricHelper.readData(file.cloudId);
    expect(mismatched, isNull);
    await CurrentFileHelper.load(file, mismatched?.cloudCredentials);
    expect(folder.cachedCredentials, isNot('full-mock-cache'));
    expect(full.cachedCredentials, 'full-mock-cache');
  });
}

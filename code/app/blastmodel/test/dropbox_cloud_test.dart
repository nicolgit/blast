import 'dart:convert';
import 'dart:typed_data';

import 'package:blastmodel/Cloud/dropbox_cloud.dart';
import 'package:blastmodel/blastfile.dart';
import 'package:blastmodel/blastfilelist.dart';
import 'package:blastmodel/secrets.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:blastmodel/specific/blastoauth/blastoauth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:shared_preferences/shared_preferences.dart';

class _OAuth extends BlastOAuth {
  final http.Client client;
  Object? error;
  int clientRequests = 0;
  bool canceled = false;
  bool loggedOut = false;

  _OAuth(this.client);

  @override
  Future<oauth2.Client> createClient() async {
    clientRequests++;
    if (error != null) throw error!;
    return oauth2.Client(oauth2.Credentials('mock-access-token'),
        identifier: applicationId, httpClient: client);
  }

  @override
  void cancelAuthorization() => canceled = true;

  @override
  Future<bool> logout() async {
    loggedOut = true;
    cachedCredentials = null;
    return true;
  }

  @override
  void dispose() {}
}

class _UnconfiguredFolder extends DropboxFolderCloud {
  final String key;

  _UnconfiguredFolder(this.key, BlastOAuth oauth) : super(oauth: oauth);

  @override
  String get clientId => key;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  final settings = SettingService();
  final bytes = Uint8List.fromList([1, 2, 3]);
  const timestamp = '2026-01-02T03:04:05Z';

  http.Response metadata(String path) => http.Response(jsonEncode({
        'path_lower': path,
        'client_modified': timestamp,
      }), 200);

  test('providers have stable identities, separate apps and common API configuration', () async {
    final fullAuth = _OAuth(MockClient((_) async => http.Response('', 500)));
    final folderAuth = _OAuth(MockClient((_) async => http.Response('', 500)));
    final full = DropboxCloud(oauth: fullAuth);
    final folder = DropboxFolderCloud(oauth: folderAuth);

    expect(full.id, 'DROPBOX');
    expect(folder.id, 'DROPBOXFOLDER');
    expect(full.name, 'Dropbox full access');
    expect(folder.name, 'Dropbox app folder');
    expect(full.clientId, Secrets.dropboxApplicationId);
    expect(folder.clientId, Secrets.dropboxFolderApplicationId);
    expect(folder.clientId, isNot(full.clientId));
    expect(fullAuth.applicationId, full.clientId);
    expect(folderAuth.applicationId, folder.clientId);
    expect(folderAuth.authorizationEndpoint, fullAuth.authorizationEndpoint);
    expect(folderAuth.tokenEndpoint, fullAuth.tokenEndpoint);
    expect(folderAuth.redirectUri, fullAuth.redirectUri);
    expect(folderAuth.scopes, ['files.content.read', 'files.content.write', 'files.metadata.read']);
    expect(await folder.rootpath, '');
    expect(await full.rootpath, '');
    expect(folder.hasCachedCredentials, isTrue);
  });

  test('registered providers and persisted same-path recents retain their access contexts', () async {
    final clouds = await settings.getCloudStoragelist();
    expect(clouds.whereType<DropboxFolderCloud>(), hasLength(1));
    final full = await settings.getCloudStorageById('DROPBOX');
    final folder = await settings.getCloudStorageById('DROPBOXFOLDER');
    expect(full.runtimeType, DropboxCloud);
    expect(folder, isA<DropboxFolderCloud>());
    expect(identical(full, folder), isFalse);
    full.cachedCredentials = 'full-cache';
    folder.cachedCredentials = 'folder-cache';

    settings.recentFiles = BlastFileList();
    for (final id in ['DROPBOX', 'DROPBOXFOLDER', 'DROPBOXFOLDER']) {
      settings.addRecentFile(BlastFile(cloudId: id, fileName: 'vault.blast', fileUrl: '/vault.blast'));
    }
    // Recent-file writes are asynchronous; wait for the public persistence result.
    final prefs = await SharedPreferences.getInstance();
    await pumpEventQueue();
    expect(prefs.getString('recentFiles'), isNotNull);
    settings.recentFiles = BlastFileList();
    final reloaded = await settings.getRecentFiles();
    expect(reloaded.map((file) => file.cloudId), ['DROPBOXFOLDER', 'DROPBOX']);
    expect(reloaded.map((file) => file.fileUrl), ['/vault.blast', '/vault.blast']);
    for (final file in reloaded) {
      final provider = await settings.getCloudStorageById(file.cloudId);
      expect(provider.cachedCredentials, file.cloudId == 'DROPBOX' ? 'full-cache' : 'folder-cache');
    }
    full.cachedCredentials = null;
    folder.cachedCredentials = null;
  });

  test('credentials, cancellation and logout belong to each OAuth instance', () async {
    final fullAuth = _OAuth(MockClient((_) async => http.Response('', 500)));
    final folderAuth = _OAuth(MockClient((_) async => http.Response('', 500)));
    final full = DropboxCloud(oauth: fullAuth)..cachedCredentials = 'full-cache';
    final folder = DropboxFolderCloud(oauth: folderAuth)..cachedCredentials = 'folder-cache';
    expect(fullAuth.cachedCredentials, 'full-cache');
    expect(folderAuth.cachedCredentials, 'folder-cache');
    await folder.cancelAuthorization();
    expect(folderAuth.canceled, isTrue);
    expect(fullAuth.canceled, isFalse);
    expect(await folder.logOut(), isTrue);
    expect(folder.cachedCredentials, isNull);
    expect(full.cachedCredentials, 'full-cache');
    expect(fullAuth.loggedOut, isFalse);
    await full.cancelAuthorization();
    await full.logOut();
    expect(fullAuth.canceled, isTrue);
    expect(full.cachedCredentials, isNull);
  });

  test('folder listing and parent navigation use the app-relative namespace', () async {
    final paths = <String>[];
    final folder = DropboxFolderCloud(oauth: _OAuth(MockClient((request) async {
      expect(request.url.toString(), 'https://api.dropboxapi.com/2/files/list_folder');
      paths.add(jsonDecode(request.body)['path'] as String);
      return http.Response(jsonEncode({
        'entries': [
          {'.tag': 'folder', 'name': 'nested', 'path_lower': '/nested'},
          {
            '.tag': 'file',
            'name': 'vault.blast',
            'path_lower': '/vault.blast',
            'client_modified': timestamp,
            'size': 3,
          },
        ],
      }), 200);
    })));
    for (final path in ['', '/', '/nested']) {
      final files = await folder.getFiles(path);
      expect(files.first.isDirectory, isTrue);
      expect(files.first.url, '/nested');
      expect(files.last.path, '/vault.blast');
      expect(files.last.size, 3);
    }
    expect(paths, ['', '', '/nested']);
    for (final path in ['', '/', '/nested', '/nested/', 'nested']) {
      expect(await folder.goToParentDirectory(path), '');
    }
    expect(await folder.goToParentDirectory('/nested/child/'), '/nested');
  });

  for (final appFolder in [false, true]) {
    test('create, reopen, metadata and update follow the actual autorenamed path (folder=$appFolder)', () async {
      final operations = <String>[];
      final auth = _OAuth(MockClient((request) async {
        final endpoint = request.url.pathSegments.last;
        operations.add(endpoint);
        final args = jsonDecode(request.headers['Dropbox-API-Arg'] ?? request.body) as Map<String, dynamic>;
        if (endpoint == 'upload' && args['mode'] == 'add') {
          expect(args['path'], '/vault.blast');
          expect(args['autorename'], isTrue);
          expect(request.bodyBytes, bytes);
          return metadata('/vault (1).blast');
        }
        expect(args['path'], '/vault (1).blast');
        if (endpoint == 'download') {
          return http.Response.bytes(bytes, 200);
        }
        if (endpoint == 'upload') {
          expect(args['mode'], 'overwrite');
          expect(args['autorename'], isFalse);
          expect(request.bodyBytes, bytes);
        } else {
          expect(endpoint, 'get_metadata');
        }
        return metadata('/vault (1).blast');
      }));
      final provider = appFolder ? DropboxFolderCloud(oauth: auth) : DropboxCloud(oauth: auth);
      final created = await provider.createFile('vault.blast', bytes);
      expect(created.id, '/vault (1).blast');
      expect(created.data, bytes);
      expect(created.lastModified, DateTime.parse(timestamp));
      final reopened = await provider.getFile(created.id);
      expect(reopened.id, created.id);
      expect(reopened.data, bytes);
      expect(reopened.lastModified, created.lastModified);
      expect((await provider.getFileInfo(created.id)).lastModified, created.lastModified);
      expect((await provider.setFile(created.id, bytes)).id, created.id);
      expect(operations, ['upload', 'get_metadata', 'download', 'get_metadata', 'upload']);
    });
  }

  for (final status in [401, 403, 409, 500]) {
    test('API errors propagate without false success or fallback ($status)', () async {
      final folder = DropboxFolderCloud(oauth: _OAuth(MockClient((_) async => http.Response('denied', status))));
      await expectLater(folder.getFiles(''), throwsException);
      await expectLater(folder.createFile('vault.blast', bytes), throwsException);
      await expectLater(folder.getFileInfo('vault.blast'), throwsException);
      await expectLater(folder.getFile('vault.blast'), throwsException);
      await expectLater(folder.setFile('vault.blast', bytes), throwsException);
    });
  }

  test('download errors propagate after successful metadata', () async {
    final folder = DropboxFolderCloud(oauth: _OAuth(MockClient((request) async {
      return request.url.path.endsWith('get_metadata') ? metadata('/vault.blast') : http.Response('revoked', 401);
    })));
    await expectLater(folder.getFile('/vault.blast'), throwsException);
  });

  test('denied and canceled authorization propagate for every operation', () async {
    final client = MockClient((_) async => fail('No API request is allowed after authentication fails'));
    final auth = _OAuth(client);
    final folder = DropboxFolderCloud(oauth: auth);
    for (final error in [StateError('consent denied'), StateError('authorization canceled')]) {
      auth.error = error;
      await expectLater(folder.getFiles(''), throwsA(same(error)));
      await expectLater(folder.getFile('vault.blast'), throwsA(same(error)));
      await expectLater(folder.getFileInfo('vault.blast'), throwsA(same(error)));
      await expectLater(folder.createFile('vault.blast', bytes), throwsA(same(error)));
      await expectLater(folder.setFile('vault.blast', bytes), throwsA(same(error)));
    }
    expect(auth.applicationId, Secrets.dropboxFolderApplicationId);
  });

  for (final key in ['', ' ', 'DROPBOX_FOLDER_APPLICATION_ID', 'invalid key']) {
    test('missing or invalid folder App Key fails before authentication ($key)', () async {
      final auth = _OAuth(MockClient((_) async => fail('No API request is allowed without configuration')));
      final folder = _UnconfiguredFolder(key, auth);
      await expectLater(folder.getFiles(''), throwsA(isA<StateError>()));
      expect(auth.clientRequests, 0);
    });
  }
}

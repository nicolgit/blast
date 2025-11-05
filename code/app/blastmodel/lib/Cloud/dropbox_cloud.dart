import 'dart:convert';
import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';
import 'package:blastmodel/secrets.dart';
import 'package:flutter/foundation.dart';

import 'package:blastmodel/specific/blastoauth/blastoauth.dart';
import 'package:blastmodel/specific/blastoauth/blastoauth_stub.dart'
    if (dart.library.io) 'package:blastmodel/specific/blastoauth/blastoauth_mobile.dart'
    if (dart.library.html) 'package:blastmodel/specific/blastoauth/blastoauth_web.dart';

class DropboxCloud extends Cloud {
  late BlastOAuth _oauth;

  DropboxCloud() {
    var redirectUri = Uri();

    if (kIsWeb) {
      final currentUri = Uri.base;

      redirectUri = Uri(
        host: currentUri.host,
        scheme: currentUri.scheme,
        port: currentUri.port,
        path: '/auth-landing.html',
      );
    } else {
      redirectUri = Uri.parse('blastapp://auth');
    }

    _oauth = getBlastAuth().initialize(
        applicationId: Secrets.dropboxApplicationId,
        authorizationEndpoint: Uri.parse('https://www.dropbox.com/oauth2/authorize'),
        tokenEndpoint: Uri.parse('https://api.dropboxapi.com/oauth2/token'),
        redirectUri: redirectUri,
        scopes: ['files.content.read', 'files.content.write', 'files.metadata.read'],
        logoutUrl: 'https://www.dropbox.com/logout?post_logout_redirect_uri=REDIRECT_URI');
  }
  @override
  String get id => "DROPBOX";

  @override
  String get name => "Dropbox";

  @override
  String get description => "Dropbox cloud storage, data stored in cloud, requires a Dropbox account";

  @override
  Future<String> get rootpath => Future.value('');

  @override
  bool get hasCachedCredentials => true;

  @override
  String? get cachedCredentials {
    return _oauth.cachedCredentials;
  }

  @override
  set cachedCredentials(String? value) {
    _oauth.cachedCredentials = value;
  }

  @override
  Future<List<CloudObject>> getFiles(String path) async {
    List<CloudObject> files = List.empty(growable: true);

    // Dropbox API v2 endpoint for listing folder contents
    // https://www.dropbox.com/developers/documentation/http/documentation#files-list_folder

    final client = await _oauth.createClient();

    final response = await client.post(
      Uri.parse('https://api.dropboxapi.com/2/files/list_folder'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'path': path.isEmpty || path == '/' ? '' : path,
        'recursive': false,
        'include_media_info': false,
        'include_deleted': false,
        'include_has_explicit_shared_members': false,
      }),
    );

    if (response.statusCode == 200) {
      final dropboxData = jsonDecode(response.body);

      for (var entry in dropboxData['entries']) {
        var co = CloudObject(
          name: entry['name'],
          path: entry['path_lower'],
          isDirectory: entry['.tag'] == 'folder',
          url: entry['.tag'] == 'file' ? entry['path_lower'] : entry['path_lower'],
          lastModified: entry['.tag'] == 'file' && entry['client_modified'] != null
              ? DateTime.parse(entry['client_modified'])
              : DateTime.now(),
          size: entry['.tag'] == 'file' ? (entry['size'] ?? 0) : 0,
        );
        files.add(co);
      }

      if (kDebugMode) {
        print('Dropbox response: ${response.body}');
      }
    } else {
      if (kDebugMode) {
        print('Dropbox API error: ${response.statusCode} - ${response.body}');
      }
      throw Exception('Failed to load files from Dropbox: ${response.statusCode}');
    }

    return files;
  }

  @override
  Future<CloudFile> createFile(String path, Uint8List bytes) async {
    // Dropbox API v2 endpoint for uploading files
    // https://www.dropbox.com/developers/documentation/http/documentation#files-upload

    // Ensure path starts with / for Dropbox API
    if (!path.startsWith('/')) {
      path = '/$path';
    }

    final client = await _oauth.createClient();

    final response = await client.post(
      Uri.parse('https://content.dropboxapi.com/2/files/upload'),
      headers: {
        'Content-Type': 'application/octet-stream',
        'Dropbox-API-Arg': jsonEncode({
          'path': path,
          'mode': 'add',
          'autorename': true,
          'mute': false,
        }),
      },
      body: bytes,
    );

    if (response.statusCode == 200) {
      final dropboxData = jsonDecode(response.body);

      final fileId = path;
      final lastModified =
          dropboxData['client_modified'] != null ? DateTime.parse(dropboxData['client_modified']) : DateTime.now();

      final CloudFile cf = CloudFile(data: bytes, lastModified: lastModified, id: fileId);

      if (kDebugMode) {
        print('Dropbox file created: ${response.body}');
      }

      return cf;
    } else {
      if (kDebugMode) {
        print('Dropbox create file error: ${response.statusCode} - ${response.body}');
      }
      throw Exception('Failed to create file in Dropbox: ${response.statusCode} - ${response.body}');
    }
  }

  @override
  Future<CloudFile> getFile(String id) async {
    final client = await _oauth.createClient();

    // First get file metadata to retrieve modification date
    // https://www.dropbox.com/developers/documentation/http/documentation#files-get_metadata
    final metadataResponse = await client.post(
      Uri.parse('https://api.dropboxapi.com/2/files/get_metadata'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'path': id.startsWith('/') ? id : '/$id',
        'include_media_info': false,
        'include_deleted': false,
        'include_has_explicit_shared_members': false,
      }),
    );

    DateTime lastModified = DateTime.now();
    if (metadataResponse.statusCode == 200) {
      final metadataData = jsonDecode(metadataResponse.body);
      if (metadataData['client_modified'] != null) {
        lastModified = DateTime.parse(metadataData['client_modified']);
      }
    }

    // Download file content
    // https://www.dropbox.com/developers/documentation/http/documentation#files-download
    final downloadResponse = await client.post(
      Uri.parse('https://content.dropboxapi.com/2/files/download'),
      headers: {
        'Dropbox-API-Arg': jsonEncode({
          'path': id.startsWith('/') ? id : '/$id',
        }),
      },
    );

    if (downloadResponse.statusCode == 200) {
      final fileContent = Uint8List.fromList(downloadResponse.bodyBytes);

      if (kDebugMode) {
        print('Dropbox file downloaded: ${id}');
      }

      return CloudFile(data: fileContent, lastModified: lastModified, id: id);
    } else {
      if (kDebugMode) {
        print('Dropbox download error: ${downloadResponse.statusCode} - ${downloadResponse.body}');
      }
      throw Exception(
          'Failed to download file from Dropbox: ${downloadResponse.statusCode} - ${downloadResponse.body}');
    }
  }

  @override
  Future<CloudFileInfo> getFileInfo(String id) async {
    final client = await _oauth.createClient();

    // Get file metadata using Dropbox API
    // https://www.dropbox.com/developers/documentation/http/documentation#files-get_metadata
    final response = await client.post(
      Uri.parse('https://api.dropboxapi.com/2/files/get_metadata'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'path': id.startsWith('/') ? id : '/$id',
        'include_media_info': false,
        'include_deleted': false,
        'include_has_explicit_shared_members': false,
      }),
    );

    if (response.statusCode == 200) {
      final dropboxData = jsonDecode(response.body);

      final lastModified =
          dropboxData['client_modified'] != null ? DateTime.parse(dropboxData['client_modified']) : DateTime.now();

      if (kDebugMode) {
        print('Dropbox file info retrieved: ${response.body}');
      }

      final CloudFileInfo cfi = CloudFileInfo(lastModified: lastModified, id: id);
      return cfi;
    } else {
      if (kDebugMode) {
        print('Dropbox get file info error: ${response.statusCode} - ${response.body}');
      }
      throw Exception('Failed to get file info from Dropbox: ${response.statusCode} - ${response.body}');
    }
  }

  @override
  Future<CloudFile> setFile(String id, Uint8List bytes) async {
    // Dropbox API v2 endpoint for uploading/updating files
    // https://www.dropbox.com/developers/documentation/http/documentation#files-upload

    final client = await _oauth.createClient();

    // Use 'overwrite' mode to update existing file
    final response = await client.post(
      Uri.parse('https://content.dropboxapi.com/2/files/upload'),
      headers: {
        'Content-Type': 'application/octet-stream',
        'Dropbox-API-Arg': jsonEncode({
          'path': id.startsWith('/') ? id : '/$id',
          'mode': 'overwrite', // Overwrite existing file
          'autorename': false, // Don't rename, we want to update the existing file
          'mute': false,
        }),
      },
      body: bytes,
    );

    if (response.statusCode == 200) {
      final dropboxData = jsonDecode(response.body);

      final lastModified =
          dropboxData['client_modified'] != null ? DateTime.parse(dropboxData['client_modified']) : DateTime.now();

      final CloudFile cf = CloudFile(data: bytes, lastModified: lastModified, id: id);

      if (kDebugMode) {
        print('Dropbox file updated: ${response.body}');
      }

      return cf;
    } else {
      if (kDebugMode) {
        print('Dropbox set file error: ${response.statusCode} - ${response.body}');
      }
      throw Exception('Failed to update file in Dropbox: ${response.statusCode} - ${response.body}');
    }
  }

  @override
  Future<String> goToParentDirectory(String currentPath) async {
    var rootpath = await this.rootpath;

    // If we're already at root, stay at root
    if (currentPath == rootpath || currentPath.isEmpty || currentPath == '/') {
      return rootpath;
    }

    // Remove trailing slash if present
    if (currentPath.endsWith('/') && currentPath.length > 1) {
      currentPath = currentPath.substring(0, currentPath.length - 1);
    }

    // Find the last slash to get parent directory
    int lastSlashIndex = currentPath.lastIndexOf('/');

    if (lastSlashIndex <= 0) {
      // If no slash found or slash is at the beginning, return root
      return rootpath;
    }

    // Get parent path
    var parentPath = currentPath.substring(0, lastSlashIndex);

    // If parent path is empty, return root
    if (parentPath.isEmpty) {
      return rootpath;
    }

    return parentPath;
  }

  @override
  Future<bool> logOut() async {
    return await _oauth.logout();
  }
}

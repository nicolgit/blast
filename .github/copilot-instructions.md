# Copilot Instructions for Blast

Blast is a cross-platform password manager built with **Flutter/Dart**. It targets Android, iOS, Windows, macOS, Linux, and Web from a single codebase.

## Build & Run

```bash
cd code/app/blastapp
flutter pub get
flutter run
```

### Code Generation (required after modifying models or routes)

```bash
# From code/app/blastapp — regenerates auto_route and json_serializable outputs
dart run build_runner build
```

Generated files (`*.g.dart`, `blast_router.gr.dart`) are checked in. Re-run the command above whenever you change `@JsonSerializable` models in `blastmodel` or `@RoutePage()` / router config in `blastapp`.

### Web Build (CI)

```bash
cd code/app/blastapp
flutter build web --release
```

The GitHub Actions workflow (`deploy-purple-flower.yml`) builds the web target and deploys to Azure Static Web Apps. It is triggered manually (`workflow_dispatch`).

### Linting

```bash
# From either blastapp or blastmodel
flutter analyze
```

Both packages use `package:flutter_lints/flutter.yaml` as the analysis baseline.

## Architecture

### Two-package structure

| Package | Path | Role |
|---------|------|------|
| **blastmodel** | `code/app/blastmodel` | Domain models, encryption, cloud storage abstraction, import/export, settings. No UI. |
| **blastapp** | `code/app/blastapp` | Flutter UI app. Depends on `blastmodel` via path reference. |

`blastapp` references `blastmodel` as a local path dependency — they are always developed together.

### MVVM Pattern

Views and ViewModels live in `blastapp/lib/View/` and `blastapp/lib/ViewModel/` respectively, with a strict 1:1 mapping:

- `card_view.dart` ↔ `card_viewmodel.dart`
- `cards_browser_view.dart` ↔ `cards_browser_viewmodel.dart`

Views are `StatefulWidget`s annotated with `@RoutePage()`. ViewModels extend `ChangeNotifier` and are wired to Views via the `provider` package.

### Routing

Navigation uses `auto_route`. Routes are declared in `blast_router.dart`. After adding/removing a route, regenerate with `dart run build_runner build`.

### Cloud Storage Abstraction

`blastmodel/lib/Cloud/cloud.dart` defines the abstract `Cloud` interface. Implementations:

- `filesystem_cloud.dart` — local file system
- `onedrive_cloud.dart` — OneDrive via OAuth
- `dropbox_cloud.dart` — Dropbox via OAuth
- `lorem_cloud.dart` — demo/test provider with sample data

Adding a new storage provider means implementing the `Cloud` interface and registering it in `SettingService`.

### Encryption

Vault files use AES-256-CBC with PKCS7 padding. Key derivation is PBKDF2 (SHA-256, configurable iterations). The binary format is documented in `docs/file-format.md`. All encrypt/decrypt logic lives in `CurrentFileService` (`blastmodel/lib/currentfile_service.dart`).

### Singleton Services

`CurrentFileService` and `SettingService` use the factory-constructor singleton pattern:

```dart
static final CurrentFileService _instance = CurrentFileService._internal();
factory CurrentFileService() => _instance;
```

### Platform-Specific Code

Conditional imports handle platform differences (web vs. mobile/desktop):

```dart
import 'stub.dart'
    if (dart.library.html) 'web_impl.dart'
    if (dart.library.io) 'mobile_impl.dart';
```

This pattern appears in `specific/desktopwindow/` and `specific/win32register/` (blastapp), and `specific/blastoauth/` (blastmodel).

## Conventions

### JSON Serialization

Model classes use `json_serializable` with **PascalCase** field renaming:

```dart
@JsonSerializable(fieldRename: FieldRename.pascal, explicitToJson: true)
```

This matches the vault file's JSON schema (e.g., `Title`, `IsFavorite`, `LastUpdateDateTime`).

### Reusable Widgets

Custom widgets live in `blastapp/lib/blastwidget/` with the `blast_` prefix (e.g., `blast_card.dart`, `blast_edit_button.dart`). Helper dialogs and utilities go in `blastapp/lib/helpers/`.

### Theming

`BlastTheme` in `blast_theme.dart` defines `light` and `dark` themes using Material 3 with `Colors.blueGrey` as the seed color. Access theme data via `BlastWidgetFactory`, not directly.

### Exception Hierarchy

All domain exceptions extend `BlastException` in `blastmodel/lib/exceptions.dart`. Named by cause: `BlastWrongPasswordException`, `BlastUnknownFileVersionException`, etc.

### Secrets / OAuth Setup

OAuth client IDs are stored in `blastmodel/lib/secrets.dart` (gitignored). The template is `secretsToFill.dart`. For local development, copy `secretsToFill.dart` to `secrets.dart`, rename the class from `SecretsToFill` to `Secrets`, and fill in your own OAuth app IDs. CI does this automatically via sed in the workflow.

## Secondary Components

- **pazword-converter** (`code/pazword-converter/`): A C# console tool for converting legacy vault formats. Not part of the Flutter build.
- **store-presence**: App store listing assets (screenshots, icons) for Android, iOS, macOS, and Windows.
- **import-file-samples**: Sample files for testing import from KeePass XML, Password Safe XML, and CSV.

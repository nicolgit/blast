These are the instructions for setting up cloud connections.

# OneDrive FULL ACCESS Setup
Go to Microsoft Entra id > App Registrations > + New Registration
* Name: `blastapp - full access`
* Supported account types: `Personal Microsoft Account Only`
* click [Registrer]

Go to Microsoft Entra id > API permissions > add a permission

* Microsoft Graph
* Select Permisssion: `Files.ReadWrite`
* click [add permission]
  
Go to Microsoft Entra id > App Registrations > all apps > `blastApp`
copy ApplicationId (ClientId) into [secrets.dart](/code/app/blastmodel/lib/secrets.dart) file, in `oneDriveApplicationId` field.

Go to Microsoft Entra id > App Registrations > all apps > `blastApp` > Authentication > platform configurations > add a platform:
* platform: `mobile and desktop`
* redirect URI: `blastapp://auth` 
* click [configure]

Go to Microsoft Entra id > App Registrations > all apps > `blastApp` > Authentication > platform configurations > add a platform:
* platform: `Single-page application`
* redirect URI: `https://blast.duckiesfarm.com/auth-landing.html`  
* redirect URI: `http://localhost:5555/auth-landing.html` (*)
* click [configure]

> (*) this is required only for local debugging. for debug in VS code locally add also the following in `.vscode/launch.json` file

```
{
    "name": "blastapp (web port 5555)",
    "cwd": "blastapp",
    "request": "launch",
    "type": "dart",
    "args": ["-d", "chrome","--web-port", "5555"],
},

```

# OneDrive - single folder access
same as above but with:
* name: blastapp
* Go to Microsoft Entra id > API permissions > add a permission > Microsoft Graph > `Files.ReadWrite.AppFolder`

# Dropbox setup

Blast offers two independent Dropbox connections:

| Provider | Stored identifier | Dropbox registration |
| --- | --- | --- |
| Dropbox full access | `DROPBOX` (existing, preserved) | Existing Scoped access / Full Dropbox app |
| Dropbox app folder | `DROPBOXFOLDER` (new) | Separate Scoped access / App folder app |

Keep the existing Full Dropbox app, App Key, permissions, and configuration unchanged. Existing connections and recent-file entries remain associated with `DROPBOX`. Selecting the app-folder provider does not migrate files or make existing full-access files available in the app folder.

## Separate App folder registration

A maintainer must create and maintain this registration externally in the [Dropbox App Console](https://www.dropbox.com/developers/apps); changing the code or OAuth scopes does not create it.

1. Choose **Create app** > **Scoped access** > **App folder**.
2. Choose a distinct app name and create the app.
3. Under **Permissions**, enable at least:
   - `files.metadata.read`
   - `files.content.read`
   - `files.content.write`
4. Under **Settings**, allow public clients and register the exact redirect URIs used by each build:
   - `blastapp://auth` (native)
   - `https://blast.duckiesfarm.com/auth-landing.html` (production web)
   - `http://localhost:5555/auth-landing.html` (only if local web debugging is used; see the port configuration above)
   - The actual `https://<deployment-domain>/auth-landing.html` URI for every additional deployed web domain in use, including Azure preview or custom domains.

Dropbox enforces the app-folder boundary on its servers through this registration. The API root is the empty string `''`, relative to the app's namespace; do not hardcode an `/Apps/...` path or treat a UI folder filter as access enforcement.
See the [Dropbox OAuth guide, Content Access](https://docs.dropboxapi.com/dropbox-api/docs/oauth) for the distinction between Full Dropbox and App folder registrations.

## App Key and deployment configuration

Use the registration's **App Key**, a public OAuth client identifier, not its client secret. Do not embed a Dropbox client secret in the app or deployment configuration.

- For local builds, copy `code/app/blastmodel/lib/secretsToFill.dart` to the gitignored `secrets.dart`, rename `SecretsToFill` to `Secrets`, and set `dropboxFolderApplicationId` to the new App Key. Its template placeholder is `DROPBOX_FOLDER_APPLICATION_ID`.
- Set the repository Actions secret `DROPBOX_FOLDER_APPLICATION_ID` to that same App Key for **both** deployment workflows: `.github/workflows/deploy-purple-flower.yml` and `.github/workflows/azure-static-web-apps-ashy-bush-0ee900a10.yml`. Both must substitute the placeholder when generating `secrets.dart`.
- Leave `dropboxApplicationId` / `DROPBOX_APPLICATION_ID` pointing to the existing Full Dropbox app.

An empty, unreplaced, or malformed App Folder key is reported when connecting; Blast never falls back to the Full Dropbox key. For account-free automated checks, generate the ignored `secrets.dart` from the template with distinct non-sensitive alphanumeric test keys and use mocked OAuth/API calls.

The providers keep separate OAuth instances and recent-file identifiers, even for identical paths. Newly saved biometric data includes provider-binding metadata in secure storage; it is not reused by another provider. Legacy biometric entries remain usable by existing providers but cannot authorize `DROPBOXFOLDER`; unlock that provider normally and enable biometric access again. Vault files, serialized model classes, and the platform keychain storage name are unchanged.

Before release, the maintainer must check the new registration's linked test accounts, development-mode user restrictions, and distribution/production approval requirements in Dropbox. An App Key alone does not establish that other users can authorize the app.

## Maintainer verification pending

No live Dropbox testing has been performed for this change. Using authorized test accounts, a maintainer must verify:

- Web and native login for each provider, including the configured redirects.
- Creating, reopening, and editing a vault; recent-file reopening; and browsing/using subfolders.
- Real API requests outside the app folder are denied or inaccessible under app-folder authorization, not merely hidden by the UI.
- Cached listings and credentials are isolated between providers and cleared appropriately on logout.
- Biometric reopening uses the selected provider's credentials; denied consent, cancellation, and revoked credentials do not switch access contexts.
- Existing Full Dropbox login, files, recent entries, and other legacy behavior remain unchanged; no file migration occurs.

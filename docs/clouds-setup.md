These are the instructions for setting up cloud connections.

# OneDrive Setup
Go to Microsoft Entra id > App Registrations > + New Registration
* Name: `blastApp`
* Supported account types: `Personal Microsoft Account Only`
* click [Registrer]
  
Go to Microsoft Entra id > App Registrations > all apps > `blastApp`
copy Application (Client) Id to [secrets.dart](/code/app/blastmodel/lib/secrets.dart) in `oneDriveApplicationId` field

Go to Microsoft Entra id > App Registrations > all apps > `blastApp` > Authentication > platform configurations > add a platform:
* platform: `mobile and desktop`
* redirect URI: `blastapp://auth`  (for windows client app)
* click [save]

Go to Microsoft Entra id > API permissions > add a permission

* Microsoft Graph
* Select Permisssion: `Files.ReadWrite`
* click [add permission]
These are the instructions for setting up cloud connections.

# OneDrive Setup
Go to Microsoft Entra id > App Registrations > + New Registration
* Name: `onedriveApp`
* Supported account types: `Personal Microsoft Account Only`
* click [Registrer]
  
Go to Microsoft Entra id > App Registrations > all apps > `onedriveApp`
copy Application (Client) Id to [secrets](/code/app/blastmodel/lib/secrets.dart) in `oneDriveApplicationId`

Go to Microsoft Entra id > App Registrations > all apps > `onedriveApp` > Authentication > platform configurations > add a platform:
* platform: `web`
* redirect URI: `http://localhost`
* click [save]

Go to Microsoft Entra id > API permissions > add a permission

* Microsoft Graph
* Select Permisssion: `Files.Read`
* click [add permission]
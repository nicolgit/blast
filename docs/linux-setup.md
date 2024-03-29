# Linux URL protocol handler setup

Blast for authentication to cloud storages that support OAUTH2/OIDC, needs to open a browser to allow the user to enter password, the second factor for MFA etc. Once the authentication flow is completed, the browser must pass back to Blast with the information collected. This flow is implemented on Linux through a custom URL protocol handler.

Below are the necessary steps for its correct configuration.

* Modify the file `blastapp.desktop` in this folder by replacing the content of the EXEC line with the full path of the Blast executable
* Copy file `blastapp.desktop` in `~/.local/share/applications/`.

```
cp blastapp.desktop ~/.local/share/applications/
```

* register the application with `blastapp` MIME type usign the following command: 

```
xdg-mime default blastapp.desktop x-scheme-handler/blastapp
sudo update-desktop-database
```

* check if the custom url is working with the following command:

```
xdg-open "blastapp://hello-world"
```

If everything is configured properly Blast is opened.

More info

* https://unix.stackexchange.com/questions/497146/create-a-custom-url-protocol-handler 
 



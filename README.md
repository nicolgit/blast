![blast!](images/icon-v01.png)
# 💥 Blast 💥
your passwords: safe and sound.

# What is Blast?
Blast is an open-source password and secrets keeper developed in Flutter. It can be used on Android, iOS, Windows, Web, Linux, and Mac. It stores your passwords in an encrypted file, allowing you to remember only one password (the "master password") instead of all the username/password combinations that you use.

You can find latest web version at https://blast.duckiesfarm.com

Binaries for all the supported platform will be available in the future on their public store and/or here.

Blast doesn't require its own cloud to work. It's designed to use your favorite cloud as a backend. All your data is keep in one single file protected by a master password. The file is an easily extendable .json format. Before being saved, it is ciphered using the 256-bit AES (Advanced Encryption Standard).

File format is documented [here](docs/file-format.md).



# Use Blast

* web ![web build](https://github.com/nicolgit/blast/actions/workflows/deploy-purple-flower.yml/badge.svg)  


# Supported feature by platform
Objective is to support all the most used cloud storage. Not all cloud storage are implemented and tested on all platforms. In the following table you can see current supported storages.

| storage             | android | ios | linux | mac | web | windows |
|---------------------|---------|-----|-------|-----|-----|---------|
| local file system   |         |     | 👍    | 👍  |     | 👍      |
| OneDrive            |         |     | 👍    | 👍  | 👍   | 👍      |
| DropBox             |         |     |       |     |     |         |
| Azure Storage       |         |     |       |     |     |         |
| AWS S3              |         |     |       |     |     |         |
| Google Drive        |         |     |       |     |     |         |
| iCloud              |         |     |       |     |     |         |
| Lorem Cloud (*)     | 👍      | 👍   | 👍    | 👍  | 👍   | 👍      | 
(*) fake cloud, for testing purpose only.


Here the list of feature available on all platforms.

* advanced search capability and sorting
* favorite flag
* tags
* dynamic list of attribute for each blast card
* number of card limited by the device memory
* number of attributes for each blast card limited by the device memory
* import data from other password managers:
  * [Keepass](https://keepass.info/) XML (2.x) file 
  * [Password Safe](https://pwsafe.org/) XML file   

Not al feature are available everywhere here the current platform < - > feature mapping

| feature                     | android | ios | linux | mac | web | windows |
|-----------------------------|---------|-----|-------|-----|-----|---------|
| export blast readable json  | 🔹      | 🔹   | 🔹    | 👍  | 🔹  | 🔹       |
| import blast readable json  | 🔹      | 🔹   | 👍    | 👍  |     | 👍       |

👍 supported 🔹 planned

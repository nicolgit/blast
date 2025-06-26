# Introduction

Welcome to Blast, an open-source password and secrets keeper developed in Flutter. We value your privacy and are committed to protecting your personal data. This privacy policy explains how we collect, use, and share information about you when you use our app.

# Information we collect

Blast is an open-source project, we do not collect, store, or transmit any personal data from users. All data handling follows these principles:

## Data Storage Location
- **Local Storage**: All data is kept locally on your device's secure application directory
- **Cloud Storage** (optional): If you choose to use cloud storage, your encrypted data is stored in your selected cloud service account (OneDrive, etc.)

## No Analytics or Tracking
We do not use any analytics services, crash reporting, or user tracking mechanisms. The app does not send any data to our servers or third-party services.

## Authentication Data
When using cloud storage services, authentication tokens are stored locally on your device and are only used to access your chosen cloud storage service. These tokens are not accessible to us.

# Optional Use of Cloud Storage

Blast offers optional integration with various cloud storage services to store your encrypted password file. Currently supported services include:

- **OneDrive**: Microsoft personal cloud storage
- **Local File System**: Data stored locally on your device
- **Lorem Cloud**: Testing environment only

Additional cloud storage providers (DropBox, Azure Storage, AWS S3, Google Drive, iCloud) are planned for future releases.

## OneDrive Integration
If you choose to use OneDrive, the app will request access to your Microsoft account with the following permissions:
- `Files.ReadWrite`: To save and retrieve your encrypted password file
- `openid` and `profile`: For authentication purposes only

This access is used solely for storing and managing your password file. We do not access any other files or data in your OneDrive account.

## Local Storage
When using local file system storage, your encrypted password file is stored in your device's application documents directory and is only accessible by the Blast application.

# Data Security

We implement multiple layers of security to protect your data:

## Encryption
- All passwords and secrets are encrypted using **256-bit AES (Advanced Encryption Standard)**
- Your master password is used as the encryption key and is never stored anywhere
- Encrypted data is stored in a single JSON ecrypted file that can be easily backed up or transferred

## Platform Security
- The app uses platform-specific secure storage mechanisms
- Authentication tokens for cloud services are stored using your device's secure storage
- Local files are stored in application-specific directories with appropriate access controls

## Network Security
- All communications with cloud storage services use HTTPS encryption
- No data is transmitted to Blast servers (we don't have any)
- Authentication flows follow OAuth 2.0 security standards

# Third-Party Services

## Cloud Storage Providers
Blast integrates with third-party cloud storage services only when you explicitly choose to use them. These integrations are:

- **Microsoft OneDrive**: Uses Microsoft Graph API for file storage
- **Future Services**: Additional cloud providers may be added (DropBox, Google Drive, iCloud, etc.)

## What Data is Shared
- Only your encrypted password file is stored in your chosen cloud service
- Authentication is handled directly between you and the cloud provider
- We never have access to your cloud storage credentials or unencrypted data

## Third-Party Privacy
When using cloud storage, you are also subject to the privacy policies of those providers:
- [Microsoft Privacy Statement](https://privacy.microsoft.com/privacystatement) (for OneDrive users)

## No Other Third-Party Services
Blast does not use:
- Analytics services
- Crash reporting services
- Advertising networks
- Social media integrations
- Third-party authentication providers (beyond cloud storage OAuth)

# User Rights

As a user, you have full control over your data. You can view, edit, and delete your data at any time. Since we do not collect any personal data, there is no need for data access or portability requests.

# Changes to This Privacy Policy

## Update Notifications
We may update this privacy policy to reflect changes in:
- Supported cloud storage providers
- Platform availability
- Security improvements
- Legal requirements

## How You'll Be Notified
- Changes will be posted in this GitHub repository
- Significant changes will be highlighted in app release notes
- **Effective Date**: This policy is effective as of June 26, 2025

## Version History
- Users can view the complete change history of this policy through GitHub's version control
- Previous versions remain accessible for reference

# Contact Us

## Questions or Concerns
If you have any questions or concerns about this privacy policy or the app's privacy practices:

- **GitHub Issues**: Open an issue in the [Blast repository](https://github.com/nicolgit/blast)
- **Security Issues**: For security-related concerns, please use GitHub's private vulnerability reporting
- **General Questions**: Use the GitHub Discussions feature for community support

## Response Time
- We aim to respond to privacy-related inquiries within 7 business days
- Security issues will be prioritized and addressed as quickly as possible

## Open Source Community
- This project is maintained by the open-source community
- Privacy improvements and suggestions are welcome through pull requests

# Platform Information

Blast is available on multiple platforms with consistent privacy practices:

## Supported Platforms
- **Desktop**: Windows, macOS, Linux
- **Mobile**: Android, iOS
- **Web**: Browser-based version at https://blast.duckiesfarm.com

## Platform-Specific Considerations
- **Web Version**: Uses browser's secure storage for temporary data; no data persists after logout
- **Desktop/Mobile**: Uses platform-specific secure storage mechanisms
- **All Platforms**: Same encryption and security standards apply

# Data Retention and Deletion

## Your Control Over Data
- You have complete control over your data at all times
- Data can be deleted by removing the encrypted file from your chosen storage location
- No data retention on our end since we don't store your data

## Account Deletion
- To stop using Blast: simply uninstall the application
- To delete cloud-stored data: remove the encrypted file from your cloud storage
- Authentication tokens can be revoked through your cloud provider's account settings

# Legal Basis and Compliance

## Open Source Nature
- Blast is an open-source project available on GitHub
- Source code can be audited by anyone
- No commercial data collection or processing

## Jurisdiction
- As an open-source project, Blast operates under software licensing terms
- Users are responsible for compliance with local data protection laws when choosing cloud storage providers

## Children's Privacy
- Blast does not knowingly collect any information from children under 13
- The app is designed for general password management use

# Data Import and Export

## Data Portability
- Your data is stored in an easily readable JSON format
- Export functionality available on supported platforms
- Import from other password managers (KeePass, Password Safe) supported

## No Vendor Lock-in
- Your encrypted file can be moved between different cloud providers
- App can be used entirely offline with local storage
- No proprietary formats that tie you to our services

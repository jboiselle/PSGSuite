# Third-Party Notices

This repository redistributes the following third-party .NET assemblies in
binary form under [`PSGSuite/lib`](PSGSuite/lib). They are downloaded from
[nuget.org](https://www.nuget.org) by [`tools/Update-GoogleSDK.ps1`](tools/Update-GoogleSDK.ps1)
and committed so that the module can be built without network access. Each
assembly remains subject to its own license, listed below.

## Google API Client Libraries for .NET

- **Assemblies:** `Google.Apis.dll`, `Google.Apis.Auth.dll`, `Google.Apis.Core.dll`,
  and the `Google.Apis.*` API-specific client assemblies (Admin Directory, Admin
  Reports, Admin DataTransfer, Calendar, Classroom, Docs, Drive, DriveActivity,
  Gmail, Groups Settings, Hangouts Chat, Licensing, OAuth2, People Service,
  Script, Sheets, Slides, Tasks)
- **Copyright:** Google LLC
- **License:** [Apache License 2.0](https://github.com/googleapis/google-api-dotnet-client/blob/main/LICENSE)
- **Source:** <https://github.com/googleapis/google-api-dotnet-client>

## Bouncy Castle C# API

- **Assembly:** `BouncyCastle.Crypto.dll` (1.8.1)
- **Copyright:** The Legion of the Bouncy Castle Inc.
- **License:** [Bouncy Castle License](https://www.bouncycastle.org/licence.html) (an adaptation of the MIT License)
- **Source:** <https://github.com/bcgit/bc-csharp>

## MimeKit

- **Assembly:** `MimeKit.dll` (1.10.1)
- **Copyright:** Xamarin Inc. and Jeffrey Stedfast
- **License:** [MIT License](https://github.com/jstedfast/MimeKit/blob/master/LICENSE)
- **Source:** <https://github.com/jstedfast/MimeKit>

## Json.NET

- **Assembly:** `Newtonsoft.Json.dll` (12.0.3)
- **Copyright:** James Newton-King
- **License:** [MIT License](https://github.com/JamesNK/Newtonsoft.Json/blob/master/LICENSE.md)
- **Source:** <https://github.com/JamesNK/Newtonsoft.Json>

---

PSGSuite also depends on the [`Configuration`](https://github.com/PoshCode/Configuration)
PowerShell module (MIT License), which is not bundled in this repository; it is
installed from the PowerShell Gallery at build/import time.

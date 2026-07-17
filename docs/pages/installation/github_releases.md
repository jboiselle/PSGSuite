# GitHub Releases Page

???+ warning
    This fork does not currently publish GitHub releases. The releases linked
    below belong to the upstream SCRT-HQ project, which is no longer maintained
    and does not include this fork's changes. To install this fork, see
    [Building From Source](building_from_source.md).

???+ info
    The GitHub releases page will likely be the same as the PowerShell Gallery. However, if you are looking for a specific version or a pre-release version, you may find it here first.

???+ warning
    You **must** have the module 'Configuration' installed as a prerequisite. Installing the module from the repo source or the release page does not automatically install dependencies.

1. Navigate to the [releases page](https://github.com/SCRT-HQ/PSGSuite/releases).
1. Expand `Assets` and download `PSGSuite.zip`.
1. Unblock the zip file before unzipping it - this is to prevent from having to unblock each file individually after unzipping.

    ```powershell {linenums="1"}
    Unblock-File -Path C:\Path\To\PSGSuite.zip -Verbose
    ```

1. Unzip the archive.
1. Place the module somewhere in `$env:PSModulePath`.

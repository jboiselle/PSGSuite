# Powershell Gallery

???+ warning
    This fork is **not** published to the PowerShell Gallery. The `PSGSuite`
    package on the Gallery is the upstream SCRT-HQ release, which is no longer
    maintained and does not include this fork's changes. To install this fork,
    see [Building From Source](building_from_source.md).

* [PowerShell Gallery](https://www.powershellgallery.com/packages/PSGSuite)

## Powershell Gallery Requirements

* [PowershellGet Module](https://learn.microsoft.com/en-us/powershell/module/powershellget/?view=powershellget-3.x)
    * Available in Windows 10 and later
    * Available in [Windows Management Framework 5.0](http://aka.ms/wmf5download)
    * Available in the PowerShell 3 and 4 MSI-based installer

???+ info

    Powershell Gallery versions might not include *all* pre-release versions. Please visit [GitHub Releases](../installation/github_releases.md) for versions that might not be available in the gallery.

```powershell {linenums="1"}
Install-Module -Name PSGSuite -Scope CurrentUser
```

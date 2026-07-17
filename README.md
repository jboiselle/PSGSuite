# PSGSuite

> [!CAUTION]
>
> PSGSuite 3.0.0 and later **requires** PowerShell 7.4 or newer

> [!NOTE]
>
> This is an independently maintained fork of
> [SCRT-HQ/PSGSuite](https://github.com/SCRT-HQ/PSGSuite), originally created
> by Nate Ferrell (SCRT HQ). The upstream project is no longer actively
> maintained; this fork exists to keep the module working. Many thanks to the
> original authors and contributors — PSGSuite is distributed under the
> [Apache 2.0 license](LICENSE) with attribution retained in [NOTICE](NOTICE).

***

PSGSuite is a PowerShell module wrapping Google's .NET SDKs in handy
functions, enabling everything from Google Workspace SuperAdmins automating
the administration of their multi-domain accounts down to individual Google
account users sending Gmail messages or uploading content to Drive.

## Installation

This fork is built from source — it is not published to the PowerShell
Gallery. The Google SDK assemblies are committed to the repo, so building
requires no network access (the `Configuration` module dependency is
installed from the PowerShell Gallery automatically if missing):

```powershell
git clone https://github.com/jboiselle/PSGSuite.git
cd PSGSuite
./build.ps1   # compiles to BuildOutput/PSGSuite and imports it
```

To use the compiled module in other sessions, either import it by path:

```powershell
Import-Module ./BuildOutput/PSGSuite
```

or copy `BuildOutput/PSGSuite` into a directory on your `$env:PSModulePath`.

## Building and testing

| Command | What it does |
| --- | --- |
| `./build.ps1` | Compile the module and import it into the current session |
| `./build.ps1 -Task Test` | Compile the module and run the Pester test suite |
| `./tools/Update-GoogleSDK.ps1` | Refresh the committed Google SDK DLLs in `PSGSuite/lib` from NuGet |

## Documentation

The upstream documentation at [psgsuite.io](https://psgsuite.io/) remains the
best reference for [configuration](https://psgsuite.io/pages/configuration)
and per-function help. The same function help pages are in this repo under
[docs/pages/function_help](docs/pages/function_help).

## Contributing

See the [Contribution Guidelines](CONTRIBUTING.md) and please adhere to the
[Code of Conduct](CODE_OF_CONDUCT.md) when interacting with this repo.

## License

[Apache 2.0](LICENSE). Attribution for the original work is retained in
[NOTICE](NOTICE); licenses for the bundled third-party assemblies are listed
in [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).

## Changelog

[Full CHANGELOG here](CHANGELOG.md)

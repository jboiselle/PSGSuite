# Building From Source

???+ note
    Building from source is the standard way to install this fork of PSGSuite —
    it is not published to the PowerShell Gallery. The Google SDK assemblies are
    committed to the repo, so building requires no network access. The
    `Configuration` module dependency is installed from the PowerShell Gallery
    automatically if it is missing.

1. Clone the repo locally:

```{linenums="1"}
git clone https://github.com/jboiselle/PSGSuite.git
```

1. Navigate to the cloned repo:

```{linenums="1"}
cd //path/to/PSGSuite
```

1. To build the module locally to test changes run `build.ps1` at the root of the repo (this also imports the compiled module into the current session):

```powershell {linenums="1"}
./build.ps1
```

1. To run the Pester tests locally to test changes run `build.ps1` with the `-Task` parameter set to `Test` at the root of the repo:

```powershell {linenums="1"}
./build.ps1 -Task Test
```

1. To import the compiled module in a new session, run the following from the root of the repo:

```powershell {linenums="1"}
Import-Module ./BuildOutput/PSGSuite -Force
```

# Contributing to PSGSuite

Thank you for your interest in helping PSGSuite grow! Below you'll find some guidelines around developing additional features and squashing bugs, including some how-to's to get started quick, general style guidelines, etc.

> [!NOTE]
> This repository is an independently maintained fork of [SCRT-HQ/PSGSuite](https://github.com/SCRT-HQ/PSGSuite). See the [README](README.md) and [NOTICE](NOTICE) for details.

<!-- no toc -->
- [Git and Pull requests](#git-and-pull-requests)
- [Overview](#overview)
    - [Code Guidelines](#code-guidelines)
    - [Documentation Guidelines](#documentation-guidelines)
        - [Requirements](#requirements)
        - [Setting up MkDocs Locally](#setting-up-mkdocs-locally)
- [Getting Started](#getting-started)
    - [Building and Testing](#building-and-testing)
    - [Updating the Google SDK Assemblies](#updating-the-google-sdk-assemblies)
    - [Google .NET SDK Documentation](#google-net-sdk-documentation)
- [Keeping in Touch](#keeping-in-touch)

## Git and Pull requests

- Contributions are submitted, reviewed, and accepted through **GitHub Pull Requests**:
    - Learn more about it [here](https://help.github.com/articles/using-pull-requests).
- We follow the **Fork and Pull** model.
    - Learn more about it [here](https://guides.github.com/activities/forking/).
- When submitting a pull request, ensure the `Allow edits from maintainers` option is checked. This allows maintainers to make necessary edits directly to your branch and include them in the same pull request.
    - Learn more about it [here](https://help.github.com/articles/allowing-changes-to-a-pull-request-branch-created-from-a-fork/#enabling-repository-maintainer-permissions-on-existing-pull-requests).

## Overview

Here's the overall flow of making contributions:

1. Fork the repo
2. Make your edits / additions on your fork
3. Push your changes back to your fork on GitHub
4. Submit a pull request
5. Pull request is reviewed. Any necessary edits / suggestions will be made
6. Once changes are approved and CI tests pass, the pull request is merged into the main branch

### Code Guidelines

Please follow these guidelines for any content being added:

- **ALL functions must...**
    - Work in the supported PowerShell versions by this module
    - Work in any OS;
        - Any code that includes paths must build the path using OS-agnostic methods, i.e. by using `Resolve-Path`, `Join-Path` and `Split-Path`
        - Paths also need to use correct casing, as some OS's are case-sensitive in terms of paths
- **Public functions must...**
    - Include comment-based help (this drives the function help documentation)
    - Include Write-Verbose calls to describe what the function is doing (CI tests will fail the build if any don't)
    - Be placed in the correct API/use-case folder in the Public sub-directory of the module path (if it's a new API/use-case, create the new folder as well)
    - Use `SupportsShouldProcess` if...
        - The function's verb is `Remove` or `Set`.
        - It can be included on `Update` functions as well, if felt that the actions executed by the function should be guarded
        - `Get` functions should **never** need `SupportsShouldProcess`
- **License notices:** this project is distributed under the Apache License 2.0. Changes to files inherited from upstream are recorded in git history; if you substantially rewrite an upstream file, add a short modification notice to its header (see `build.ps1` for an example).
- **Every Pull Request must...**
    > [!NOTE]
    > These can be added in during the pull request review process, but are nice to have if possible

    - Have the module version bumped appropriately in the manifest (Major for any large updates, Minor for any new functionality, Patch for any hotfixes)
    - Have an entry in the Changelog describing what was added, updated and/or fixed with this version number
        > [!NOTE]
        > Please follow the same format already present

### Documentation Guidelines

The PSGSuite documentation site is built using MkDocs. Follow these steps to spin up MkDocs locally, make changes, and preview your updates before submitting them.

#### Requirements

- Python (version 3.7 or higher):
    - Download and install Python from [python.org](https://python.org).
    - Ensure `pip` (Python's package manager) is installed and available in your `PATH`.
- MkDocs and Dependencies:
    - Install MkDocs and its dependencies using the provided `requirements.txt` file.

#### Setting up MkDocs Locally

- Fork the PSGSuite repository
- Clone your forked repository to your local machine

```plaintext
git clone https://github.com/<your-username>/PSGSuite.git
```

- Navigate to the cloned repository directory

```plaintext
cd //path/to/PSGSuite
```

1. Install dependencies

```plaintext
pip install -r requirements.txt
```

1. Start the MkDocs development server and navigate to `http://127.0.0.1:8000` in your web browser

```plaintext
mkdocs serve
```

1. Make your edits and submit a pull request

> [!NOTE]
>
> The function help pages under `docs/pages/function_help` were previously regenerated automatically by the upstream deployment pipeline. That pipeline has been removed in this fork, so updates to comment-based help should be reflected in the corresponding Markdown page manually (or via `platyPS`) when relevant.

## Getting Started

### Building and Testing

The build is a single self-contained script — no build frameworks or NuGet restores involved. The Google SDK assemblies the module depends on are committed under `PSGSuite/lib`, so building works offline (the `Configuration` module dependency is installed from the PowerShell Gallery automatically if missing):

```powershell
# Compile the module to BuildOutput/PSGSuite and import it into the current session
./build.ps1

# Compile the module and run the full Pester test suite against it
./build.ps1 -Task Test
```

A few things worth knowing:

- The compiled module is a single `psm1` built by concatenating everything under `PSGSuite/Private` and `PSGSuite/Public`, so functions live one-per-file in source and the file name must match the function name (the build exports functions by file name).
- The test suite is written for **Pester 4** (`build.ps1` installs 4.10.1 if needed); Pester 5 syntax will not work in test files.
- The test harness sets the global `$ErrorActionPreference` to `Stop` for the duration of the run — module functions branch on it to decide between throwing and writing a non-terminating error, and the tests expect the throwing behavior.

### Updating the Google SDK Assemblies

To pick up newer Google SDK releases, refresh the committed DLLs and commit the result:

```powershell
./tools/Update-GoogleSDK.ps1
./build.ps1 -Task Test   # verify before committing
```

### Google .NET SDK Documentation

PSGSuite uses Google's .NET SDK's for 99% of its functions. The easiest way to pull up the documentation for the function you are writing is by visiting Google's API .NET [GitHub repository](https://github.com/googleapis/google-api-dotnet-client). Scroll down to [`API-specific Libraries`](https://github.com/googleapis/google-api-dotnet-client?tab=readme-ov-file#api-specific-libraries) for more .NET SDK Documentation and API documentation.

## Keeping in Touch

For any questions, comments or concerns outside of opening an issue, please open a [GitHub issue](https://github.com/jboiselle/PSGSuite/issues) on this fork. For historical discussion of the upstream project, see the [SCRT-HQ/PSGSuite](https://github.com/SCRT-HQ/PSGSuite) repository.

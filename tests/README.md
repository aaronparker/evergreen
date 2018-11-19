# Pester Tests

Located here are a set of Pester tests to be used when testing the module locally or integrating with AppVeyor to implement tests for new builds and posting to the PowerShell Gallery.

* `Main.Tests.ps1` - Performs standard tests against all module functions for project and module validation (including PSScriptAnalyzer)
* `Module.Tests.ps1` - Tests the module manifest and tests that the module imports OK
* `PublicFunctions.Tests.ps1` - Pester tests for public functions
* `PrivateFunctions.Tests.ps1` - Pester tests for private functions
* `Build.ps1` - this script can be used locally to update the module manifest when adding new functions

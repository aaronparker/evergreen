Function Get-FunctionResource {
    <#
        .SYNOPSIS
            Reads the function strings from the JSON file and returns a hashtable.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNull()]
        [System.String] $AppName
    )
    
    # Setup path to the manifests folder and the app manifest
    $Path = Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "Manifests"
    $AppManifest = Join-Path -Path $Path -ChildPath "$AppName.json"

    # Read the content from the manifest file
    If (Test-Path -Path $AppManifest) {
        try {
            Write-Verbose -Message "$($MyInvocation.MyCommand): read application resource strings from [$AppManifest]"
            $content = Get-Content -Path $AppManifest -Raw -ErrorAction "Stop"
        }
        catch {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to read from: $AppManifest."
            Throw "$($MyInvocation.MyCommand): $($_.Exception.Message)."
        }
    }
    Else {
        Throw "$($MyInvocation.MyCommand): manifest does not exist: $AppManifest."
    }

    # Convert the content from JSON into a hashtable
    try {
        If (Test-PSCore) {
            $hashTable = $content | ConvertFrom-Json -AsHashtable -ErrorAction "Stop"
        }
        Else {
            $hashTable = $content | ConvertFrom-Json -ErrorAction "Stop" | ConvertTo-Hashtable
        }
    }
    catch {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to convert strings to required hashtable object."
        Throw "$($MyInvocation.MyCommand): $($_.Exception.Message)."
    }

    # If we got a hashtable, return it to the pipeline
    If ($Null -ne $hashTable) {
        Write-Output -InputObject $hashTable
    }
}

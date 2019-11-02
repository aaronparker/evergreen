Function Get-FunctionResource {
    <#
        .SYNOPSIS
            Reads the function strings from the JSON file and returns a hashtable.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.String] $AppName = "Template"
    )
    
    # Setup path to the manifests folder and the app manifest
    $Path = Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "Manifests"
    $AppManifest = Join-Path -Path $Path -ChildPath "$AppName.json"

    try {
        Write-Verbose -Message "$($MyInvocation.MyCommand): read module resource strings from [$AppManifest]"
        $content = Get-Content -Path $AppManifest -Raw -ErrorAction SilentlyContinue
    }
    catch [System.Exception] {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to read from: $AppManifest."
        Throw $_.Exception.Message
    }

    try {
        If (Test-PSCore) {
            $hashTable = $content | ConvertFrom-Json -AsHashtable -ErrorAction SilentlyContinue
        }
        Else {
            $hashTable = $content | ConvertFrom-Json -ErrorAction SilentlyContinue | ConvertTo-Hashtable
        }
    }
    catch [System.Exception] {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to convert strings to required object."
        Throw $_.Exception.Message
    }
    finally {
        If ($Null -ne $hashTable) {
            Write-Output -InputObject $hashTable
        }
    }
}

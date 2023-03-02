function Get-ESETServerSecurity {
    <#
        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Query the update feed
    $params = @{
        Uri         = $res.Get.Update.Uri
        ContentType = $res.Get.Update.ContentType
    }
    $Metadata = Invoke-RestMethodWrapper @params
    if ($null -ne $Metadata) {

        # Grab the JSON metadata from the returned object
        Write-Verbose -Message "$($MyInvocation.MyCommand): Filter for metadata and sorting updates."
        $InfoData = ('{' + $(([Regex]::Matches($Metadata, '(?<={)(.*?)(?=}],"switch")')).Value) + '}]}' | ConvertFrom-Json).info

        # Find all the supported languages because the versions can be different per language
        $Languages = $InfoData.Language | Select-Object -Unique
        Write-Verbose -Message "$($MyInvocation.MyCommand): Found $($Language.Count) languages."

        # Step through each of the supported languages
        foreach ($Language in $Languages) {

            # Find the latest version number of this language
            Write-Verbose -Message "$($MyInvocation.MyCommand): Filter on language: $Language."
            $Latest = $InfoData | Where-Object { $_.Language -eq $Language } | `
                Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $true } | `
                Where-Object { $_.OSType -eq "windows" } | `
                Select-Object -First 1

            Write-Verbose -Message "$($MyInvocation.MyCommand): Found product: $($Latest.Description)."
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $($Latest.Version)."

            # Find the files matching this version number for this language
            $Files = $InfoData | Where-Object { $_.Language -eq $Language } | `
                Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $true } | `
                Where-Object { $_.OSType -eq "windows" -and $_.Version -eq $Latest.Version }
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found $($Files.Count) files."

            # Filter the files for the updates we need
            $Updates = $Files | Where-Object { $_.Legacy -eq $False -and $_.OSNames -match $res.Get.Update.OS }
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found $($Updates.Count) individual update files."

            # Output the object to the pipeline
            foreach ($Update in $Updates) {
                $PSObject = [PSCustomObject] @{
                    Version      = $Update.Version
                    Size         = $Update.Size
                    Hash         = $Update.Hash
                    Language     = $Update.Language
                    Architecture = Get-Architecture -String $Update.Path
                    Type         = Get-FileType -File $Update.Path
                    URI          = $res.Get.Download.Uri -replace "#file", $Update.Path
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}

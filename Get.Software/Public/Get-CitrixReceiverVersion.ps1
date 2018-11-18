Function Get-CitrixReceiverVersion {
    <#
        .SYNOPSIS
            Gets the current available Citrix Receiver release versions.

        .DESCRIPTION
            Reads the public Citrix Receiver web page to return an array of Receiver platforms and the available versions.
            Does not provide the version number for Receiver where a login is required (e.g. HTML5, Chrome)

        .NOTES
            Name: Get-CitrixReceiverVersion.ps1
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://stealthpuppy.com/latest-receiver-version-powershell/

        .PARAMETER Url
            The URL to the Citrix Receiver download page. This should not need to be changed.

        .PARAMETER Platforms
            The target platform for the Citrix Receiver version number to return. If not specified, all platforms are returned.
            Can be one of: 'Windows', 'LTSR', 'Universal Windows Platform', 'Mac', 'iOS', 'Linux', 'Android', 'Desktop Lock'.

        .EXAMPLE
            Get-CitrixReceiverVersions

            Description:
            Returns the available Citrix Receiver versions for all platforms.

        .EXAMPLE
            Get-CitrixReceiverVersions -Platform Windows | Select-Object -First 1

            Description:
            Returns the latest available Citrix Receiver version available for Windows.
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    Param(
        [Parameter(Mandatory = $false)]
        [string]$Url = 'https://www.citrix.com/downloads/citrix-receiver/',

        [Parameter(Mandatory = $false)]
        [ValidateSet('Windows', 'Windows LTSR*', 'Universal Windows Platform', 'Mac', 'iOS', 'Linux', 'Android', 'Desktop Lock', 'Windows Desktop Lock')]
        [string[]]$Platforms = @('Windows', 'Windows LTSR*', 'Universal Windows Platform', 'Mac', 'iOS', 'Linux', 'Android', 'Desktop Lock', 'Windows Desktop Lock')
    )
    Begin {
        # RegEx to filter out all characters except the version number
        $RegExNumbers = "[^.0-9]"
        $RegExVersion = "\d+(\.\d+)+\s"
        $RegExAtag = "(<[a|A][^>]*>|</[a|A]>)"

        # Create an emtpy array from which we'll return receiver version links and ultimately all Receiver versions
        $innerHTML = @()
        $Receivers = @()
        $Versions = @()

        # Get the contents from $Url and return version descriptions for all Receiver platforms by filtering the text for each link where link includes 'Receiver'
        Write-Verbose "Reading from: $Url"
        Try { $ReceiverLinks = (Invoke-WebRequest -Uri $Url -ErrorAction SilentlyContinue).Links | Where-Object { $_.outerHTML -like "*>Receiver*" } }
        Catch { Write-Error $($_.Exception.Message) -ErrorAction Stop }
        If (!($ReceiverLinks)) { Write-Error "Unable to return HTML from URL $Url." -ErrorAction Stop }

        # Replace <a href> tags to leave innerHTML. Doing this to enable the function to work on PowerShell Core
        ForEach ($Link in $ReceiverLinks.outerHTML) {
            $innerHTML += $Link -replace $RegExAtag, ""
        }

        # Build the Receiver versions table by filtering text for Platform and version numbers for Version
        # Cast the version number string as a version so that we can sort correctly at output
        $Receivers += $innerHTML | Select-Object @{Name = "Platform"; Expression = {$_ -replace $RegExVersion}}, `
            @{Name = "Version"; Expression = {[Version]$($_ -replace $RegExNumbers)}}
    }
    Process {
        # Filter the $Receivers array to return a specific set of platforms (or by default, all platforms)
        If ($PSBoundParameters.ContainsKey('Platforms')) {
            ForEach ( $Platform in $Platforms ) {
                $Versions += $Receivers | Where-Object { $_.Platform -like "Receiver for $Platform" }
            }
        }
        Else {
            $Versions = $Receivers
        }
    }
    End {
        # Return the array, sorting by Platform and then platform version
        $output = $Versions | Sort-Object -Property Platform, @{Expression = 'Version'; Descending = $True}
        Write-Output $output
    }
}

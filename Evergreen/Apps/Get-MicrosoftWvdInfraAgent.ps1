Function Get-MicrosoftWvdInfraAgent {
    <#
        .SYNOPSIS
            Get the current version and download URL for the Microsoft Windows Virtual Desktop Infrastructure agent.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]),

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNull()]
        [System.String] $Filter
    )

    If (Test-PSCore) {
        # Grab the download link headers to find the file name
        try {
            #TODO: turn this into a function
            $tempFile = New-TemporaryFile
            $params = @{
                Uri             = $res.Get.Uri
                Method          = "Head"
                UseBasicParsing = $True
                ErrorAction     = $script:resourceStrings.Preferences.ErrorAction
            }
            (Invoke-WebRequest @params).RawContent | Out-File -FilePath $tempFile
        }
        catch {
            Throw "$($MyInvocation.MyCommand): Error at: $($res.Get.Uri) with: $($_.Exception.Response.StatusCode)"
        }

        # Convert to an object, without the first line
        $RawContent = Get-Content -Path $tempFile
        $Content = $RawContent | Select-Object -Skip 1 | ConvertFrom-StringData -Delimiter ":"

        If ($Content) {
            # Match filename
            $Filename = [RegEx]::Match($Content.'Content-Disposition', $res.Get.MatchFilename).Captures.Groups[1].Value

            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version      = [RegEx]::Match($Content.'Content-Disposition', $res.Get.MatchVersion).Captures.Value
                Architecture = Get-Architecture -String $Filename
                Date         = $Content.'Last-Modified'
                Size         = $Content.'Content-Length'
                Filename     = $Filename
                URI          = $res.Get.Uri
            }
            Write-Output -InputObject $PSObject
        }
        Else {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to return a header from $($res.Get.Uri)."
        }
    }
    Else {
        # Windows PowerShell
        # Grab the download link headers to find the file name
        try {
            $params = @{
                Uri             = $res.Get.Uri
                Method          = "Head"
                UseBasicParsing = $True
                ErrorAction     = $script:resourceStrings.Preferences.ErrorAction
            }
            $Content = (Invoke-WebRequest @params).RawContent
        }
        catch {
            Throw "$($MyInvocation.MyCommand): Error at: $($res.Get.Uri) with: $($_.Exception.Response.StatusCode)"
        }

        If ($Content) {
            # Match filename
            $Filename = [RegEx]::Match($Content, $res.Get.MatchFilename).Captures.Groups[1].Value

            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version      = [RegEx]::Match($Content, $res.Get.MatchVersion).Captures.Value
                Architecture = Get-Architecture -String $Filename
                Filename     = $Filename
                URI          = $res.Get.Uri
            }
            Write-Output -InputObject $PSObject
        }
    }
}

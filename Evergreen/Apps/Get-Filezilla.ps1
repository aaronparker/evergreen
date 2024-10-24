function Get-Filezilla {
    <#
        .SYNOPSIS
            Get the current version and download URI for FileZilla for Windows.

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
        Uri       = $res.Get.Update.Uri
        Headers   = $res.Get.Update.Headers
    }
    $Content = (Invoke-EvergreenWebRequest @params -ReturnObject All).Links

    # Convert the content to an object
    try {
        $Content.Where({ $_.href -match "^https" -and $_.href -match $res.Get.Update.MatchVersion -and $_.href -match $res.Get.Update.MatchArchitechture }).ForEach({
            $Url = $_.href
            If ($_.href  -match $res.Get.Update.MatchVersion) { 
                $version = $Matches[1]
            }
            
            $FileType = [System.IO.Path]::GetExtension($Url.split("?")[0])
            $FileName = [System.IO.Path]::GetFileName($Url.split("?")[0])
            $Architecture = Switch -Regex ($FileName)  {
                "_\w+64(\.|-)" { "x64" }
                "_\w+32(\.|-)" { "x86" }

            }

            $PSObject = [PSCustomObject] @{
                FileName     = $FileName
                Version      = $version
                Architecture = $Architecture
                Type         = $FileType.Trim(".")
                URI          = $Url
            }
             Write-Output -InputObject $PSObject
        })
       
    } catch [System.Exception] {
        throw $_
    }

}


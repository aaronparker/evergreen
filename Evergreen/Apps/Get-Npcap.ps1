Function Get-Npcap {
    <#
        .SYNOPSIS
            Returns the latest Npcap version number and download.

        .NOTES
            Author: Jasper Metselaar
            E-mail: jms@du.se
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )


    # Get latest version and download latest release via GitHub API
    $params = @{
        Uri          = $res.Get.Update.Uri
        ContentType  = $res.Get.Update.ContentType
        ReturnObject = "Content"
    }

    # Get only latest version tag from GitHub API
    $Content = ((Invoke-EvergreenWebRequest @params | ConvertFrom-Json).name -replace "v",""| ForEach-Object { New-Object -TypeName "System.Version" ($_) } | Sort-Object -Descending | Select-Object -First 1 | ForEach-Object {("{0}.{1}" -f $_.Major,$_.Minor)})

    if ($null -ne $Content) {
        $Content | ForEach-Object {
            $PSObject = [PSCustomObject] @{
                Version = $_
                Type    = "exe"
                URI     = $res.Get.Download.Uri -replace $res.Get.Download.ReplaceText, $_
            }
            Write-Output -InputObject $PSObject
        }
    }
}


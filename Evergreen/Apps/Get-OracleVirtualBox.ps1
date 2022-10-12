Function Get-OracleVirtualBox {
    <#
        .SYNOPSIS
            Get the current version and download URL for the XenServer tools.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    foreach ($Channel in $res.Get.Update.Uri.GetEnumerator()) {

        # Get latest VirtualBox version
        Write-Verbose -Message "$($MyInvocation.MyCommand): Check channel: $($Channel.Name)"
        $Version = Invoke-WebRequestWrapper -Uri $res.Get.Update.Uri[$Channel.Key]

        if ($Null -ne $Version) {

            $Version = $Version.Trim()
            Write-Verbose -Message "$($MyInvocation.MyCommand): Version: $Version"
            #$Version = [RegEx]::Match($Version, $res.Get.Download.MatchVersion).Captures.Groups[1].Value
            #Write-Verbose -Message "$($MyInvocation.MyCommand): RegEx version: $Version"
            Write-Verbose -Message "$($MyInvocation.MyCommand): $($res.Get.Download.Uri)$Version/"

            # Get the content from the latest downloads folder
            $iwrParams = @{
                Uri          = "$($res.Get.Download.Uri)$Version/"
                ReturnObject = "All"
            }
            $Downloads = Invoke-WebRequestWrapper @iwrParams
            if ($Null -ne $Downloads) {

                # Filter downloads with the version string and the file types we want
                $RegExVersion = $Version -replace ("\.", "\.")
                $MatchExtensions = $res.Get.Download.MatchExtensions -replace "Version", $RegExVersion
                $Links = $Downloads.Links.outerHTML | Select-String -Pattern $MatchExtensions

                # Construct an array with the version number and each download
                foreach ($link in $Links) {
                    $link -match $res.Get.Download.MatchDownloadFile | Out-Null
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Link: $link"
                    $Uri = "$($res.Get.Download.Uri)$Version/$($Matches[1])"

                    $PSObject = [PSCustomObject] @{
                        Version = $Version
                        Channel = $Channel.Name
                        Type    = [System.IO.Path]::GetExtension($Uri).Split(".")[-1]
                        URI     = $Uri
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
}

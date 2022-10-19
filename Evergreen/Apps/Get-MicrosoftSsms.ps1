Function Get-MicrosoftSsms {
    <#
        .SYNOPSIS
            Returns the latest SQL Server Management Studio

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification="Product name is a plural")]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Resolve the SSMS update feed
    $UpdateFeed = Resolve-SystemNetWebRequest -Uri $res.Get.Update.Uri

    # SQL Management Studio downloads/versions documentation
    $params = @{
        Uri = $UpdateFeed.ResponseUri.AbsoluteUri
    }
    $Content = Invoke-RestMethodWrapper @params

    If ($Null -ne $Content) {
        ForEach ($entry in $Content.component) {
            Write-Warning -Message "$($MyInvocation.MyCommand): Version returned from the update feed: $($entry.version). See $($script:resourceStrings.Uri.Issues) for more information."

            ForEach ($language in $res.Get.Download.Language.GetEnumerator()) {

                # Follow the download link which will return a 301
                $Uri = $res.Get.Download.Uri -replace $res.Get.Download.ReplaceText, $res.Get.Download.Language[$language.key]
                $ResponseUri = Resolve-SystemNetWebRequest -Uri $Uri

                # Check returned URL. It should be a go.microsoft.com/fwlink/?linkid style link
                If ($Null -ne $ResponseUri) {

                    # Construct the output; Return the custom object to the pipeline
                    $PSObject = [PSCustomObject] @{
                        Version  = $entry.version
                        Date     = ConvertTo-DateTime -DateTime ($Content.updated.Split(".")[0]) -Pattern $res.Get.Update.DatePattern
                        Language = $language.key
                        URI      = $ResponseUri.ResponseUri.AbsoluteUri
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
}

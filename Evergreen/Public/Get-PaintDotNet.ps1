Function Get-PaintDotNet {
    <#
        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Read the Paint.NET updates feed
    $Content = Invoke-WebRequestWrapper -Uri $res.Get.Uri
    If ($Null -ne $Content) {

        # Convert the content from string data
        $Data = $Content | ConvertFrom-StringData

        # Build the output object
        ForEach ($url in ($Data.("$($Data.StableVersions)$($res.Get.UrlProperty)") -split $res.Get.UrlDelimiter)) {
            $PSObject = [PSCustomObject] @{
                Version = $Data.($res.Get.VersionProperty)
                URI     = $url
            }
            Write-Output -InputObject $PSObject
        }
    }
}

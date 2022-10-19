Function Get-RStudio {
    <#
        .SYNOPSIS
            Returns the available RStudio version and download URI.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
            Based on Get-AtlassianBitbucket.ps1
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Read the update URI
    foreach ($branch in $res.Get.Update.Uri.GetEnumerator()) {
        $params = @{
            Uri = $res.Get.Update.Uri[$branch.Key]
        }
        $Content = Invoke-RestMethodWrapper @params

        # Read the JSON and build an array of platform, channel, version
        If ($Null -ne $Content) {

            # Step through each installer type
            foreach ($product in $res.Get.Update.Products) {
                foreach ($platform in $res.Get.Update.Platforms) {
                    foreach ($item in $Content.$product.platforms.$platform) {

                        # Build the output object; Output object to the pipeline
                        $PSObject = [PSCustomObject] @{
                            Version       = $item.version
                            Sha256        = $item.sha256
                            Size          = $item.size
                            Branch        = $branch.Name
                            Channel       = $item.channel
                            ProductName   = $Content.$product.name
                            InstallerName = $item.name
                            Type          = Get-FileType -File $item.link
                            URI           = $item.link
                        }
                        Write-Output -InputObject $PSObject
                    }
                }
            }
        }
        else {
            Write-Error -Message "$($MyInvocation.MyCommand): Unable to return usable content from: $($res.Get.Update.Uri[$branch.Key])."
        }
    }
}

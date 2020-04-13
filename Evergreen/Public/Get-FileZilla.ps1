Function Get-FileZilla {
    <#
        .SYNOPSIS
            Get the current version and download URI for FileZilla for Windows.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-FileZilla

            Description:
            Get the current version and download URI for FileZilla for Windows.
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Query the update feed
    $iwcParams = @{
        Uri              = $res.Get.Uri
        UserAgent        = $res.Get.UserAgent
        TrustCertificate = $True
    }
    $Content = Invoke-WebContent @iwcParams

    # Convert the content to an object
    try {
        $Update = ($Content | ConvertFrom-Csv -Delimiter $res.Get.Delimiter -Header $res.Get.Headers) | Where-Object { $_.Channel -eq $res.Get.Channel }
    }
    catch [System.Exception] {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to convert update feed."
        Break
    }

    # Output the object to the pipeline
    $PSObject = [PSCustomObject] @{
        Version = $Update.Version
        Size    = $Update.Size
        Hash    = $Update.Hash
        URI     = $Update.URI
    }
    Write-Output -InputObject $PSObject
}

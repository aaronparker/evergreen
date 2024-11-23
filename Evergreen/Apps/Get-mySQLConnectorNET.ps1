function Get-mySQLConnectorNET {
    <#
        .NOTES
            Author: BornToBeRoot
            Twitter: @BornToBeRoot
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "Product name is a plural")]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get latest repo tag
    $Tags = Get-GitHubRepoTag -Uri $res.Get.Update.Uri

    $Version = ($Tags | Sort-Object -Property @{ Expression = { [System.Version]$_.Tag }; Descending = $true } | Select-Object -First 1).Tag

    # Build the output object
    if ($Null -ne $Version) {
        foreach ($Architecture in $res.Get.Download.Uri.GetEnumerator()) {

            # https://dev.mysql.com/get/Downloads/Connector-ODBC/9.1/mysql-connector-odbc-9.1.0-winx64.msi
            # redirect to
            # https://cdn.mysql.com//Downloads/Connector-ODBC/9.1/mysql-connector-odbc-9.1.0-winx64.msi
            #
            # The sub path is only major.minor
            # The version ist major.minor.patch, while the tag can have also have major.minor.patch.build
            $Uri = $res.Get.Download.Uri[$Architecture.Key] -replace $res.Get.Download.ReplaceVersionShort, (($Version -split '\.')[0, 1] -join '.') -replace $res.Get.Download.ReplaceVersion, (($Version -split '\.')[0..2] -join '.')

            # The website/CDN checks the user agent, which means that the call from e.g. Azure Automation is only possible by overwriting it
            $CdnUri = (Invoke-WebRequest $Uri -MaximumRedirection 0 -UserAgent "Curl/8" -SkipHttpErrorCheck -ErrorAction:SilentlyContinue).Headers.Location[0]

            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Type         = Get-FileType -File $Uri
                Architecture = $Architecture.Name
                URI          = $CdnUri
            }
            Write-Output -InputObject $PSObject
        }
    }
}

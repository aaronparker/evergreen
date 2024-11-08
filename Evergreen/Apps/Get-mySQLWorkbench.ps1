function Get-mySQLWorkbench {
    <#
        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
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

            # https://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-workbench-community-8.0.40-winx64.msi
            # redirect to
            # https://cdn.mysql.com//Downloads/MySQLGUITools/mysql-workbench-community-8.0.40-winx64.msi
            #
            # The version ist major.minor.patch, while the tag can have also have major.minor.patch.build
            $Uri = $res.Get.Download.Uri[$Architecture.Key] -replace $res.Get.Download.ReplaceVersion, (($Version -split '\.')[0..2] -join '.')

            $CdnUri = (Invoke-WebRequest $Uri -MaximumRedirection 0 -SkipHttpErrorCheck -ErrorAction:SilentlyContinue).Headers.Location[0]

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

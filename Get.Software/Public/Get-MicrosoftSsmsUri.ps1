Function Get-MicrosoftSsmsUri {
    <#
        .SYNOPSIS
            Gets the latest SQL Server Management Studio release URI.

        .DESCRIPTION
            Gets the latest SQL Server Management Studio release URI.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
        
        .LINK
            https://github.com/aaronparker/Get.Software

        .PARAMETER Release
            Specify whether to return the GAFull, GAUpdate, or Preview release.

        .EXAMPLE
            Get-MicrosoftSsmsUri

            Description:
            Returns the latest SQL Server Management Studio for Windows download URI.

        .EXAMPLE
            Get-MicrosoftSsmsVersion -Release Preview

            Description:
            Returns the preview release SQL Server Management Studio for Windows download URI.
    #>
    [CmdletBinding()]
    [Outputtype([string])]
    param(
        [ValidateSet("GAFull","GAUpdate","Preview")]
        [string] $Release = "GAFull"
    )

    # SQL Management Studio downloads/versions documentation
    $url = "https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017"
    
    try {
        $response = Invoke-WebRequest -UseBasicParsing -Uri $url -ErrorAction SilentlyContinue
    }
    catch {
        Throw "Failed to connect to SSMS: $url with error $_."
        Break
    }
    finally {
        $interestingLinks = $response.links  | Where-Object {$_.outerHTML -like "*Download SQL Server Management Studio*"}
        switch ($Release) { 
            "GAFull" {
                $thislink = $interestingLinks | Where-Object {$_.outerHTML -notlike "*preview*" -and $_.outerHTML -notlike "*upgrade*"}
            };
            "GAUpdate" {
                $thislink = $interestingLinks | Where-Object {$_.outerHTML -like "*upgrade*"}
            };
            "Preview" {
                $thislink = $interestingLinks | Where-Object {$_.outerHTML -like "*preview*"}
            };
        }

        Write-Output $thislink.href 
    }
}

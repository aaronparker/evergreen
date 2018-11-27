Function Get-MicrosoftSsmsUri {
    <#
        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
    #>
    [CmdletBinding()]
    [Outputtype([string])]
    param(
        [ValidateSet("GAFull","GAUpdate","Preview")]
        [string] $Release = "GAFull"
    )

    $url = "https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017"
    try {
        $response = Invoke-WebRequest -UseBasicParsing -Uri $url -ErrorAction SilentlyContinue
    }
    catch {
        Throw "Failed to connect to SSMS: $url with error $_."
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

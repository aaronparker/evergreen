Function Get-CitrixRssFeed {
    <#
        .SYNOPSIS
            Get content from a citrix.com XML feed of notifications of new downloads.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy        
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNull()]
        [System.String] $Uri,

        [Parameter(Mandatory = $False, Position = 1)]
        [System.String] $Include,

        [Parameter(Mandatory = $False, Position = 2)]
        [System.String] $Exclude
    )

    # Read the Citrix RSS feed
    $Nodes = Invoke-RestMethodWrapper -Uri $Uri
    If ($Null -ne $Nodes) {

            # Walk through each node to output details
            ForEach ($node in $Nodes) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): matching [$($node.title)]"
                If (($node.title -match $Include) -and ($node.title -notmatch $Exclude)) {

                    # Match version number from the title, account for title strings without version numbers
                    try {
                        $Version = [RegEx]::Match($node.title, $res.Get.MatchVersion).Captures.Groups[1].Value 4>$Null
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $Version."
                    }
                    catch {
                        $Version = "Unknown"
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Unknown version."
                    }

                    # Output the version object
                    $PSObject = [PSCustomObject] @{
                        Version     = $Version
                        Title       = $node.title -replace $res.Get.TitleReplace, ""
                        Description = $node.description
                        Date        = ConvertTo-DateTime -DateTime $node.pubDate.Trim() -Pattern "ddd, dd MMM yyyy HH:mm:ss zzz" #"Tue, 02 Feb 2021 13:30:00 -0500"
                        URI         = $node.link
                    }
                    Write-Output -InputObject $PSObject
                }
            }
    }
    Else {
        Throw "$($MyInvocation.MyCommand): failed to read Citrix RSS feed [$Uri]."
    }
}

Function Get-ControlUpAgentUri {
    <#
        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
    #>
    [CmdletBinding()]
    [OutputType([String])]
    Param(
        [ValidateSet("net45","net35")]
        [string] $NetVersion = "net45",

        [ValidateSet("x86","x64")]
        [string] $Architecture = "x64"
    )
    
    $version = Get-ControlUpAgentVersion
    $downloadURL = "https://downloads.controlup.com/agent/$($version.tostring())/ControlUpAgent-$($netversion)-$($architecture).msi"
    
    Write-Output $downloadURL
}

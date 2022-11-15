Function Get-AWSCLI {
    <#
        .SYNOPSIS
            Get the current versions and download URLs for AWS CLI

        .NOTES
            Author: Kirill Trofimov
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get the latest download
    ForEach ($CLIversion in $res.Get.Download.CLI.GetEnumerator()) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Looking for CLI version $($CLIversion.Name)."

        ForEach ($CLIType in $res.Get.Download.CLI.($CLIversion.Name).GetEnumerator()) {

            $Url = $CLIType.Value
            $Response = Resolve-SystemNetWebRequest -Uri $Url

            # Construct the output; Return the custom object to the pipeline
            #NOTE: Version can now be returned with `Get-GitHubRepoRelease -ReturnVersionOnly`
            If ($Null -ne $Response) {
                $PSObject = [PSCustomObject] @{
                    Version      = [RegEx]::Match($Response.ResponseUri.LocalPath, $res.Get.Download.MatchVersion).Captures.Groups[1].Value
                    Architecture = Get-Architecture -String $Url
                    CLI          = $CLIversion.Name
                    Type         = [System.IO.Path]::GetExtension($Url).Split(".")[-1]
                    URI          = $Response.ResponseUri.AbsoluteUri
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}

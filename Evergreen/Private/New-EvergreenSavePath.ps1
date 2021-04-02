Function New-EvergreenSavePath {
    <#
        .SYNOPSIS
            Build a path from the Evergreen input object properties

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy        
    #>
    [OutputType([System.String])]
    [CmdletBinding()]
    Param(
        [Parameter()]
        [System.Management.Automation.PSObject] $InputObject,

        [Parameter()]
        [System.String] $Path
    )

    # Set the value of $Path to $OutPath to use to build the new path
    $OutPath = $Path

    # Build the new path using the specified object properties
    ForEach ($property in ("Channel", "Release", "Ring", "Version", "Language", "Architecture")) {
        If ([System.Boolean]($InputObject.$property)) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): $($property): $($InputObject.$property)."
            $OutPath = Join-Path -Path $OutPath -ChildPath $InputObject.$property
            If (Test-Path -Path $OutPath) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Path exists: $OutPath."
            }
            Else {
                try {
                    $params = @{
                        Path        = $OutPath
                        ItemType    = "Directory"
                        ErrorAction = "SilentlyContinue"
                    }
                    New-Item @params > $Null
                }
                catch {
                    Write-Error -Message "$($MyInvocation.MyCommand): Failed to create target directory. Error failed with: $($_.Exception.Message)."
                    Break
                }
            }
        }
    }

    # Return the newly built path
    Write-Output -InputObject $OutPath
}

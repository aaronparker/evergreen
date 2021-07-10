Function New-EvergreenPath {
    <#
        .SYNOPSIS
            Build a path from the Evergreen input object properties

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy        
    #>
    [OutputType([System.String])]
    [CmdletBinding(SupportsShouldProcess = $True)]
    param (
        [Parameter()]
        [System.Management.Automation.PSObject] $InputObject,

        [Parameter()]
        [System.String] $Path
    )

    # Set the value of $Path to $OutPath to use to build the new path
    $OutPath = $Path

    # Build the new path using the specified object properties
    ForEach ($property in ("Product", "Track", "Channel", "Release", "Ring", "Version", "Language", "Architecture")) {
        If ([System.Boolean]($InputObject.$property)) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): $($property): $($InputObject.$property)."
            $OutPath = Join-Path -Path $OutPath -ChildPath $InputObject.$property
            If (Test-Path -Path $OutPath) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Path exists: $OutPath."
            }
            Else {
                If ($PSCmdlet.ShouldProcess($OutPath, "Create Directory")) {
                    try {
                        $params = @{
                            Path        = $OutPath
                            ItemType    = "Directory"
                            ErrorAction = "Continue"
                        }
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Create path: $OutPath."
                        New-Item @params > $Null
                    }
                    catch {
                        Throw "$($MyInvocation.MyCommand): Failed to create target directory. Error failed with: $($_.Exception.Message)."
                    }
                }
            }
        }
    }

    # Return the newly built path
    Write-Output -InputObject $OutPath
}

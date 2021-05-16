Function Add-FileType {
    <#
        Adds the Type property to an object,
        including adding additional file types
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject] $InputObject,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateNotNull()]
        [System.Array] $FileType
    )

    Begin {}
    Process {
        ForEach ($Object in $InputObject) {
            If ([System.Boolean]($Object.URI)) {

                # Find the existing extension
                $CurrentExtension = [System.IO.Path]::GetExtension($Object.URI).Split(".")[-1]

                ForEach ($File in $FileType) {
                    If (($CurrentExtension -eq $File) -and ([System.Boolean]($Object.Type))) {
                        Write-Object -InputObject $Object
                    }
                    ElseIf (($CurrentExtension -ne $File) -and ([System.Boolean]($Object.Type) -eq $False)) {
                        $params = @{
                            MemberType = "NoteProperty"
                            Name       = "Type"
                            Value      = $($Object.URI -replace $CurrentExtension, $File)
                        }
                        $Object | Add-Member @params
                        Write-Object -InputObject $Object
                    }
                }
            }
            Else {
                Throw "$($MyInvocation.MyCommand): Input object does not have an expected URI property."
            }
        }
    }
    End {}
}

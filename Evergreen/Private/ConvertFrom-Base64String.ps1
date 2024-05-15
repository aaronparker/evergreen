function ConvertFrom-Base64String {
    <#
        .SYNOPSIS
        Converts a Base64 encoded string to a regular string.

        .DESCRIPTION
        This cmdlet takes a Base64 encoded string as input and converts it to a regular string.
        The resulting string is then outputted.

        .PARAMETER Base64String
        Specifies the Base64 encoded string to be converted.

        .OUTPUTS
        System.String
        The converted string.

        .NOTES
        This cmdlet does not support the ShouldProcess functionality.

        .EXAMPLE
        ConvertFrom-Base64 -Base64String "SGVsbG8gd29ybGQ="
        # Outputs: "Hello world"
    #>
    [OutputType([System.String])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
        [System.String] $Base64String
    )

    process {
        try {
            $Byte = [System.Convert]::FromBase64String($Base64String)
            $String = [System.BitConverter]::ToString($Byte)
            $OutputString = $String.Replace('-', '').ToLower()
            Write-Output -InputObject $OutputString
        }
        catch {
            throw $_
        }
    }
}

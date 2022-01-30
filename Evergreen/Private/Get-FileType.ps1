Function Get-FileType {
    [OutputType([System.String])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $File
    )

    $Extension = [System.IO.Path]::GetExtension($File).Split(".")[-1]
    Write-Verbose -Message "$($MyInvocation.MyCommand): found extension: [$Extension]"
    Write-Output -InputObject $Extension
}

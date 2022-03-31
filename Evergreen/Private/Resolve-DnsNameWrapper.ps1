Function Resolve-DnsNameWrapper {
    <#
        .SYNOPSIS
            Wrap Resolve-DnsName to filter what's returned
    #>
    [OutputType([Microsoft.DnsClient.Commands.DnsRecord])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Type = "A"
    )

    # Resolve-DnsName only exists on Windows
    If (($Null -eq $PSVersionTable.OS) -or ($PSVersionTable.OS -match "Microsoft Windows*")) {

        # Wrap Resolve-DnsName
        Write-Verbose -Message "$($MyInvocation.MyCommand): Resolving: $Name, with type: $Type."
        try {
            $params = @{
                Name        = $Name
                Type        = $Type
                ErrorAction = "SilentlyContinue"
            }
            $Response = Resolve-DnsName @params | Where-Object { $_.Type -eq $Type }
        }
        catch {
            Write-Error -Message "$($MyInvocation.MyCommand): $($_.Exception.Message)."
        }
        if ($Null -ne $Response) {
            Write-Output -InputObject $Response
        }
        else {
            Write-Error -Message "$($MyInvocation.MyCommand): failed to return a useable object from Resolve-DnsName."
        }
    }
    else {
        throw "$($MyInvocation.MyCommand): this function requires Microsoft Windows."
    }
}

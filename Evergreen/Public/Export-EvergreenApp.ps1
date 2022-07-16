function Export-EvergreenApp {
    <#
        .EXTERNALHELP Evergreen-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline,
            HelpMessage = "Pass an application object from Get-EvergreenApp.")]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject] $InputObject,

        [Parameter(
            Mandatory = $True,
            Position = 1,
            ValueFromPipelineByPropertyName,
            HelpMessage = "Specify the path to the JSON file.",
            ParameterSetName = "Path")]
        [ValidateNotNull()]
        [System.IO.FileInfo] $Path
    )

    begin {}

    process {
        if (Test-Path -Path $Path) {
            try {
                # Add the new details to the existing file content
                $Content = Get-Content -Path $Path -Verbose:$VerbosePreference | ConvertFrom-Json
                $InputObject += $Content
            }
            catch {
                throw $_
            }
        }

        # Sort the content and keep unique versions
        $Properties = $InputObject | Get-Member | `
            Where-Object { $_.MemberType -eq "NoteProperty" } | Select-Object -ExpandProperty "Name" | `
            Sort-Object -Descending
        $InputObject = $InputObject | Select-Object -Unique -Property $Properties

        # Export the data to file
        $InputObject | Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $false } | `
            ConvertTo-Json | `
            Out-File -Path $Path -Encoding "Utf8" -NoNewline -Verbose:$VerbosePreference
    }

    end {}
}

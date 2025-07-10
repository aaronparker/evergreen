using namespace System.Management.Automation
function Write-Message {
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $true)]
        [System.String] $Message
    )
    $Msg = [HostInformationMessage]@{
        Message         = "$($Message.PadRight([System.Console]::WindowWidth))"
        ForegroundColor = "Black"
        BackgroundColor = "DarkGreen"
        NoNewline       = $false
    }
    $params = @{
        MessageData       = $Msg
        InformationAction = "Continue"
        Tags              = "Evergreen"
    }
    Write-Information @params
}

using namespace System.Management.Automation
function Write-Message {
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $true)]
        [System.String] $Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Information", "Fail", "Pass")]
        [System.String] $MessageType = "Information"
    )

    # [System.Text.Encoding]::UTF32.GetBytes("✓")
    switch ($MessageType) {
        "Information" {
            $ForegroundColor = "Black"
            $BackgroundColor = "DarkGreen"
        }
        "Pass" {
            $ForegroundColor = "Black"
            $BackgroundColor = "DarkGreen"
            $Message = "[$(Get-Symbol -Symbol "Tick")] $Message"
        }
        "Fail" {
            $ForegroundColor = "White"
            $BackgroundColor = "DarkRed"
            $Message = "[$(Get-Symbol -Symbol "Cross")] $Message"
        }
    }

    $Msg = [HostInformationMessage]@{
        Message         = "$($Message.PadRight([System.Console]::WindowWidth))"
        ForegroundColor = $ForegroundColor
        BackgroundColor = $BackgroundColor
        NoNewline       = $false
    }
    $params = @{
        MessageData       = $Msg
        InformationAction = "Continue"
        Tags              = "Evergreen"
    }
    Write-Information @params
}

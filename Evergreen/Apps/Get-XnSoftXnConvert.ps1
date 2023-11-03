function Get-XnSoftXnConvert {
    <#
        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "Product name is a plural")]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Pass the repo releases API URL and return a formatted object
    $params = @{
        Uri          = $res.Get.Update.Uri
        ContentType  = $res.Get.Update.ContentType
        ReturnObject = "Content"
    }
    $Content = Invoke-EvergreenWebRequest @params
    if ($null -ne $Content) {
        $Update = ConvertFrom-IniFile -InputObject $Content

        if ($null -ne $Update) {
            foreach ($Download in $res.Get.Download.Uri.GetEnumerator()) {
                $PSObject = [PSCustomObject] @{
                    Version      = $Update.$($res.Get.Update.Property).version
                    Architecture = $Download.Name
                    Type         = Get-FileType -File $res.Get.Download.Uri[$Download.Key]
                    URI          = $res.Get.Download.Uri[$Download.Key]
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}

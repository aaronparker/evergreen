Function Get-AdobeAcrobat {
    <#
        .SYNOPSIS
            Gets the download URLs for Adobe Acrobat (Standard/Pro) 2020 or DC updates.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    #region Update downloads
    ForEach ($Product in $res.Get.Update.Uri.GetEnumerator()) {
        ForEach ($item in $res.Get.Update.Uri.($Product.Name).GetEnumerator()) {

            # Find the latest version number
            $params = @{
                Uri         = $res.Get.Update.Uri.($Product.Name)[$item.key]
                ContentType = $res.Get.Update.ContentType
            }
            $Content = Invoke-EvergreenWebRequest @params

            # Construct update download list
            If ($Null -ne $Content) {

                # Format version string
                $versionString = $Content.Replace(".", "").Trim()
                Write-Verbose -Message "$($MyInvocation.MyCommand): Update found: [$($Content)] and converted to version string: [$($versionString)]."

                # Build the output object
                ForEach ($Architecture in $res.Get.Download.Uri.($Product.Name).GetEnumerator()) {
                    ForEach ($Url in $res.Get.Download.Uri.($Product.Name).($Architecture.Name).GetEnumerator()) {

                        # Filter the output object for combinations that don't exist
                        [System.Boolean] $Build = $True
                        If (($Architecture.Name -eq "x64") -and ($item.Name -notin $res.Get.Download.Filter.x64)) {
                            Write-Verbose -Message "$($MyInvocation.MyCommand): Skip x64 architecture for track: [$($item.Name)]."
                            [System.Boolean] $Build = $False
                        }
                        If (($Product.Name -eq "Reader") -and ($Url.Name -eq "Neutral") -and ($item.Name -in $res.Get.Download.Filter.Neutral)) {
                            Write-Verbose -Message "$($MyInvocation.MyCommand): Skip Neutral language for track: [$($item.Name)]."
                            [System.Boolean] $Build = $False
                        }

                        If ($Build) {
                            Write-Verbose -Message "$($MyInvocation.MyCommand): Construct object for: [$($Product.Name) $($item.Name) $($Url.Name) $($Architecture.Name)]."

                            # Construct the URI property
                            $Uri = ($res.Get.Download.Uri.($Product.Name).($Architecture.Name)[$Url.key] `
                                    -replace $res.Get.Download.ReplaceText.Version, $versionString) `
                                -replace $res.Get.Download.ReplaceText.Track, $item.Name

                            # Build the object
                            $PSObject = [PSCustomObject] @{
                                Version      = $Content.Trim()
                                Type         = $res.Get.Download.Type
                                Product      = $Product.Name
                                Track        = $item.Name
                                Language     = $Url.Name
                                Architecture = $Architecture.Name
                                URI          = $Uri
                            }
                            Write-Output -InputObject $PSObject
                        }
                    }
                }
            }
            Else {
                Throw "$($MyInvocation.MyCommand): unable to retrieve content from $($res.Get.Update.Uri[$item.key])."
            }
        }
    }
    #endregion
}

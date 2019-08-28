Function Get-XenServerTools {
    $Uri = "https://pvupdates.vmd.citrix.com/updates.latest.tsv"
    $TempFile = New-TemporaryFile
    Invoke-WebRequest -Uri $Uri -OutFile $TempFile
    $RawContent = Get-Content $TempFile
    $Table = $RawContent | ConvertFrom-Csv -Delimiter "`t" -Header "Uri", "Version", "Size", "Architecture", "Index"
    Write-Output $Table

    # Write-Verbose "Setting Arguments" -Verbose
    # $StartDTM = (Get-Date)
    # $Vendor = "Citrix"
    # $Product = "XenServer"
    # $PackageName = "managementagentx64"
    # $Version = $Latest.version
    # $InstallerType = "msi"
    #$Source = "$PackageName" + "." + "$InstallerType"
    # $LogPS = "C:\Windows\Temp\$Vendor $Product $Version PS Wrapper.log"
    # $LogApp = "C:\Windows\Temp\XS65FP1.log"
    # $UnattendedArgs = "/i $PackageName.$InstallerType ALLUSERS=1 /Lv $LogApp /quiet /norestart"
}

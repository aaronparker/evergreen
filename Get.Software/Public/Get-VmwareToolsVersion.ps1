Function Get-VMWareToolsVersion {
    <#
        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
    #>
    [CmdletBinding()]
    [OutputType([Version])]
    Param()

    $vmwareTools = "https://packages.vmware.com/tools/esx/latest/windows/x64/index.html"
    $pattern = "[0-9]+\.[0-9]+\.[0-9]+\-[0-9]+\-x86_64"

    #get the raw page content
    $pageContent=(wget -Uri $vmwareTools).content

    #change one big string into many strings, then find only the line with the version number
    $interestingLine = ($pageContent.split("`n") | Select-string -Pattern $pattern).tostring().trim()

    #remove the whitespace and split on the assignment operator, then split on the double quote and select the correct item
    $filename = (($interestingLine.Replace(" ","").Split("=") | Select-string -Pattern $pattern).ToString().Trim().Split("`""))[1]

    #file name is in the format "VMware-tools-10.2.1-8267844-x86_64.exe"
    #convert to a .NET version class, that can be used to compare against other version objects
    $version = [version]$filename.Replace("VMware-tools-","").Replace("-x86_64.exe","").Replace("-",".")

    #return the version object
    Write-Output $version
}

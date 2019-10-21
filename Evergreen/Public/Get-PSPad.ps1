Function Get-PSPad {    
    <#
        .NOTES
            Author: Trond Eirik Haavarstein
            Twitter: @xenappblog
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()
        $url = "http://www.pspad.com/en/download.php"
    try {
        $web = Invoke-WebRequest -UseBasicParsing -Uri $url -ErrorAction SilentlyContinue
    }
    catch {
        Throw "Failed to connect to URL: $url with error $_."
        Break
    }
    finally {
        $m = $web.ToString() -split "[`r`n]" | Select-String "Current Version" | Select-Object -First 1
        $m = $m -replace "<((?!@).)*?>"
        $m = $m.Replace(' ','')
        $m = $m -replace "PSPad-currentversion"
        $Version = $m.Substring(0,5)
        
        $File = $Version -replace "\.",""
        $x32 = "http://pspad.poradna.net/release/pspad$($File)_setup.exe"

        $PSObjectx32 = [PSCustomObject] @{
        Version      = $Version
        Architecture = "x86"
        URI          = $x32
        }
        
        Write-Output -InputObject $PSObjectx32

     }
}

Function Get-IrfanView {    
    <#
        .NOTES
            Author: Trond Eirik Haavarstein
            Twitter: @xenappblog
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()
        $url = "https://www.irfanview.com/"
    try {
        $web = Invoke-WebRequest -UseBasicParsing -Uri $url -ErrorAction SilentlyContinue
    }
    catch {
        Throw "Failed to connect to URL: $url with error $_."
        Break
    }
    finally {
        $m = $web.ToString() -split "[`r`n]" | Select-String "Version" | Select-Object -First 1
        $m = $m -replace "<((?!@).)*?>"
        $m = $m.Replace(' ','')
        $Version = $m -replace "Version"
        $File = $Version -replace "\.",""
        $x32 = "http://download.betanews.com/download/967963863-1/iview$($File)_setup.exe"
        $x64 = "http://download.betanews.com/download/967963863-1/iview$($File)_x64_setup.exe"

        $PSObjectx32 = [PSCustomObject] @{
        Version      = $Version
        Architecture = "x86"
        URI          = $x32
        }
        
        $PSObjectx64 = [PSCustomObject] @{
        Version      = $Version
        Architecture = "x64"
        URI          = $x64
        }

        Write-Output -InputObject $PSObjectx32
        Write-Output -InputObject $PSObjectx64
    }
}

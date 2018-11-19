Function Get-PaintDotNetVersion {
    <#
        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
    #>
    [CmdletBinding()]
    [OutputType([Version])]
    Param()

    # Get the latest Paint.NET download using the Get-PaintDotNetUri function
    # Returns a URI like 'https://www.dotpdn.com/files/paint.net.4.1.4.install.zip'
    try {
        $downloadUrl = Get-PaintDotNetUri -ErrorAction SilentlyContinue
    }
    catch {
        Throw "Unable to find Paint.NET download URI."
    }
    finally {
        # $filename = ($downloadurl.split('/') | Select-String -Pattern "(\d+\.)+\d+" | Select-Object -first 1).ToString().Trim()
        $filename = Split-Path -Path $downloadUrl -Leaf
        
        # If $filename matches a version number, output the version string and convert to a [Version]
        If ($filename -match "(\d+\.)+\d+") {
            $fileversion = [Version]::new($Matches[0])
            Write-Output $fileversion
        }
        Else {
            Throw "Unable to match version from $filename."
        }
    }
}

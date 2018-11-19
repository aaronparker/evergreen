Function Get-LibreOfficeVersion {
    [CmdletBinding()]
    [OutputType([version])]
    Param (
        [ValidateSet("Latest", "Business")]
        [string] $Release = "Latest"
    )

    $url = "https://www.libreoffice.org/download/download/"

    try {
        $response = Invoke-WebRequest -UseBasicParsing -Uri $url -ErrorAction SilentlyContinue
    }
    catch {
        Throw "Failed to connect to Libre Office URL: $url with error $_."
    }
    finally {
        # Search for their big green logo version number '<span class="dl_version_number">*</span>'
        $content = $response.Content
        $spans = $content.Replace('<span', '#$%^<span').Replace('</span>', '</span>#$%^').Split('#$%^') | `
            Where-Object { $_ -like '<span class="dl_version_number">*</span>' }
        $verBlock = ($spans).Replace('<span class="dl_version_number">', '').Replace('</span>', '')

        If ($Release -eq "Latest") {
            $version = [version]::new($($verblock | Select-Object -First 1))
        }
        Else {
            $version = [version]::new($($verblock | Select-Object -Last 1))
        }

        Write-Output $version
    }
}

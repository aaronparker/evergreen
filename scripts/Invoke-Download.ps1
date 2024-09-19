function Invoke-Download {
    <#
    .NOTES
        Original code from: https://github.com/DanGough/PsDownload/
        Original author: Dan Gough
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [Alias('URL')]
        [ValidateNotNullOrEmpty()]
        [System.String] $URI,

        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Destination = $PWD.Path,

        [Parameter(Position = 2)]
        [System.String] $FileName,

        [System.String[]] $UserAgent = @('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36 Edg/127.0.2651.105', 'Googlebot/2.1 (+http://www.google.com/bot.html)'),

        [System.String] $TempPath = [System.IO.Path]::GetTempPath(),

        [System.Management.Automation.SwitchParameter] $IgnoreDate,
        [System.Management.Automation.SwitchParameter] $BlockFile,
        [System.Management.Automation.SwitchParameter] $NoClobber,
        [System.Management.Automation.SwitchParameter] $NoProgress,
        [System.Management.Automation.SwitchParameter] $PassThru
    )

    begin {
        # Required on Windows Powershell only
        if ($PSEdition -eq 'Desktop') {
            Add-Type -AssemblyName "System.Net.Http"
            Add-Type -AssemblyName "System.Web"
        }

        # Enable TLS 1.2 in addition to whatever is pre-configured
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

        # Create one single client object for the pipeline
        $HttpClient = New-Object -TypeName "System.Net.Http.HttpClient"
    }

    process {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Requesting headers from URL '$URI'"

        foreach ($UserAgentString in $UserAgent) {
            $HttpClient.DefaultRequestHeaders.Remove('User-Agent') | Out-Null
            if ($UserAgentString) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Using UserAgent '$UserAgentString'"
                $HttpClient.DefaultRequestHeaders.Add('User-Agent', $UserAgentString)
            }

            # This sends a GET request but only retrieves the headers
            $ResponseHeader = $HttpClient.GetAsync($URI, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result
            if ($ResponseHeader.IsSuccessStatusCode) {
                # Exit the foreach if success
                break
            }
        }

        if ($ResponseHeader.IsSuccessStatusCode) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Successfully retrieved headers"

            if ($ResponseHeader.RequestMessage.RequestUri.AbsoluteUri -ne $URI) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): URL '$URI' redirects to '$($ResponseHeader.RequestMessage.RequestUri.AbsoluteUri)'"
            }

            try {
                $FileSize = $null
                $FileSize = [System.Int32]$ResponseHeader.Content.Headers.GetValues('Content-Length')[0]
                $FileSizeReadable = switch ($FileSize) {
                    { $_ -gt 1TB } { '{0:n2} TB' -f ($_ / 1TB); break }
                    { $_ -gt 1GB } { '{0:n2} GB' -f ($_ / 1GB); break }
                    { $_ -gt 1MB } { '{0:n2} MB' -f ($_ / 1MB); break }
                    { $_ -gt 1KB } { '{0:n2} KB' -f ($_ / 1KB); break }
                    default { '{0} B' -f $_ }
                }
                Write-Verbose -Message "$($MyInvocation.MyCommand): File size: $FileSize bytes ($FileSizeReadable)"
            }
            catch {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Unable to determine file size"
            }

            # Try to get the last modified date from the "Last-Modified" header, use error handling in case string is in invalid format
            try {
                $LastModified = $null
                $LastModified = [DateTime]::ParseExact($ResponseHeader.Content.Headers.GetValues('Last-Modified')[0], 'r', [System.Globalization.CultureInfo]::InvariantCulture)
                Write-Verbose -Message "$($MyInvocation.MyCommand): Last modified: $($LastModified.ToString())"
            }
            catch {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Last-Modified header not found"
            }

            if ($FileName) {
                $FileName = $FileName.Trim()
                Write-Verbose -Message "$($MyInvocation.MyCommand): Will use supplied filename '$FileName'"
            }
            else {
                try {
                    # Get the file name from the "Content-Disposition" header if available
                    $ContentDispositionHeader = $null
                    $ContentDispositionHeader = $ResponseHeader.Content.Headers.GetValues('Content-Disposition')[0]
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Content-Disposition header found: $ContentDispositionHeader"
                }
                catch {
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Content-Disposition header not found"
                }

                if ($ContentDispositionHeader) {
                    $ContentDispositionRegEx = @'
^.*filename\*?\s*=\s*"?(?:UTF-8|iso-8859-1)?(?:'[^']*?')?([^";]+)
'@
                    if ($ContentDispositionHeader -match $ContentDispositionRegEx) {
                        # GetFileName ensures we are not getting a full path with slashes. UrlDecode will convert characters like %20 back to spaces.
                        $FileName = [System.IO.Path]::GetFileName([System.Web.HttpUtility]::UrlDecode($matches[1]))
                        # If any further invalid filename characters are found, convert them to spaces.
                        [System.IO.Path]::GetInvalidFileNameChars() | ForEach-Object { $FileName = $FileName.Replace($_, ' ') }
                        $FileName = $FileName.Trim()
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Extracted filename '$FileName' from Content-Disposition header"
                    }
                    else {
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Failed to extract filename from Content-Disposition header"
                    }
                }

                if ([System.String]::IsNullOrEmpty($FileName)) {
                    # If failed to parse Content-Disposition header or if it's not available, extract the file name from the absolute URL to capture any redirections.
                    # GetFileName ensures we are not getting a full path with slashes. UrlDecode will convert characters like %20 back to spaces.
                    # The URL is split with ? to ensure we can strip off any API parameters.
                    $FileName = [System.IO.Path]::GetFileName([System.Web.HttpUtility]::UrlDecode($ResponseHeader.RequestMessage.RequestUri.AbsoluteUri.Split('?')[0]))
                    [System.IO.Path]::GetInvalidFileNameChars() | ForEach-Object { $FileName = $FileName.Replace($_, ' ') }
                    $FileName = $FileName.Trim()
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Extracted filename '$FileName' from absolute URL '$($ResponseHeader.RequestMessage.RequestUri.AbsoluteUri)'"
                }
            }
        }
        else {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Failed to retrieve headers"
        }

        if ([System.String]::IsNullOrEmpty($FileName)) {
            # If still no filename set, extract the file name from the original URL.
            # GetFileName ensures we are not getting a full path with slashes. UrlDecode will convert characters like %20 back to spaces.
            # The URL is split with ? to ensure we can strip off any API parameters.
            $FileName = [System.IO.Path]::GetFileName([System.Web.HttpUtility]::UrlDecode($URI.Split('?')[0]))
            [System.IO.Path]::GetInvalidFileNameChars() | ForEach-Object { $FileName = $FileName.Replace($_, ' ') }
            $FileName = $FileName.Trim()
            Write-Verbose -Message "$($MyInvocation.MyCommand): Extracted filename '$FileName' from original URL '$URI'"
        }

        $DestinationFilePath = Join-Path -Path $Destination -ChildPath $FileName

        # Exit if -NoClobber specified and file exists.
        if ($NoClobber -and (Test-Path -LiteralPath $DestinationFilePath -PathType Leaf)) {
            return
        }

        # Open the HTTP stream
        $ResponseStream = $HttpClient.GetStreamAsync($URI).Result
        if ($ResponseStream.CanRead) {

            # Check TempPath exists and create it if not
            if (-not (Test-Path -LiteralPath $TempPath -PathType Container)) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Temp folder '$TempPath' does not exist"

                try {
                    New-Item -Path $Destination -ItemType "Directory" -Force | Out-Null
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Created temp folder '$TempPath'"
                }
                catch {
                    Write-Error -Message "$($MyInvocation.MyCommand): Unable to create temp folder '$TempPath': $($_.Exception.Message)"
                    return
                }
            }

            # Generate temp file name
            $TempFileName = (New-Guid).ToString('N') + ".tmp"
            $TempFilePath = Join-Path -Path $TempPath -ChildPath $TempFileName

            # Check Destination exists and create it if not
            if (-not (Test-Path -LiteralPath $Destination -PathType Container)) {
                try {
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Output folder '$Destination' does not exist"
                    New-Item -Path $Destination -ItemType Directory -Force | Out-Null
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Created output folder '$Destination'"
                }
                catch {
                    Write-Error "Unable to create output folder '$Destination': $($_.Exception.Message)"
                    return
                }
            }

            # Open file stream
            try {
                $FileStream = [System.IO.File]::Create($TempFilePath)
            }
            catch {
                Write-Error "Unable to create file '$TempFilePath': $($_.Exception.Message)"
                return
            }

            if ($FileStream.CanWrite) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Downloading to temp file '$TempFilePath'..."

                $Buffer = New-Object -TypeName byte[] 64KB
                $BytesDownloaded = 0
                $ProgressIntervalMs = 250
                $ProgressTimer = (Get-Date).AddMilliseconds(-$ProgressIntervalMs)

                while ($true) {
                    try {
                        # Read stream into buffer
                        $ReadBytes = $ResponseStream.Read($Buffer, 0, $Buffer.Length)

                        # Track bytes downloaded and display progress bar if enabled and file size is known
                        $BytesDownloaded += $ReadBytes
                        if (!$NoProgress -and (Get-Date) -gt $ProgressTimer.AddMilliseconds($ProgressIntervalMs)) {
                            if ($FileSize) {
                                $PercentComplete = [System.Math]::Floor($BytesDownloaded / $FileSize * 100)
                                Write-Progress -Activity "Downloading $FileName" -Status "$BytesDownloaded of $FileSize bytes ($PercentComplete%)" -PercentComplete $PercentComplete
                            }
                            else {
                                Write-Progress -Activity "Downloading $FileName" -Status "$BytesDownloaded of ? bytes" -PercentComplete 0
                            }
                            $ProgressTimer = Get-Date
                        }

                        # If end of stream
                        if ($ReadBytes -eq 0) {
                            Write-Progress -Activity "Downloading $FileName" -Completed
                            $FileStream.Close()
                            $FileStream.Dispose()

                            try {
                                Write-Verbose -Message "$($MyInvocation.MyCommand): Moving temp file to destination '$DestinationFilePath'"
                                $DownloadedFile = Move-Item -LiteralPath $TempFilePath -Destination $DestinationFilePath -Force -PassThru
                            }
                            catch {
                                Write-Error "Error moving file from '$TempFilePath' to '$DestinationFilePath': $($_.Exception.Message)"
                                return
                            }

                            if ($IsWindows) {
                                if ($BlockFile) {
                                    Write-Verbose -Message "$($MyInvocation.MyCommand): Marking file as downloaded from the internet"
                                    Set-Content -LiteralPath $DownloadedFile -Stream 'Zone.Identifier' -Value "[ZoneTransfer]`nZoneId=3"
                                }
                                else {
                                    Unblock-File -LiteralPath $DownloadedFile
                                }
                            }
                            if ($LastModified -and -not $IgnoreDate) {
                                Write-Verbose -Message "$($MyInvocation.MyCommand): Setting Last Modified date"
                                $DownloadedFile.LastWriteTime = $LastModified
                            }
                            Write-Verbose -Message "$($MyInvocation.MyCommand): Download complete!"
                            if ($PassThru) {
                                $DownloadedFile
                            }
                            break
                        }
                        $FileStream.Write($Buffer, 0, $ReadBytes)
                    }
                    catch {
                        Write-Error -Message "$($MyInvocation.MyCommand): Error downloading file: $($_.Exception.Message)"
                        Write-Progress -Activity "Downloading $FileName" -Completed
                        $FileStream.Close()
                        $FileStream.Dispose()
                        break
                    }
                }
            }
        }
        else {
            Write-Error 'Failed to start download'
        }

        # Reset this to avoid reusing the same name when fed multiple URLs via the pipeline
        $FileName = $null
    }

    end {
        $HttpClient.Dispose()
    }
}

Try {
    #$response = Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -MaximumRedirection 0 -UseBasicParsing -ErrorAction SilentlyContinue
    $response = Invoke-WebRequest -Uri "https://get.videolan.org/vlc/3.0.8/macosx/vlc-3.0.8.dmg" `
        -UseBasicParsing -UserAgent "VLC/3.0.7 LibVLC/3.0.7" -MaximumRedirection 0 `
        -ErrorAction SilentlyContinue
}
catch {
    $response = $_.Exception.Response
}

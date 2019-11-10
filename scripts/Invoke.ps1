Try {
    $response = Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -MaximumRedirection 0
} catch {
    $r = $_.Exception.Response
}

$r = Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -MaximumRedirection 0 -ErrorAction SilentlyContinue

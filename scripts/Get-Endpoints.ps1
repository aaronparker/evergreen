# Read the application manifests and output URLs as a PSObject
$UrlMatch = "(http|https):\/\/(.*[a-zA-Z0-9_\-]+\.[a-zA-Z0-9_\-]+)/"
$EndpointsUpdates = Get-ChildItem -Path "/Users/aaron/projects/evergreen/Evergreen/Manifests" -Recurse -Include "*.json" | ForEach-Object {
    [PSCustomObject]@{
        Application = $_.BaseName
        Endpoints   = ((Select-String -Path $_.FullName -Pattern $UrlMatch).Matches.Value | Select-Object -Unique | Sort-Object)
    }
}

$Namespace = "037069e7da3e4944be2cbc97c92409a5"
wrangler kv:key put "endpoints-updates" $($EndpointsUpdates | ConvertTo-Json) --namespace-id=$Namespace

$EndpointsDownloads = Get-ChildItem -Path "/Users/aaron/projects/apptracker/json" -Recurse -Include "*.json" | ForEach-Object {
    [PSCustomObject]@{
        Application = $_.BaseName
        Endpoints   = ((Select-String -Path $_.FullName -Pattern $UrlMatch).Matches.Value | Select-Object -Unique | Sort-Object)
    }
}

wrangler kv:key put "endpoints-downloads" $($EndpointsDownloads | ConvertTo-Json) --namespace-id=$Namespace





$UrlMatch = "(?:(?:http|https):\/\/)(.*[a-zA-Z0-9_\-]+\.[a-zA-Z0-9_\-]+)"
Select-String -Path "/Users/aaron/projects/evergreen/Evergreen/Manifests/MicrosoftEdge.json" -Pattern $UrlMatch

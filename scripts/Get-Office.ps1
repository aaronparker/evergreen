$webreturn = Invoke-WebRequest -uri "https://mrodevicemgr.officeapps.live.com/mrodevicemgrsvc/api/v2/C2RReleaseData?audienceFFN=492350f6-3a01-4f97-b9c0-c7c6ddf67d60"
$jsonData = ConvertFrom-Json $webreturn.Content
Write-Host " Current Build - Monthly Channel - $($jsonData.AvailableBuild)"
$webreturn = Invoke-WebRequest -uri "https://mrodevicemgr.officeapps.live.com/mrodevicemgrsvc/api/v2/C2RReleaseData?audienceFFN=7ffbc6bf-bc32-4f92-8982-f9dd17fd3114"
$jsonData = ConvertFrom-Json $webreturn.Content
Write-Host " Current Build - Semi-Annual Channel - $($jsonData.AvailableBuild)"
$webreturn = Invoke-WebRequest -uri "https://mrodevicemgr.officeapps.live.com/mrodevicemgrsvc/api/v2/C2RReleaseData?audienceFFN=64256afe-f5d9-4f86-8936-8840a6a4f5be"
$jsonData = ConvertFrom-Json $webreturn.Content
Write-Host " Current Build - Monthly Channel (Targeted) - $($jsonData.AvailableBuild)"
$webreturn = Invoke-WebRequest -uri "https://mrodevicemgr.officeapps.live.com/mrodevicemgrsvc/api/v2/C2RReleaseData?audienceFFN=b8f9b850-328d-4355-9145-c59439a0c4cf"
$jsonData = ConvertFrom-Json $webreturn.Content
Write-Host " Current Build - Semi-Annual Channel (Targeted) - $($jsonData.AvailableBuild)"
$webreturn = Invoke-WebRequest -uri "https://mrodevicemgr.officeapps.live.com/mrodevicemgrsvc/api/v2/C2RReleaseData?audienceFFN=f2e724c1-748f-4b47-8fb8-8e0d210e9208"
$jsonData = ConvertFrom-Json $webreturn.Content
Write-Host " Current Build - PerpetualVL2019 - $($jsonData.AvailableBuild)"
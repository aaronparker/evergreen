# Evergreen output

JSON files here list the output for all supported applications. These are listed here for reporting purposes only.

Export all applications to JSON by running the following command:

```powershell
Find-EvergreenApp | Where-Object { $_.Name -notmatch "GhislerTotalCommander" } | ForEach-Object { Get-EvergreenApp -Name $_.Name | ConvertTo-Json | Out-File -Path ".\$($_.Name).json" -Encoding "Utf8" }
```

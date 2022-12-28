# platyPS Help

platyPS help markdown can be found here: [/docs/help](/docs/help).

To generate the external help use `New-ExternalHelp`:

```powershell
Update-MarkdownHelp -Path "docs/help/en-US"
New-ExternalHelp -Path "docs/help/en-US" -OutputPath "Evergreen/en-US" -Encoding ([System.Text.Encoding]::UTF8) -Force
```

```powershell
Update-MarkdownHelpModule -Path "docs/help/en-US"
```

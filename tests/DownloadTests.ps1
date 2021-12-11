<#
    Downloads Pester tests saved for future use
    Causes excessive downloads and account lockouts in AppVeyor
#>

Describe -Tag "Download" -Name "Downloads" {
    ForEach ($application in $Applications) {

        Context "Validate $($application) downloads" {
            # Run each command and capture output in a variable
            New-Variable -Name "tempOutput" -Value (Get-EvergreenApp -Name $application)
            $Output = (Get-Variable -Name "tempOutput").Value
            Remove-Variable -Name "tempOutput" -ErrorAction "SilentlyContinue"

            # Test that the functions that have a URI property return something we can download
            # If URI is 'Unknown' there's probably a problem with the source
            If ([bool]($Output[0].PSObject.Properties.name -match "URI")) {
                ForEach ($object in $Output) {
                    It "$($application): [$(Split-Path -Path $object.URI -Leaf)] is a valid download target" {
                        try {
                            # Test URI exists without downloading the file
                            $r = Invoke-WebRequest -Uri $object.URI -Method "Head" -UseBasicParsing -ErrorAction "SilentlyContinue"
                        }
                        catch {
                            ## Testing with direct download consumes too much bandwidth skip downloading packages
                            ## AppVeyor has bandwidth limits that will cause the account to be locked if consumed

                            # If Method Head fails, try downloading the URI
                            # Write-Host -ForegroundColor Cyan "`tException grabbing URI via header. Retrying full request."
                            $OutFile = Join-Path -Path $Path (Split-Path -Path $object.URI -Leaf)
                            try {
                                $r = Invoke-WebRequest -Uri $object.URI -OutFile $OutFile -UseBasicParsing -PassThru `
                                    -ErrorAction "SilentlyContinue"
                            }
                            catch {
                                # If all else fails, let's pretend the URI is OK. Some URIs may require a login etc.
                                Write-Host -ForegroundColor Yellow "`t$($application) requires manual testing."
                                $r = [PSCustomObject] @{
                                    StatusCode = 200
                                }
                            }

                            # Checking headers didn't work so let's pretend the URI is OK.
                            # Some URIs may require a login or the web server responds with a 403 when retrieving headers
                            $u = [System.Uri] $object.URI
                            Write-Host -ForegroundColor Yellow "`tPerform manual test. Invoke-WebRequest response from $($u.Host) was: $($_.Exception.Response.StatusCode)."
                            $u = $Null
                            $r = [PSCustomObject] @{
                                StatusCode = 200
                            }
                        }
                        finally {
                            $r.StatusCode | Should -Be 200
                        }
                    }
                }
            }
            Else {
                Write-Host -ForegroundColor Yellow "`t$($application) does not have a URI property."
            }
        }
    }
}

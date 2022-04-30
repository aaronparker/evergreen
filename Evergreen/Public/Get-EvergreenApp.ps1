Function Get-EvergreenApp {
    <#
        .EXTERNALHELP Evergreen-help.xml
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, HelpURI = "https://stealthpuppy.com/evergreen/use/")]
    [Alias("gea")]
    param (
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage = "Specify an application name. Use Find-EvergreenApp to list supported applications.")]
        [ValidateNotNull()]
        [System.String] $Name,

        [Parameter(
        Mandatory = $False,
        Position = 1,
        HelpMessage = "Specify a hashtable of parameters to pass to the internal application function.")]
        [System.Collections.Hashtable] $AppParams
    )

    process {
        try {
            # Build a path to the application function
            # This will build a path like: Evergreen/Apps/Get-TeamViewer.ps1
            $Function = [System.IO.Path]::Combine($MyInvocation.MyCommand.Module.ModuleBase, "Apps", "Get-$Name.ps1")
        }
        catch {
            throw "$($MyInvocation.MyCommand): Failed to combine: $($MyInvocation.MyCommand.Module.ModuleBase), Apps, Get-$Name.ps1"
        }

        #region Test that the function exists and run it to return output
        if (Test-Path -Path $Function -PathType "Leaf" -ErrorAction "SilentlyContinue") {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Function exists: $Function."

            try {
                # Dot source the function so that we can use it
                # Import function here rather than at module import to reduce IO and memory footprint as the module grows
                # This also allows us to add an application manifest and function without having to re-load the module
                Write-Verbose -Message "$($MyInvocation.MyCommand): Dot sourcing: $Function."
                . $Function
            }
            catch {
                throw "$($MyInvocation.MyCommand): Failed to load function: $Function."
            }

            try {
                # Run the function to grab the application details; pass the per-app manifest to the app function
                # Application manifests are located under Evergreen/Manifests
                if ($PSBoundParameters.ContainsKey("AppParams")) {
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Adding AppParams."
                    $params = @{
                        res = (Get-FunctionResource -AppName $Name)
                    }
                    $params += $AppParams
                }
                else {
                    $params = @{
                        res = (Get-FunctionResource -AppName $Name)
                    }
                }
                Write-Verbose -Message "$($MyInvocation.MyCommand): Calling: Get-$Name."
                $Output = & Get-$Name @params
            }
            catch {
                Write-Error -Message "$($MyInvocation.MyCommand): Internal application function: $Function, failed with: $($_.Exception.Message)"
            }

            # if we get an object, return it to the pipeline
            # Sort object on the Version property
            if ($Output) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Output result from: $Function."
                Write-Output -InputObject ($Output | Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $true } -ErrorAction "SilentlyContinue")
            }
            else {
                throw "$($MyInvocation.MyCommand): Failed to capture output from: Get-$Name."
            }
        }
        else {
            Write-Warning -Message "Please list valid application names with Find-EvergreenApp."
            Write-Warning -Message "Documentation on how to contribute a new application to the Evergreen project can be found at: $($script:resourceStrings.Uri.Docs)."
            throw "$($MyInvocation.MyCommand): Cannot find application script at: $Function."
        }
        #endregion
    }

    end {
        # Remove these variables for next run
        Remove-Variable -Name "Output", "Function" -ErrorAction "SilentlyContinue"
    }
}

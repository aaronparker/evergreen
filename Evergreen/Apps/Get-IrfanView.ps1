﻿Function Get-IrfanView {
    <#
        .SYNOPSIS
            Returns the available IrfanView versions.

        .NOTES
            Author: Timo Wolf
            Github: @EldoBam
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Request page which has forwarding to current version (latest)
    $params = @{
        Uri = $res.Get.Uri
    }
    $req = Invoke-WebRequestWrapper @params
    $version = ([regex]$res.Get.MatchVersion).Matches($req).Groups[1].Value
    Write-Verbose "found version: $($version)"

    foreach ($architecture in $res.Update.Architectures.GetEnumerator()) {
        Write-Verbose "architecture: $($architecture.Key)"
        foreach ($format in $res.Update.Architectures.($architecture.Key).Formats) {
            Write-Verbose "format: $($format)"
            # build uri
            $uri = $res.Update.Uri
            foreach ($search in $res.Update.UriReplace.GetEnumerator() ) {
                Write-Verbose "Key: $($search.Key) - Value: $($search.Value)"
                $replaceValue = Invoke-Expression "`$$($res.Update.UriReplace.($search.Name))"
                Write-Verbose "replaceValue: $($replaceValue)"
                if($res.Update.UriMapping.Architectures.($replaceValue)){
                    Write-Verbose "found UriMapping for $($replaceValue)"
                    $replaceValue = $res.Update.UriMapping.Architectures.($replaceValue)
                    Write-Verbose "new replaceValue: $($replaceValue)"
                }
                $uri = $uri.Replace($search.Key, $replaceValue)
            }
            Write-Verbose "builded URI: $($uri)"
            # Output object to the pipeline
            $PSObject = [PSCustomObject]@{
                Version      = $version
                Architecture = $architecture.Key
                Type         = $format
                URI          = $uri
            }
            Write-Verbose "returning object"
            Write-Output -InputObject $PSObject
        }
    }

}
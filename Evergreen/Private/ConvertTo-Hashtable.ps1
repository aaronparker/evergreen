Function ConvertTo-Hashtable {
    <#
        .SYNOPSIS
            Converts a PSCustomObject into a hashtable for Windows PowerShell

        .NOTES
            Author: Adam Bertram
            Link: https://4sysops.com/archives/convert-json-to-a-powershell-hash-table
    #>
    [OutputType([System.Collections.Hashtable])]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        $InputObject
    )

    Process {
        ## Return null if the input is null. This can happen when calling the function
        ## recursively and a property is null
        If ($Null -eq $InputObject) {
            Return $Null
        }

        ## Check if the input is an array or collection. If so, we also need to convert
        ## those types into hash tables as well. This function will convert all child
        ## objects into hash tables (if applicable)
        If ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [System.String]) {
            $collection = @(
                ForEach ($object in $InputObject) {
                    ConvertTo-Hashtable -InputObject $object
                }
            )

            ## Return the array but don't enumerate it because the object may be pretty complex
            Write-Output -NoEnumerate -InputObject $collection
        }
        ElseIf ($InputObject -is [psobject]) {
            ## If the object has properties that need enumeration
            ## Convert it to its own hash table and return it
            $hash = @{ }
            ForEach ($property in $InputObject.PSObject.Properties) {
                $hash[$property.Name] = ConvertTo-Hashtable -InputObject $property.Value
            }
            $hash
        }
        Else {
            ## If the object isn't an array, collection, or other object, it's already a hash table
            ## So just return it.
            $InputObject
        }
    }
}

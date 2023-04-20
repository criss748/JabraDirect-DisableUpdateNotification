Function Format-Json {
    <#
    .SYNOPSIS
        Prettifies JSON output.
    .DESCRIPTION
        Reformats a JSON string so the output looks better than what ConvertTo-Json outputs.
    .PARAMETER Json
        Required: [string] The JSON text to prettify.
    .PARAMETER Minify
        Optional: Returns the json string compressed.
    .PARAMETER Indentation
        Optional: The number of spaces (1..1024) to use for indentation. Defaults to 4.
    .PARAMETER AsArray
        Optional: If set, the output will be in the form of a string array, otherwise a single string is output.
    .EXAMPLE
        $json | ConvertTo-Json  | Format-Json -Indentation 2
    #>
    [CmdletBinding(DefaultParameterSetName = 'Prettify')]
    Param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Json,

        [Parameter(ParameterSetName = 'Minify')]
        [switch]$Minify,

        [Parameter(ParameterSetName = 'Prettify')]
        [ValidateRange(1, 1024)]
        [int]$Indentation = 4,

        [Parameter(ParameterSetName = 'Prettify')]
        [switch]$AsArray
    )

    if ($PSCmdlet.ParameterSetName -eq 'Minify') {
        return ($Json | ConvertFrom-Json) | ConvertTo-Json -Depth 100 -Compress
    }

    # If the input JSON text has been created with ConvertTo-Json -Compress
    # then we first need to reconvert it without compression
    if ($Json -notmatch '\r?\n') {
        $Json = ($Json | ConvertFrom-Json) | ConvertTo-Json -Depth 100
    }

    $indent = 0
    $regexUnlessQuoted = '(?=([^"]*"[^"]*")*[^"]*$)'

    $result = $Json -split '\r?\n' |
        ForEach-Object {
            # If the line contains a ] or } character, 
            # we need to decrement the indentation level unless it is inside quotes.
            if ($_ -match "[}\]]$regexUnlessQuoted") {
                $indent = [Math]::Max($indent - $Indentation, 0)
            }

            # Replace all colon-space combinations by ": " unless it is inside quotes.
            $line = (' ' * $indent) + ($_.TrimStart() -replace ":\s+$regexUnlessQuoted", ': ')

            # If the line contains a [ or { character, 
            # we need to increment the indentation level unless it is inside quotes.
            if ($_ -match "[\{\[]$regexUnlessQuoted") {
                $indent += $Indentation
            }

            $line
        }

    if ($AsArray) { return $result }
    return $result -Join [Environment]::NewLine
}

# ---------------------------------------------------------------------------------
# NAME: JabraDirect-DisableUpdateNotification-All Users
# 
# AUTHOR: Ellis Barrett - A365
# FORK A: criss748 
#
# CREATION DATE: 14/07/2022
# FORK DATE: 20/04/2023
# ---------------------------------------------------------------------------------

#Get Userlist
$allusers=dir c:\users -Directory -Attributes directory,hidden |ft name -HideTableHeaders > userlist.txt

#Clean list
Get-Content -Path .\userlist.txt | ForEach-Object {$_ -Replace ' ', ''} |where {$_ -ne ""} | Set-Content -Path .\userlist2.txt
$allusers=Get-Content -Path .\userlist2.txt |Where-Object {($_ -notlike 'Public') -and ($_ -notlike 'AllUsers') -and ($_ -notlike 'DefaultUser')}


#Run
foreach ($user in $allusers)
	{
	$path="C:\Users\$user\AppData\Roaming\Jabra Direct\config.json"
	If (Test-Path("$path")) 
		{
		Write-Output "-- Found the Config File,by $user applying changes"
		$a = Get-Content "$path" -Raw | ConvertFrom-Json

       		$a.DirectShowNotification.value = $false
       		$a.DirectShowNotification.locked = $true

	        $a.EnableFeedback.value = $false
        	$a.EnableFeedback.locked = $true

	        $a | ConvertTo-Json -Depth 3 | Format-Json | Set-Content "$path" -Encoding UTF8
        	((Get-Content "$path") -join "`n") + "`n" | Set-Content -NoNewline "$path"
		} else 
	{
        Write-Output "-- Didn't find the Config File"
        #If (Test-path("C:\Program Files (x86)\Jabra\Direct4\jabra-direct.exe")) {
           #Write-Output "--- But Jabra Direct is installed, creating a Config File"
	    
	    $dir="C:\Users\$user\AppData\Roaming\Jabra Direct"
            If (-Not (Test-Path("$dir"))) {
                New-Item "$dir" -type directory -Force | out-null
                Write-Output "-- Created '$dir'"
            } 
            $ConfigurationRequest = @{
                DirectShowNotification = @{
                    key = "DirectShowNotification"
                    value = $false
                    locked = $true
                }
                EnableFeedback = @{
                    key = "EnableFeedback"
                    value = $false
                    locked = $true
                }   
            }
            $ConfigurationRequest | ConvertTo-Json -depth 100 | Set-Content "$path"
            $a = Get-Content "$path" -Encoding UTF8 | ConvertFrom-Json
            $a | ConvertTo-Json -Depth 3 | Format-Json | Set-Content "$path" -Encoding UTF8
            ((Get-Content "$path") -join "`n") + "`n" | Set-Content -NoNewline "$path"
        #}
        
    }
}
del userlist* -force

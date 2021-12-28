﻿###################################################################################
if (!(Test-Path -Path $Path))
{
New-Item -ItemType "directory" -Path $Path
}
Get-ChildItem C:\ -Recurse -ErrorAction silentlycontinue -Filter '*.pst' | select fullname, @{label='size';Expression={$_.length/1MB}} | export-csv $path\Pstsize.csv -NoType
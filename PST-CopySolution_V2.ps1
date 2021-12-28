#==========================================================================================================
#PST Backup - This script will search & copy all *.PST files which are in C: Drive to C:\Intune\PST folder
#==========================================================================================================

Stop-Process -ProcessName *outlook* -Force
Start-Sleep -Seconds 3
$Path = 'C:\intune\PST'
$script_scope = 'c:\'
if (!(Test-Path -Path $Path))
{
New-Item -ItemType "directory" -Path $Path
}
get-childitem $script_scope -recurse -Force -ErrorAction SilentlyContinue -filter *.pst | Where-Object {$_.FullName -notlike 'C:\$RECYCLE.BIN\*' } |
Select fullname,length |
export-csv $Path\PSTfiles.csv -notype -Append
Import-CSV C:\intune\pst\PSTfiles.csv | ForEach-Object{Copy-Item -Path $_.FullName -Destination $Path }

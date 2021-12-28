$backUpTo = "C:\Intune\Printers"
if (!(Test-Path -Path $backUpTo))
{
New-Item -ItemType "directory" -Path $backUpTo
}
Try{
Get-WmiObject win32_printer -ComputerName $env:COMPUTERNAME|
Select-Object -Property Name, Network, Default, Location, ShareName, ServerName | 
Export-csv -Path "$($backUpTo)\AllPrinters.csv" -NoTypeInformation 

Start-Sleep -Seconds 3
 
$PrinterCollection = Import-Csv "C:\Intune\Printers\AllPrinters.csv"

$PrinterCollection | Where-Object {$_.Network -eq $true} |
            
 Select name, Network, Location, ShareName, ServerName |
 Export-Csv -Path "$($backUpTo)\NetworkPrinters.csv" -NoTypeInformation -Append
            }
         
Catch{

{
Write-Error "Printers not found"
} 
}

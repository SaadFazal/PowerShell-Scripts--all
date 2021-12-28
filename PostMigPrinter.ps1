Import-Csv C:\intune\Printers\NetworkPrinters.csv | ForEach-Object {
$prnname = $($_.Name)
Add-Printer -ConnectionName $prnname -ErrorAction SilentlyContinue
}
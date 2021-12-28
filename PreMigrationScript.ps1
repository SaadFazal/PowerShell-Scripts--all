
#=============================================================
#Create a local admin and add it to the administrators group
#=============================================================

New-LocalUser -Name "localadmin003" -AccountNeverExpires:$true -Password ( ConvertTo-SecureString -AsPlainText -Force 'B@usch_Batch_001')
Add-LocalGroupMember -Group "Administrators" -Member "localadmin003"




#=============================================================
#Get Printer Info and Export in C:\Intune\Printer
#=============================================================


$backUpTo = "C:\Intune\Printers"
if (!(Test-Path -Path $backUpTo))
{
New-Item -ItemType "directory" -Path $backUpTo
}
Try{
Get-WmiObject win32_printer -ComputerName $env:COMPUTERNAME|
Select-Object -Property Name, Network, Default, Location, ShareName, ServerName | 
Export-csv -Path "$($backUpTo)\$($env:USERNAME)_Printer.csv" -NoTypeInformation 

Start-Sleep -Seconds 5
 
$PrinterCollection = Import-Csv "C:\Intune\Printers\$($env:USERNAME)_Printer.csv"

$PrinterCollection | Where-Object {$_.Network -eq $true} |
            
 Select name, Network, Location, ShareName, ServerName |
 Export-Csv -Path "$($backUpTo)\$($env:USERNAME)_NetworkPrintersOnly.csv" -NoTypeInformation -Append
            }
         
Catch{

{
Write-Error "Printers not found"
} 
}




#=============================================================
#Get Network Drive and Export in C:\Intune\NetworkDrive
#=============================================================


# Define array to hold identified mapped drives.
$Path2 = "c:\intune\MappedDrives"
New-Item -ItemType Directory -Force -Path $Path2
$Test2 = Test-Path -Path $Path2
if ($Test2 -like 'true' )
{
$mappedDrives = @()
# Get a list of the drives on the system, including only FileSystem type drives.


$drives = Get-PSDrive -PSProvider FileSystem
# Iterate the drive list

foreach ($drive in $drives) {
    # If the current drive has a DisplayRoot property, then it's a mapped drive.
    if ($drive.DisplayRoot) {
        # Exctract the drive's Name (the letter) and its DisplayRoot (the UNC path), and add then to the array.
        $mappedDrives += Select-Object Name,DisplayRoot -InputObject $drive
    }
}
}
# Take array of mapped drives and export it to a CSV file.
$mappedDrives | Export-Csv -Path c:\intune\MappedDrives\NetworkDrive.csv -Force -NoTypeInformation


#=============================================================
 #Decrypt Bitloicker Drive
#=============================================================

$BLV = Get-BitLockerVolume
Disable-BitLocker -MountPoint $BLV

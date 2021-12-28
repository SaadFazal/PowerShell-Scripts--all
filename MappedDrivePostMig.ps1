# Import drive list.
$mappedDrives = Import-Csv C:\Intune\MappedDrives\NetworkDrive.csv
# Iterate over the drives in the list. 
foreach ($drive in $mappedDrives) 
{ 
# Create a new mapped drive for this entry. 
New-PSDrive -Name $drive.Name -PSProvider "FileSystem" -Root $drive.DisplayRoot -Persist -ErrorAction Continue 
}

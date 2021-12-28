<#

.COPYRIGHT
Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.
See LICENSE in the project root for license information.

Script will bulk delete Intune device entry.

#>

#Connect-MSGraph
Connect-MSGraph



$Path = Read-Host -Prompt 'Enter a CSV path containing serial number' 
$test = Test-Path -Path $Path
if ($test -eq 'true' ) 
{

}

    Else
{
Write-Host $SNFile "does not exist" -ForegroundColor Red
}

$SNFile=Import-Csv -Path $Path

    foreach($SN in $SNFile.SerialNumber)


{
try{
Remove-IntuneManagedDevice -managedDeviceId $(Get-AutopilotDevice -serial $SN).manageddeviceid 
Write-Host "Serial Number" $SN "successfully deleted from Intune" -ForegroundColor Green

}
catch
{
Write-Host "Serial Number " $SN "failed to delete the Intune device entry" -ForegroundColor Red
}
}
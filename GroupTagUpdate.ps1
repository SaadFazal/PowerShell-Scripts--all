<#

.COPYRIGHT
Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.
See LICENSE in the project root for license information.

Script will bulk update autopilot device group tags.

#>

#Connect-MSGraph
Connect-MSGraph


$GT = Read-Host "Enter Group Tag"
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
Set-AutopilotDevice -id $(Get-AutopilotDevice -serial $SN).id -groupTag $GT
Write-Host "Serial Number" $SN "successfully updated" -ForegroundColor Green

}
catch
{
Write-Host "Serial Number " $SN "failed to update" -ForegroundColor Red
}
}
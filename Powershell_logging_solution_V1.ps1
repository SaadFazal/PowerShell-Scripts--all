<#
.SYNOPSIS
    PowerShell Scripts logging solution for Windows devices.
.DESCRIPTION
    PowerShell Scripts logging solution for Windows devices.
#>




#Powershell logging solution

#01- Enable PS Transcription logging

#Create a new folder for logging
New-Item -Path "C:\Intune" -ItemType Directory -Name "PSLogs" -Force -ErrorAction SilentlyContinue
#Transcript path
$OutputDirectory = "C:\Intune\PSLogs"
# Registry path
$basePath = 'HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell\Transcription'

# Create the key if it does not exist
if (-not (Test-Path $basePath)) {
    $null = New-Item $basePath -Force

    # Create the correct properties
    New-ItemProperty $basePath -Name "EnableInvocationHeader" -PropertyType Dword
    New-ItemProperty $basePath -Name "EnableTranscripting" -PropertyType Dword
    New-ItemProperty $basePath -Name "OutputDirectory" -PropertyType String
    

    # These can be enabled (1) or disabled (0) by changing the value
    Set-ItemProperty $basePath -Name "EnableInvocationHeader" -Value "1"
    Set-ItemProperty $basePath -Name "EnableTranscripting" -Value "1"
    Set-ItemProperty $basePath -Name "OutputDirectory" -Value $OutputDirectory
}

#02 - Script PS Block Logging

# Registry key 
$basePath = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' 
# Create the key if it does not exist 
if(-not (Test-Path $basePath)) 

{     
    $null = New-Item $basePath -Force     

    # Create the correct properties      
    New-ItemProperty $basePath -Name "EnableScriptBlockLogging" -PropertyType Dword 
} 
# These can be enabled (1) or disabled (0) by changing the value 
Set-ItemProperty $basePath -Name "EnableScriptBlockLogging" -Value "1"
 
# 03- Enable-AllModuleLogging

    # Registry Path     
    $basePath = 'HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames' 
    
    # Create the key if it does not exist
    if(-not (Test-Path $basePath))
    {
	$null = New-Item $basePath -Force
    
    # Set the key value to log all modules
    Set-ItemProperty $basePath -Name "*" -Value "*"
    }
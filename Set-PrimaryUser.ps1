#region Initialisation...
<#

.COPYRIGHT
Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.
See LICENSE in the project root for license information.

#>
####################################################
####################################################
#Instantiate Vars
####################################################

[CmdLetBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true,
        ValueFromPipeline = $True,
        HelpMessage = 'Please provide source AzureAD tenant name'
    )]
    [ValidateNotNullOrEmpty()]
    [string] $Tenant,

    [Parameter(Position = 2, ValueFromPipelineByPropertyName = $true,
        ValueFromPipeline = $True,
        HelpMessage = 'Please provide the source Azure tenant ID'
    )]
    [ValidateNotNullOrEmpty()]
    [string] $TenantId,

    [Parameter(Position = 3, ValueFromPipelineByPropertyName = $true,
        ValueFromPipeline = $True,
        HelpMessage = 'Please provide the Application (client) ID for authentication'
    )]
    [ValidateNotNullOrEmpty()]
    [string] $clientId = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547", 
    
    [Parameter(Position = 4, ValueFromPipelineByPropertyName = $true,
        ValueFromPipeline = $True,
        HelpMessage = 'Please provide the username for authentication'
    )]
    [ValidateNotNullOrEmpty()]
    [string] $Username,

    [Parameter(Position = 5, ValueFromPipelineByPropertyName = $true,
        ValueFromPipeline = $True,
        HelpMessage = 'Please provide the full path, including the filename, to the CSV file containing the list of devices and associated primary users'
    )]
    [ValidateNotNullOrEmpty()]
    [string] $CSVFile
)

$Global:exitCode = 0
$BuildVer = "1.0"
$ProgramFiles = $env:ProgramFiles
$ScriptName = $myInvocation.MyCommand.Name
$ScriptName = $ScriptName.Substring(0, $ScriptName.Length - 4)
$LogName = $ScriptName + "_" + (Get-Date -UFormat "%d-%m-%Y")
$logPath = "$($env:Temp)\$ScriptName"
$logFile = "$logPath\$LogName.log"
Add-Type -AssemblyName Microsoft.VisualBasic
$EventLogName = "Application"
$EventLogSource = $ScriptName

####################################################
####################################################
#Build Functions
####################################################

Function Start-Log {
    param (
        [string]$FilePath,

        [Parameter(HelpMessage = 'Deletes existing file if used with the -DeleteExistingFile switch')]
        [switch]$DeleteExistingFile
    )
		
    #Create Event Log source if it's not already found...
    $ErrorActionPreference = 'SilentlyContinue'
    If (!([system.diagnostics.eventlog]::SourceExists($EventLogSource))) { New-EventLog -LogName $EventLogName -Source $EventLogSource }
    $ErrorActionPreference = 'Continue'

    Try {
        If (!(Test-Path $FilePath)) {
            ## Create the log file
            New-Item $FilePath -Type File -Force | Out-Null
        }
            
        If ($DeleteExistingFile) {
            Remove-Item $FilePath -Force
        }
			
        ## Set the global variable to be used as the FilePath for all subsequent Write-Log
        ## calls in this session
        $global:ScriptLogFilePath = $FilePath
    }
    Catch {
        Write-Error $_.Exception.Message
    }
}

####################################################

Function Write-Log {
    #Write-Log -Message 'warning' -LogLevel 2
    #Write-Log -Message 'Error' -LogLevel 3
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
			
        [Parameter()]
        [ValidateSet(1, 2, 3)]
        [int]$LogLevel = 1,

        [Parameter(HelpMessage = 'Outputs message to Event Log,when used with -WriteEventLog')]
        [switch]$WriteEventLog
    )
    Write-Host
    Write-Host $Message
    Write-Host
    $TimeGenerated = "$(Get-Date -Format HH:mm:ss).$((Get-Date).Millisecond)+000"
    $Line = '<![LOG[{0}]LOG]!><time="{1}" date="{2}" component="{3}" context="" type="{4}" thread="" file="">'
    $LineFormat = $Message, $TimeGenerated, (Get-Date -Format MM-dd-yyyy), "$($MyInvocation.ScriptName | Split-Path -Leaf):$($MyInvocation.ScriptLineNumber)", $LogLevel
    $Line = $Line -f $LineFormat
    Add-Content -Value $Line -Path $ScriptLogFilePath
    #If ($WriteEventLog) { Write-EventLog -LogName $EventLogName -Source $EventLogSource -Message $Message  -Id 100 -Category 0 -EntryType Information }
}

####################################################

function Get-IntuneDevicePrimaryUser {

    <#
.SYNOPSIS
This lists the Intune device primary user
.DESCRIPTION
This lists the Intune device primary user
.EXAMPLE
Get-IntuneDevicePrimaryUser
.NOTES
NAME: Get-IntuneDevicePrimaryUser
#>

    [cmdletbinding()]

    param
    (
        [Parameter(Mandatory = $true)]
        [string] $IntuneDeviceId
    )

    $Resource = "deviceManagement/managedDevices"
    $uri = "$($Resource)" + "/" + $IntuneDeviceId + "/users"

    try {
        $primaryUser = Invoke-GraphRequest -Query $uri -ErrorAction Stop

        Return $primaryUser.id
    }
    catch {
        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        throw "Get-IntuneDevicePrimaryUser error"
    }
}

####################################################

function Set-IntuneDevicePrimaryUser {

    <#
.SYNOPSIS
This updates the Intune device primary user
.DESCRIPTION
This updates the Intune device primary user
.EXAMPLE
Set-IntuneDevicePrimaryUser
.NOTES
NAME: Set-IntuneDevicePrimaryUser
#>

    [cmdletbinding()]

    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $IntuneDeviceId,
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $UserId
    )

    $uri = "deviceManagement/managedDevices('$IntuneDeviceId')/users/`$ref"

    try {

        $userUri = "https://graph.microsoft.com/beta/users/$UserId"

        $id = "@odata.id"
        $body = @{ $id = $userUri }

        Invoke-GraphRequest -Query $uri -Method Post -Body $body -ErrorAction Stop

    }
    catch {
        throw
    }

}

####################################################

Clear-Host
Start-Log -FilePath $logFile -DeleteExistingFile
Write-Host
Write-Host "Script log file path is [$logFile]" -f Cyan
Write-Host
Write-Log -Message "Starting $ScriptName version $BuildVer" -WriteEventLog

#endregion Initialisation...
##########################################################################################################
##########################################################################################################
#region Main Script work section
##########################################################################################################
##########################################################################################################
#Main Script work section
##########################################################################################################
##########################################################################################################

#region auth
$module = "minigraph"
#Install-Module -Name $module -Force -AllowClobber
Try {
    Import-Module $module -Force
}
Catch {
    Write-Log -Message "Error importing module: $module"
    Write-Log -Message "Ensure you install the module first using command: Install-Module -Name $module -Force"
    Throw
}

Write-Log -Message "Authenticate to Graph and AzureAD..." -WriteEventLog
Write-Log -Message "Username: $UserName" -WriteEventLog

$adminPwd = Read-Host -AsSecureString -Prompt "Enter password for $Username"
$creds = New-Object System.Management.Automation.PSCredential ($Username, $adminPwd)

#Connect-GraphCredential -Credential $creds -ClientID $clientID -TenantID $tenant -Scopes 'user.read', 'user.readbasic.all'
Connect-GraphCredential -Credential $creds -ClientID $clientID -TenantID $tenant
Set-GraphEndpoint -Type beta
# Removing alias to avoid Microsoft.Graph collision
Remove-Item alias:\Invoke-GraphRequest -ErrorAction Ignore
#endregion auth

#region validate CSV file
Write-Log -Message "Validating CSV file..."
If (Test-Path -Path $CSVFile) {
    Write-Log -Message "Using CSVFile: $CSVFile"
    $primaryUsers = Import-Csv -Path $CSVFile
}
Else {
    Write-Log -Message "Error - file not found: $CSVFile"
    Throw
}
#endregion validate CSV file

foreach ($primaryUser in $primaryUsers) {
    Write-Log -Message "Read from CSV - applying primary user: $($primaryUser.User) to device: $($primaryUser.Device)"

    #region primary user
    $intuneUser = Invoke-GraphRequest -Query "users" | Where-Object -Property "displayName" -EQ $($primaryUser.User)
    $intuneUserCount = @($intuneUser).Count
    Write-Log -Message "User query returned: $intuneUserCount object(s)"

    If ($intuneUserCount -ne 1 ) {
        Write-Log -Message "Error with user query"
        Throw
    }
    Write-Log -Message "Found user: $($intuneUser.displayName) with id: $($intuneUser.id)"
    #endregion primary user

    #region device
    $intuneDevice = Invoke-GraphRequest -Query "deviceManagement/managedDevices" | Where-Object -Property "deviceName" -EQ $($primaryUser.Device)
    $intuneDeviceCount = @($intuneDevice).Count
    Write-Log -Message "Device query returned: $intuneDeviceCount object(s)"

    If ($intuneDeviceCount -ne 1 ) {
        Write-Log -Message "Error with device query"
        Throw
    }
    Write-Log -Message "Found device: $($intuneDevice.deviceName) with id: $($intuneDevice.id)"
    #endregion device

    #region set primary user
    Write-Log -Message "Setting Primary user: $($primaryUser.User) to device: $($intuneDevice.id)"
    Set-IntuneDevicePrimaryUser -IntuneDeviceId $intuneDevice.id -UserId $intuneUser.id

    $intuneDevicePrimaryUser = Get-IntuneDevicePrimaryUser -IntuneDeviceId $intuneDevice.id
    Write-Log -Message "Device: $($intuneDevice.deviceName), Primary User: $intuneDevicePrimaryUser"
    #endregion set primary user
}

Write-Log -Message "Script end."
##########################################################################################################
##########################################################################################################
#endregion Main Script work section
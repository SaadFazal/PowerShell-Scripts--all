$TenantId = 'msmadlab1.onmicrosoft.com'
$ClientID = 'f4b48da1-af65-45f8-ace8-0f9e332765da'
$ClientSecret = 'four@4ivP6UnJuOHIf?A-H9SHVrxGMFvxe@'

$APDevices = Import-Csv "<pathToCsv"

try {
    # Get Access Token
    $Body = @{
        client_id=$ClientID
        client_secret=$ClientSecret
        grant_type="client_credentials"
        scope="https://graph.microsoft.com/.default"
    }

    $OAuthReq = Invoke-RestMethod -Method Post -Uri https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token -Body $Body

    foreach ($ApDevice in $APDevices) {
        Try {
            [int] $count = 0
            $GetURI = [string]::Empty

            $GetURI = "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeviceIdentities/?`$filter=contains(serialNumber,'{0}')" -f $APDevices.serialnumber

            $Results = [string]::Empty

            # Query for device
            $Results = Invoke-RestMethod -Headers @{Authorization = "Bearer $($OAuthReq.access_token)"} -Uri $GetURI -Method GET
            
            [int] $count = $Results."@odata.count"

            switch ($count) {
                0 {
                    write-host "no results returned"
                }

                1 {
                    write-host "Found 1 result:"
                    $Results.value
                    $RemovalURI = "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeviceIdentities/{0}" -f $Results.value.id
                    try {
                        write-host "Removing $($APDevices.serialnumber)"
                        Invoke-RestMethod -Headers @{Authorization = "Bearer $($OAuthReq.access_token)"} -Uri $RemovalURI -Method DELETE
                        # Is anything returned that would confirm that the request was successful?

                        write-host "Command completed"
                    } catch {
                        write-host "An error occurred when attempting to remove device. Error: $_"
                    }
                }

                default {
                    write-host "More than one result was returned. Skipping"
                }
            }
        } catch {
            Write-Host "An error occurred when attempting to query device serial number: $_" 
        }
    }
} catch {
    Write-Host "Failed to get Access Token: $_"
}

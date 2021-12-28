Connect-AzureAD

$grpname = Read-Host -Prompt "Please specify the Group Name"
           Write-Host
         
Import-Csv C:\temp\grp_membership_update.csv.csv | ForEach-Object {
    
     Try   
       {
        $devname = $($_.DevName)
        $grpID = Get-AzureADGroup -SearchString $grpname
        $grpID = $grpID.ObjectId
        $devID = Get-AzureADDevice -SearchString $devname
        $devID = $devID.ObjectId
       
        Add-AzureADGroupMember -ObjectId $grpID -RefObjectId $devID
        $success = $devname + " Succesfully added to " + $grpname
        Write-Host $success -ForegroundColor Green
       }
     Catch
       {
        $Fail = "Operation failed for " + $devname
        Write-Host $Fail -ForegroundColor Red
       }
}
$password = ConvertTo-SecureString -String "Bausch@123" -AsPlainText -Force 
$Localuser= gwmi -class Win32_UserAccount | Where {$_.Name -eq "localadmin003"}
if($localuser.Name -match  "localadmin003")
{
$UserAccount = Get-LocalUser -Name "localadmin003"
$UserAccount | Set-LocalUser -Password $Password | Add-LocalGroupMember -Group "Administrators" -Member "localadmin003" -Verbose

}

else
{

New-LocalUser -Name "localadmin003" -AccountNeverExpires:$true -Password ( ConvertTo-SecureString -AsPlainText -Force 'Bausch@123')
$var = get-wmiobject Win32_Account -filter "Domain=""$ENV:ComputerName"" AND SID=""S-1-5-32-544"""
Add-LocalGroupMember -Group $var.name -Member "localadmin003"

}

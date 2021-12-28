﻿$Profiles = Get-CimInstance -Class Win32_UserProfile | where {$_.localpath -notlike "*c:\windows*" -and $_.LocalPath.split('\')[-1] -ne 'localadmin003'}Foreach ($profile in $profiles) {            write-host "Renaming profile: $($profile.localpath)"        Rename-Item $($profile.LocalPath) -NewName "$($Profile.LocalPath)`_old"         write-host "removing $($profile.LocalPath)"         $Profile | Remove-CimInstance  -ErrorAction SilentlyContinue    }
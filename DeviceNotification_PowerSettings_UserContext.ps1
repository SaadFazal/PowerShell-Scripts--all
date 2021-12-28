##Script must run as a user context!!


#PowerSettings set to NEVER expire!!
Powercfg /Change monitor-timeout-ac 0
Powercfg /Change monitor-timeout-dc 0
Powercfg /Change standby-timeout-ac 0
Powercfg /Change standby-timeout-dc 0

#Below script will present notification!!

Add-Type -AssemblyName PresentationCore,PresentationFramework;
[System.Windows.MessageBox]::Show("Your Device is in Maintenance Window and will be restarted multiple times. We will begin the device migration soon...")
﻿# Step 1: Define the destination folder and the PowerShell script content
$destinationFolder = "C:\Windows\System32\Tasks"
$psScriptContent = @'
# Detect the Removable Drive letters
$RemDrive = gwmi win32_diskdrive | ?{$_.interfacetype -eq "USB"} | %{gwmi -Query "ASSOCIATORS OF {Win32_DiskDrive.DeviceID=`"$($_.DeviceID.replace('\','\\'))`"} WHERE AssocClass = Win32_DiskDriveToDiskPartition"} | %{gwmi -Query "ASSOCIATORS OF {Win32_DiskPartition.DeviceID=`"$($_.DeviceID)`"} WHERE AssocClass = Win32_LogicalDiskToPartition"} | %{$_.deviceid}
# Store the recovery key to AzureAD with the device record
$BLV = Get-BitLockerVolume -MountPoint $RemDrive 
BackupToAAD-BitLockerKeyProtector -MountPoint $RemDrive -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
'@

# Step 2: Create and save the PowerShell script to the destination folder
$psScriptPath = "$destinationFolder\BackUpBLtoAAD.ps1"
$psScriptContent | Set-Content -Path $psScriptPath -Force

# Step 3: Create the Task Scheduler XML content
$taskXmlContent = @'
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2024-12-30T08:26:01.9990851</Date>
    <Author>Learning Lab\Harminderpal Sing</Author>
    <Description>Backup Bitlocker key to Azure AD tenant</Description>
    <URI>\BackUpRemovableBitLockerKey.xml</URI>
  </RegistrationInfo>
  <Triggers>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="Microsoft-Windows-BitLocker/BitLocker Management"&gt;&lt;Select Path="Microsoft-Windows-BitLocker/BitLocker Management"&gt;*[System[(EventID=768)]]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
    </EventTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-18</UserId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-ExecutionPolicy Bypass -File "C:\WINDOWS\System32\Tasks\BackUpBLtoAAD.ps1"</Arguments>
    </Exec>
  </Actions>
</Task>
'@

# Step 4: Register the scheduled task from the XML content
$taskXmlPath = "$destinationFolder\BackUpRemovableBitLockerKey.xml"
$taskXmlContent | Set-Content -Path $taskXmlPath -Force

# Step 5: Use schtasks to register the task from the XML
schtasks.exe /create /tn "BackUpRemovableBitLockerKey" /xml "$taskXmlPath"

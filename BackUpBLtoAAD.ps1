# Detect the Removable Drive letters
$RemDrive = gwmi win32_diskdrive | ?{$_.interfacetype -eq "USB"} | %{gwmi -Query "ASSOCIATORS OF {Win32_DiskDrive.DeviceID=`"$($_.DeviceID.replace('\','\\'))`"} WHERE AssocClass = Win32_DiskDriveToDiskPartition"} | %{gwmi -Query "ASSOCIATORS OF {Win32_DiskPartition.DeviceID=`"$($_.DeviceID)`"} WHERE AssocClass = Win32_LogicalDiskToPartition"} | %{$_.deviceid}
# Store the recovery key to AzureAD with the device record
$BLV = Get-BitLockerVolume -MountPoint $RemDrive 
BackupToAAD-BitLockerKeyProtector -MountPoint $RemDrive -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId

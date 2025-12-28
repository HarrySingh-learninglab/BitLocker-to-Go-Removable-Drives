$File = "C:\Windows\System32\Tasks\BackUpRemovableBitLockerKey" 
if (Test-Path $File) {
    write-output "Scheduled Task Detected, exiting" 
    exit 0
}
else {
    exit 1
}
<#
-----------------------------------
    Contact:    abevio GmbH
    Mail:       info@abevio.li
    Homepage:   www.abevio.li
    Tel:        00423 237 06 60
    Author:     Sebastian Beck
    Date:       26.08.2020
----------------------------------
.SYNOPSIS
This script loads the data of a csv which servers as log when script has last run. 
It then checks when it last run according to the username and if it's older then 6 days it removes the the content of the %TEMP%\Outlook-Logging\ Folder.
It writes username, hostname, nr of files and size of the folder before deletion to the log file. 

No Example No Parameters.

#>
$filepath = "\\ff\OutlookETL.CSV"
$TempFolder = "$($env:TEMP)\Outlook Logging"
$uname = $env:UserName
$hname = $env:ComputerName

$LastRunLine = Import-Csv -Path $filepath -Delimiter ";" | where {$_.Username -eq $uname} | Select -Last 1 
if(!$LastRunLine.Date)
{
    $delta = New-TimeSpan -Days 10
}
else
{
    $delta = New-TimeSpan -Start ($LastRunLine.Date -as [datetime]) -End (Get-Date)
}
if($delta.Days -ge 7)
{
    
    $FolderSize = "{0} MB" -f ((Get-ChildItem $TempFolder -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)
    $FileCount = (Get-ChildItem -Path $TempFolder | Where Name -Match "OUTLOOK.+\.etl").Count
    "{0};{1};{2};{3};{4}" -f (Get-Date -Format "dd/MM/yyyy"),$uname,$hname,$FileCount,$FolderSize | Add-content -path $filepath
    Remove-Item -path "$($TempFolder)\OUTLOOK_16_0*.etl"
}
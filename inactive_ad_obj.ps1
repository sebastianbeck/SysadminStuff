#Script to get user and computer Accounts who didn't log on for 3 months and empty user groups,
# Printers? not printed 3 months? .
0
#Author:  Beck Sebastian
#Date:    2019.01.16
#Version: v1.1

#environment Informatioan
    #Run from a DC Windows Server 2012 R2 where the Active Directory Powershell Module is enabled
    #Administrative Privileges needed

#AD Module import
Import-Module activedirectory

#$Variables
$90daysago = (Get-Date).AddDays(-90)
$SBUser = "OU=XXXXX,OU=XXXXXXX,DC=XXXXXX,DC=XXXXX"
$SBGroups = "OU=XXXXX,OU=XXXXXX,DC=XXXXXX,DC=XXXXX"
$outputpath = "\\srv-daten-01\IT-Betrieb$\Wartung\ActiveDirectory\"
$homedrive = "\\XXXXXX\XXXXXX$\"
$upd= "\\XXXXXX\XXXXXX$\" # we work with User profile disks. you can also check for the normal Roaming Profiler
$report = @()

#Get Computers
Get-ADComputer -Filter * -Properties * | ForEach-Object {
    if($90daysago -ge $_.LastLogonDate)
    {
        $report += New-Object psobject -Property @{Objekt=$_.Name;Date=$_.LastLogonDate;Homedrive="";UPD=""}
    }
}

#Get Users
Get-ADUser -SearchBase $SBUser -Filter * -Properties * | ForEach-Object {
    if($90daysago -ge $_.LastLogonDate)
    {
        if((Test-Path "$homedrive$($_.SamAccountName)") -and (Test-Path "$upd$($_.SID).vhdx")) #check if both exist, if you want to check for roaming Profiles you need to alter the second test-path
        {
            $report += New-Object psobject -Property @{Objekt=$_.CanonicalName;Date=$_.LastLogonDate;Homedrive="$homedrive$($_.SamAccountName)";UPD="$upd$($_.SID)"}
        }
        elseif(Test-Path $homedrive$($_.SamAccountName)) #only homedrive
        {
        $report += New-Object psobject -Property @{Objekt=$_.CanonicalName;Date=$_.LastLogonDate;Homedrive="$homedrive$($_.SamAccountName)";UPD=""}
        }
        elseif(Test-Path $upd$($_.SID)) #only UPD, if you use roaming profile and want to check that you need to chnge SID to Username or whatever
        {
        $report += New-Object psobject -Property @{Objekt=$_.CanonicalName;Date=$_.LastLogonDate;Homedrive="$homedrive$($_.SamAccountName)";UPD=""}
        }
        else{ #nothing matches
            $report += New-Object psobject -Property @{Objekt=$_.CanonicalName;Date=$_.LastLogonDate;Homedrive="";UPD=""}
        }
    }
}
#Get Groups
Get-ADUser -SearchBase $SBGroups -Filter * -Properties * | ForEach-Object {
    if($90daysago -ge $_.LastLogonDate)
    {
        $report += New-Object psobject -Property @{Objekt=$_.CanonicalName;Date=$_.LastLogonDate;Homedrive="";UPD=""}
    }
}
    $report | Select-Object Date, Objekt, Homedrive, UPD | Export-csv "$outputpath$(Get-Date -f yyyy-MM-dd) Inactive Users and Groups.csv" -Delimiter ';'
    
    $report = @()
#Empty Groups
Get-ADGroup -SearchBase $SBGroups -Filter * -Properties * | ForEach-Object {
    if($_.Members.Count -eq 0)
    {
        $report += New-Object psobject -Property @{Gruppenname=$_.CN}
    }
}
    $report | Export-csv "$outputpath$(Get-Date -f yyyy-MM-dd) Empty Groups.csv" -Delimiter ';'

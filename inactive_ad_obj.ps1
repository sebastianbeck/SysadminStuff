#Script to get user and computer Accounts which didn't log on for 3 months or more. 
#It also checks if the inactive user still has a home directory or RDS ProfileDisk.
#Additionally it will check Check for Empty AD Groups.
#It will output all the information in 3 different CSV Files on a network drive.

#Author:  Beck Sebastian
#Date:    2019.01.16
#Version: v1.2

#environment Informatioan
    #Run from a DC Windows Server 2012 R2 where the Active Directory Powershell Module is enabled

#AD Module import
Import-Module activedirectory

#Variables
#Sets the timeframe which will be searched
$90daysago = (Get-Date).AddDays(-90)
#Defines the Searchbase for the Users 
$SBUser = "OU=XXX,OU=YYYYYY,DC=DOMAIN,DC=COM"
#Defines the Searchbase for the groups 
$SBGroups = "OU=XXX,OU=YYYYYY,DC=DOMAIN,DC=COM"
#This Variable defines where the output is stored 
$path = "\\blablablabl\XXX\YYY\"
#Path to homedirectories
$homedir = "\\blablablabl\XXX\YYY\"
#Path to RDSProfileDisks
$profiledir = "\\blablablabl\XXX\YYY\"
#Needed for the output
$report = @()

#Get Computers
Get-ADComputer -Filter {LastLogonDate -le $90daysago} -Properties Name, LastLogonDate | ForEach-Object {
        $report += New-Object psobject -Property @{Objekt=$_.Name;Date=$_.LastLogonDate}
}
    $report | Export-csv "$path$(Get-Date -f yyyy-MM-dd) Inactive Hosts.csv" -Delimiter ';'
    $report = @()

#Get Empty Groups
Get-ADGroup -SearchBase $SBGroups -Filter * -Properties Members, CN | ForEach-Object {
    if($_.Members.Count -eq 0)
    {
        $report += New-Object psobject -Property @{Gruppenname=$_.CN}
    }
}
    $report | Export-csv "$path$(Get-Date -f yyyy-MM-dd) Empty Groups.csv" -Delimiter ';'
    $report = @()

#Get Old Users, Profile Disks and Home Folders
Get-ADUser -SearchBase $SBGroups -Filter {LastLogonDate -le $90daysago} -Properties SAMAccountName, CanonicalName, LastLogonDate | ForEach-Object {
    #Create home directory path for each user
    $homedirfull = $homedir + $_.SAMAccountName

    #Create RemoteDesktopprofileDisks  path
    $objUser = New-Object System.Security.Principal.NTAccount("a-group.li", $_.SAMAccountName)
    $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
    $profiledirfull = $profiledir + "UVHD-" + $strSID.Value + ".vhdx"
        
    #Homedir test
    if(Test-Path -Path $homedirfull)
    { 
        write-host $homedirfull
        $report += New-Object psobject -Property @{Objekt=$_.SAMAccountName;Date=$_.LastLogonDate;Path=$homedirfull}
    }
    #Profile test
    if(Test-Path -Path $profiledirfull)
    { 
        write-host $profiledirfull
        $report += New-Object psobject -Property @{Objekt=$_.SAMAccountName;Date=$_.LastLogonDate;Path=$profiledirfull}
    }
}
    $report | Export-csv "$path$(Get-Date -f yyyy-MM-dd) Old Users and Folders.csv" -Delimiter ';'
    $report = @()
# Useful short PowerShell commands 

Delete duplicate files source: https://n3wjack.net/2015/04/06/find-and-delete-duplicate-files-with-just-powershell/
```powershell
ls *.* -recurse | get-filehash | group -property hash | where { $_.count -gt 1 } | % { $_.group | select -skip 1 } | del
```
RoboCopy with permissions
```
ROBOCOPY "\\xxx\xxx$" "\\xxx\xxx$ /MIR /SEC /LOG:C:\temp\name.log
```
## AD
Export Users from a specific ad group 
```
Get-ADGroupMember GroupName| get-aduser -properties GivenName, SurName, mail | Select GivenName, SurName, Mail | export-csv -Path "" -Encoding Default
```
Export Users from AD to CSV File where EMailaddress is not empty (for example gophish campaign)
```powershell
Get-ADUser -SearchBase "ou=Users,ou=x,dc=x,dc=com" -Filter {EmailAddress -like '*'} -Properties * | select GivenName, SurName,EmailAddress | export-csv -Path "C:\temp\gg.csv" -Encoding "UTF8" -Delimiter ","

```
Export AD Computers with OS information
```powershell
Get-ADComputer -Filter * -Property * | Select-Object Name,OperatingSystem,OperatingSystemVersion | Export-CSV AllWindows.csv -NoTypeInformation -Encoding UTF8
```
Export AD Username and PW Expiry DAte
```
Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} –Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed" | Select-Object -Property "Displayname",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}} | Export-CSV PWExpiryDate.csv -NoTypeInformation -Encoding UTF8
```
Export AD Username and PW Last changed
```powershell
Get-ADUser -Filter * -Property * | Select-Object Name,PasswordLastset | Export-CSV PWLastSet.csv -NoTypeInformation -Encoding UTF8
```
## Exchange
Message Tracking example
```
Get-MessageTrackinglog -Start "05/15/2020 16:00:00" -End "05/19/2020 10:30:00" -Recipients "mail@mail.com" -Sender "mail@mail.com"
```
Get Mailbox size for a certain domain including username, alias and size
```
Get-Mailbox | Where-Object {($_.PrimarySMTPAddress -like "*@domain.com")} | ForEach-Object{Get-MailboxStatistics -Identity $_.Alias} | Select-Object DisplayName, Alias, TotalItemSize | Export-CSV C:\temp\test.csv
```

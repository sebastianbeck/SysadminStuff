# Useful short Powershell commands 

Delete duplicate files source: https://n3wjack.net/2015/04/06/find-and-delete-duplicate-files-with-just-powershell/
```powershell
ls *.* -recurse | get-filehash | group -property hash | where { $_.count -gt 1 } | % { $_.group | select -skip 1 } | del
```
Export Users from AD to CSV File where EMailaddress is not empty (for Exmaple Getgophish campaign)
```powershell
Get-ADUser -SearchBase "ou=Users,ou=blabla,dc=example,dc=com" -Filter {EmailAddress -like '*'} -Properties * | select GivenName, SurName, EmailAddress | export-csv -Path "" -Encoding Default

```
Export AD Computers with OS information
```powershell
Get-ADComputer -Filter * -Property * | Select-Object Name,OperatingSystem,OperatingSystemVersion | Export-CSV AllWindows.csv -NoTypeInformation -Encoding UTF8
```
Export AD Username and PW Last changed
```powershell
Get-ADUser -Filter * -Property * | Select-Object Name,PasswordLastset | Export-CSV PWLastSet.csv -NoTypeInformation -Encoding UTF8
```
RoboCopy with permissions
```
ROBOCOPY "\\xxx\xxx$" "\\xxx\xxx$ /MIR /SEC /LOG:C:\temp\name.log
```

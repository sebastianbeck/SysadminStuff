# Useful short Powershell commands 

Delete duplicate files source: https://n3wjack.net/2015/04/06/find-and-delete-duplicate-files-with-just-powershell/
```powershell
ls *.* -recurse | get-filehash | group -property hash | where { $_.count -gt 1 } | % { $_.group | select -skip 1 } | del
```
Export Users from AD to CSV File where EMailaddress is not empty (for Exmaple Getgophish campaign)
```powershell
Get-ADUser -SearchBase "ou=Users,ou=blabla,dc=example,dc=com" -Filter {EmailAddress -like '*'} -Properties * | select GivenName, SurName, EmailAddress | export-csv -Path "" -Encoding Default
```

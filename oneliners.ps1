# Usefull Powershell oneliner

## Delete duplicate files source: https://n3wjack.net/2015/04/06/find-and-delete-duplicate-files-with-just-powershell/
ls *.* -recurse | get-filehash | group -property hash | where { $_.count -gt 1 } | % { $_.group | select -skip 1 } | del

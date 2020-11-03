Import-Module ActiveDirectory
$objUser = New-Object System.Security.Principal.NTAccount("example.com", "xxx")
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
$strSID.Value
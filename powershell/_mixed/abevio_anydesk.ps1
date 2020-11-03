<#
.SYNOPSIS
    This scripts installs the abevio anydesk client on to the users desktop
.PAR
.DESCRIPTION
  tbd if wanted
.EXAMPLE
  EXAMPLE
.NOTES
  Version:          1.2
  Author:           Sebastian Beck (sebastian@abevio.li)
  Creation Date:    25.05.2020
  Purpose/Change:   See Changelog
#>
#---------------------------------------------------------[Parameters]--------------------------------------------------------

$url = "https://get.anydesk.com/bDBH0WWd/AnyDesk_abevio_Windows_Client.exe"
$output = "$env:USERPROFILE\Desktop\AnyDesk_abevio.exe"
$start_time = Get-Date

Invoke-WebRequest -Uri $url -OutFile $output
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
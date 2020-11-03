$starttime = Get-Date
#Import the csv with the MandatNR and Mandatbezeichnung
$csv = Import-CSV -Path "C:\x\x.csv" -Encoding "UTF8" -Delimiter ";"
#Setup Counters
$aktiv = 0
$notfound = 0
#Get the Folder Name and for each foldername
Get-ChildItem -Path C:\temp\test -Directory | ForEach-Object{
    $Mandatnr = $_.Name
    $row = $csv | Where {$_.MNR -eq $Mandatnr}
    if($row)
    {
        Write-Host $row.'Mandbez.'
        $aktiv = $aktiv + 1
    }
    else{
        Write-host "0"
        $notfound = $notfound + 1
    }
}
write-Host "Aktiv" $aktiv
write-host "not found" $notfound
New-TimeSpan -Start $starttime -End (Get-Date)
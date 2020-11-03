<#
.SYNOPSIS
Uses Hyper-V Manager Services & Hyper V-Modul for Powershell to optimize filesize of the .vhdx files and create a xlsx log. 
In my case it is used for RDS Profiledisks. 

TODO: 
1. option without excel
2. Description
3. Check Resize Command see- Get VHD the minimal File sizei s way lower then the one with optimization


.DESCRIPTION
As it's a pretty small script the synopsis already explains it. With the comments in the script everything should be clear.

Dependencies: 
Tested from from a Windows 10 machine with Excel 2016
* Needs excel installed to create the log file.
* Must run as administrator
* To open the VHDX files you at least need to enable the "Hyper-V Module for Powershell" and "Hyper-V Services" 
on the host where the script is started. You can do that like this (admin privileges are required):
Open Windows-Features --> Select the Hyper-V Manager Services & Hyper V-Modul for Powershell and then click on OK

.PARAMETER vhdxdir
Use this parameter to define where your vhdx files are stored. Please use this format \\server\share\folder\

.PARAMETER outputdir
Path to Log File, if Not set, it will use the directroy where you started the powershell script
#>

param(
	# Path to VHDX Files
    [parameter(Mandatory=$true)]	
    [string]
	$vhdxdir,

	# Path to Log File, if Not set it will use the default 
    [parameter(Mandatory=$false)]	
    [string]
	$outputdir = (Get-Location)
)
#Create Excel Log File 
$psbefore = Get-Process | % { $_.Id } #Excel does not close proberly with the $Excel.Quit() command, we get a list of all the process 
$Excel = New-Object -ComObject Excel.Application #Creates new Excel Process 
$excelId = Get-Process excel | % { $_.Id } | ? { $psbefore -notcontains $_ } #get the ProcessID of the Excel Process, with the ID we can close the process after the script
$Excel.Visible = $True #Excel is Stelath
$wb = $Excel.Workbooks.Add() #Create Excel
$ws = $wb.Sheets.Item(1) #Use Worksheet 1 

#Write the Table Information
$ws.cells.item(1,1) = "Nr"
$ws.cells.item(1,2) = "Username"
$ws.cells.item(1,3) = "VHDX"
$ws.cells.item(1,4) = "Mountable"
$ws.cells.item(1,5) = "Size before"
$ws.cells.item(1,6) = "Size After"
$ws.cells.item(1,7) = "Shrinked"

$i=2 #needed for the loop
$to=0 #used to calculate the total storage saved

#Check if paths are written in the correct format and corrects them 
if($vhdxdir -notmatch '.+?\\$')
{
$vhdxdir += '\'
write-host $vhdxdir
}
if($outputdir -notmatch '.+?\\$')
{
$outputdir += '\'
write-host $outputdir
}

Get-ChildItem $vhdxdir -File | ForEach-Object {
    $Fullvhdxdir = $vhdxdir + $_.Name #Creates Fullvhxdir 
    $vhdxname = $_.Name #ONly 
    #Split .VHDX that we have only the SID and translate the SID to username
    $SID = $vhdxname -split ("UVHD-") -Split (".vhdx")
    $objSID = New-Object System.Security.Principal.SecurityIdentifier($SID[1])
    $objUser = $objSID.Translate( [System.Security.Principal.NTAccount]).Value
    #Write Nr, Username, and VHDX Name into LOG File
    $ws.cells.item($i,1) = "$($i-1)"
    $ws.cells.item($i,2) = "$objUser"
    $ws.cells.item($i,3) = $vhdxname
    #Get infos of vhdx, if infos can't be retrieved the vhdx is mounted and it will be logged
    $Get = Get-VHD -Path $Fullvhdxdir -ErrorAction SilentlyContinue -ErrorVariable ProcessError
        if($ProcessError) #if an error happens during this the vhdx file won't be optimized 
            {
                $ws.cells.item($i,4) = "No"
            }
        else{#If the Get-VHD command doesn't get an error the file will be optimized and the infos will be written into the excel
                $ws.cells.item($i,4) = "Yes"
                $fs = $Get.FileSize / 1000000
                $ws.cells.item($i,5) = "$fs"
                Optimize-VHD -Path $Fullvhdxdir -Mode Full
                $Get = Get-VHD -Path $Fullvhdxdir
                $fs2 = $Get.FileSize / 1000000 
                $dif = $fs - $fs2
                $ws.cells.item($i,6) = "$fs2"
                $ws.cells.item($i,7) = "$dif"
                $to = $to + $dif
            }
    $i++
}
            $ws.cells.item($i,7) = "$to" #writes total
#Close Excel, save it and force the process to quit
$ws.columns.item("A:G").EntireColumn.AutoFit() | out-null
$excel.displayAlerts = $false
$wb.SaveAs("$outputdir$(Get-Date -UFormat %Y%m%d)VHDX-Optimization-Log.xlsx")
$wb.Close()
$Excel.Quit()
Stop-Process -ID $excelId

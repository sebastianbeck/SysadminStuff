#Script to replace a file in the UserProfile for all users in an RDS-environment with RDS ProfileDisks in use
#Author:  Beck Sebastian
#Date:    2018.12.17
#Version: v1.2

#environment Informatioan
    #Run from a Windows 10 Machine with Windows 2012 R2 Server
    #To Open the VHDX Files you at least need to enable the "Hyper-V Module for Powershell" and "Hyper-V Services" on the host where the script is started
    #You can do that like this (admin privileges are required)
    #Open Windows-Features --> Select the Hyper-V Manager Services & Hyper V-Modul for Powershell and then click on OK

#Define Variable
$Path = '\\xxxxxx\vhdx\' #Path to the VHDX Files 
$Source = 'C:\Temp\normal.dotm' # Source File to Copy to the Profiles
$logfile = 'C:\Temp\copy.log' #logs get written to this file

#Get File Names in the array and start loop
Get-ChildItem $Path -File | ForEach-Object {
    # Crate $FullPath Variable, Used to Mount the VHDX
    $FullPath = $Path + $_.Name
    #Get the SID out of the $FullPath variable. Translate the SID to username for logging   
    $SID = $FullPath -split "UVHD-"
    $SID = $SID[1]
    $SID = $SID -split ".vhdx"
    $objSID = New-Object System.Security.Principal.SecurityIdentifier ($SID[0])
    $objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
    #Mount VHDX silently continue with errors -> they will be shown in the log file 
    $Mount = Mount-VHD -Path $FullPath -PassThru -ErrorAction SilentlyContinue -ErrorVariable ProcessError | Get-Partition | Select DriveLetter
    
    #Figure out Drive Letter to where the VHDX gets mounted to access it
    $Mount = $Mount -Split "="
    $Mount = $Mount[1]
    $Mount = $Mount -Split "}"
    $Mount = $Mount[0]
    
    #Create the Paths to the Files for Copy and for the Rename
    $Destination = "$Mount" + ":\AppData\Roaming\Microsoft\Templates\"
    $OldNormalDotm = "$Mount" +":\AppData\Roaming\Microsoft\Templates\normal.dotm"
    if($ProcessError){
        "$objUser $FullPath ERROR: Couldn't Mount VHXD ************ " | Out-file -filepath $logfile -Append
    }
    else{    
        #Test if the Path exists. in this case if the user never started an Office application the Folder doesn't exist
        if(Test-Path $OldNormalDotm){
            #Rename default normal.dot and copy new normal.dot
            Rename-Item -Path $OldNormalDotm -NewName 'normal.dotmold'
            Copy-Item  -Path $Source -Destination $Destination -Recurse -force
            #Create Log if successfully
            "$objUser $FullPath Success" | Out-file -filepath $logfile -Append
        }
        else{
            #Create Log if not successfully
            "$objUser $FullPath ERROR: Office never started ************ " | Out-file -filepath $logfile -Append
        }
    
    #Dismount the File
    Dismount-VHD $FullPath 
    }
}

<#
.SYNOPSIS
This script uses the config created with "CreateConfig.ps1" and downloads the specified file to the given path.
If desired it will extract the archive files .gz and .zip. It is also able to send a mail notification.
A Log file is written to the $PSROOT Directory.
.EXAMPLE
./downloader_wCred.ps1 -Config config1.xml -dst "C:\Folder2\" -extract -overWriteURL"https://..." -mailcfg mxcfg.xml -recipient "xyz@domain.com"
.TODO: 
- variable cleaning
- file read as function

.DESCRIPTION:
This script will:
	-make sure that the config files end with .xml and check their existence
	-read the content of the config file
	-if needed overwrite the URL 
	-get the file name from the URL
	-Check if the destination ends with an \. This is needed to save the file correctly.
	-Sets TLS Settings to 1.2 
	-Download the file
	-figure out the file extension
	-if .gz or .zip extract the file and delete the archive
	-if mail notification is wished it will
		- check the config file again
		- reads the config file
		- sends mail
	-writes log

.Dependencies:
You need to run the Create Config script first to run this script.
The Folder should look something like this:
/Path to Script
|----CreateConfig.ps1
|----downloader.ps1
|----config1.xml
|----config2.xml
After that it will create a config file.
It is possible to create multiple config files. The config can only be used with the windows user which created the config file due to the way the password is saved.

.PARAMETER Config
Defines the name of the config file to use for the download
.PARAMETER dst
Defines the path to the Destination Folder. The user who runs the script needs to have access
.PARAMETER extract
If a zip or gzip is downloaded it will auto-extract it and delete the archive.
.PARAMETER mailcfg
Defines the name of the mailconfig file.
.PARAMETER sendmail
write the mail address of the recipient in "" 
.PARAMETER overwriteURL
overwrites the url in the -config file if needed
#>

# Parameters
param(
    [parameter(Mandatory=$true)]	
    [string]
	$Config,
    [parameter(Mandatory=$true)]	
    [string]
	$dst,
    [parameter(Mandatory=$false)]
    [switch]
    $extract,
    [parameter(Mandatory=$false)]
    [string]
    $mailcfg,
    [parameter(Mandatory=$false)]
    [string]
    $recipient,
    [parameter(Mandatory=$false)]
    [string]
    $overwriteURL
)
Function check-cfgfile{
    Param(
        $Config
        )
    #Check if the Parameter Name has already.xml endig, if not attach .xml at the end of the path
    if($Config -like '*.xml')
    {
        $XML_Path = "$($PSScriptRoot)\$($Config)"
    }
    else
    {
        $XML_Path = "$($PSScriptRoot)\$($Config).xml"
    }
     #Check if the config exists
    if (!(Test-Path($XML_Path))) 
    {
        $errMsg = "File $($XML_Path) not found. Please run CreateConfig.ps1 first."
        Write-Error $errMsg
        return
    }
    else{
        return $XML_Path
    }
}

#function DeGZip-File is extracting the .gz file , I stole this one online  but can't find the source
Function DeGZip-File{
    Param(
        $infile,
        $outfile = ($infile -replace '\.gz$','')
        )

    $input = New-Object System.IO.FileStream $inFile, ([IO.FileMode]::Open), ([IO.FileAccess]::Read), ([IO.FileShare]::Read)
    $output = New-Object System.IO.FileStream $outFile, ([IO.FileMode]::Create), ([IO.FileAccess]::Write), ([IO.FileShare]::None)
    $gzipStream = New-Object System.IO.Compression.GzipStream $input, ([IO.Compression.CompressionMode]::Decompress)

    $buffer = New-Object byte[](1024)
    while($true){
        $read = $gzipstream.Read($buffer, 0, 1024)
        if ($read -le 0){break}
        $output.Write($buffer, 0, $read)
        }

    $gzipStream.Close()
    $output.Close()
    $input.Close()
}

#this function is used to send the mail notificaiton
Function SendMail{
    Param(
        $mailcfg,
        $recipient,
        $status
        )
    $MXXML_Path = check-cfgfile $mailcfg
    [xml]$XMLDoc2= Get-Content $MXXML_Path
    $MXserver = $XmlDoc2.Configuration.URL
    $MXPort = $XMLDoc2.Configuration.Port
    $MXUsername = $XMLDoc2.Configuration.Username
    $MXPassword = $XMLDoc2.Configuration.Password
    $MXMyCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $MXUsername, ($MXPassword | ConvertTo-SecureString)
    Send-MailMessage -To $recipient -Subject "Worldcheck Import Weekly $($status)" -Body "The weekly worldcheck import job running on srv-mgmt-01 has $($status) at $(Get-Date)" -From $MXUsername -Credential $MXMyCredential -SmtpServer $MXserver
}

####################################################################################################
# Initialize
####################################################################################################
$XML_Path = check-cfgfile $Config
#Read Config File and Create Credential Object
[xml]$XMLDoc= Get-Content $XML_Path
$URL = $XmlDoc.Configuration.URL
$Port = $XMLDoc.Configuration.Port
$Username = $XMLDoc.Configuration.Username
$Password = $XMLDoc.Configuration.Password
$MyCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, ($Password | ConvertTo-SecureString)

#if the url of the config file should be overwritten for some testing etc.
if($overwriteURL)
{
    $URL = $overwriteURL
}

#get the file name from the url
$fn = $URL -split "/"
$fn = $fn[$fn.Count - 1]

#check if destination doesn't end with an \ and attaches one
if(!$dst -match '.+?\\$')
{
    $dst = "$($dst)\"
}
$dst ="$($dst)$($fn)"
Try{
    #Sets the TLS Setting to TLS 1.2 (Powershell would use 1.0 as default)
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    #Downloads the file using the variables from the config file and the destination variable
    Invoke-WebRequest -Uri $URL -Credential $MyCredential -OutFile $dst
    $extension =  dir $dst | Select Extension
    $extension = $extension.extension
    if($extension -eq ".gz" -and $extract)
        {
            #Unzips the .gz file & remove it
            DeGZip-File $dst
            Start-Sleep -s 3
            Remove-Item $dst
        }
    if($extension -eq ".zip" -and $extract)
        {
            #Unzips the .zip file & remove it
            Expand-Archive $dst
            Start-Sleep -s 3
            Remove-Item $dst
        }
    if($mailcfg -and $recipient)
        {
            SendMail -mailcfg $mailcfg -recipient $recipient -status "worked successfully"
        }
    Add-content "$($PSScriptRoot)\$($config)_history.log" -value "Weekly Worldcheck Download worked at $(Get-Date)"
    }
Catch{
    
    SendMail -mailcfg $mailcfg -recipient $recipient -status "failed"
    Add-content "$($PSScriptRoot)\$($config)_history.log" -value "Weekly Worldcheck Download failed at $(Get-Date)"
}

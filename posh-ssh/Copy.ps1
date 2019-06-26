<#
.SYNOPSIS
This script uses the config created with "CreateConfig.ps1" and connects to the sftp server to do the requiered task.
It will copy files or complete folders to the sftp server. The Source and Destination Folder are the parameters.
.EXAMPLE
./Copy.ps1 -Config config1.xml -src /folder1/folder2/ -dst "C:\Folder1\Folder2\" -direction down -mode move 
.TODO: 
- Add possibilty to change copy direction & Finish upload
- "Better Remove"

.DESCRIPTION:
This script checks if
    - Posh SSH is installed
    - the config and keys folder exist 
    - the name parameter has .xml at the and and adds it if not 
    - the config file exists
Afterwards it reads the config file and checks if the name of the key file still exists in the keys folder.
For each case (no key, keyfile and keystring )it opens the SSH Session and defines the commands which will be used later. 

.Dependencies:
You need to run the Create Config script first to run this script.
The Folder should look something like this:
/Path to Script
|----CreateConfig.ps1
|----Copy.ps1
|----configs
|    |----config1.xml
|----keys
|    |----key1
After that it will create a config file in the configs folder. 
It is possible to create multiple config files. The config can only be used with the windows user which created the config file due to the way the password is saved.
none as of yet, 
.PARAMETER Config
Defines the name of the config file to use
.PARAMETER src
Defines the path to the Source Directory/File. Needs to be the full path
.PARAMETER dst
Defines the path to the Destination Directory/File. Needs to be the full path
.PARAMETER direction
Defines if you want to upload or . It needs to be exactly "up" or "down" else it will fail
.PARAMETER mode
Defines if you copy or move 
#>
####################################################################################################
# Parameters
####################################################################################################
param(
    [parameter(Mandatory=$true)]	
    [string]
	$Config,
    [parameter(Mandatory=$true)]	
    [string]
	$src,
    [parameter(Mandatory=$true)]	
    [string]
	$dst,
    [parameter(Mandatory=$false)]	
    [string]
	$direction = "down",
    [parameter(Mandatory=$false)]	
    [string]
	$mode = "copy"
)
####################################################################################################
# Initialize
####################################################################################################
#Make sure that Posh-SSH is installed
if (!( Get-Module -ListAvailable -Name Posh-SSH))
{
    $errMsg = "Module Posh-SSH is required. Install the Module with this command: Install-Module Posh-SSH"
    Write-Error $errMsg
    return
}
#Make sure that the Create-Config.ps1 script has run and the folders/config is in the right place
if (!(Test-Path("$($PSScriptRoot)\Configs")))
{     
    $errMsg = "Folder $($PSScriptRoot)\Configs not found. Please run CreateConfig.ps1 first."
    Write-Error $errMsg
    return
}
if (!(Test-Path("$($PSScriptRoot)\Keys"))) 
{ 
    $errMsg = "Folder $($PSScriptRoot)\Keys Folder not found. Please run CreateConfig.ps1 first."
    Write-Error $errMsg
    return
}
#Check if the Parameter Name has already.xml endig, if not attach .xml at the end of the path
if($Config -like '*.xml')
{
    $XML_Path = "$($PSScriptRoot)\Configs\$($Config)"
}
else
{
    $XML_Path = "$($PSScriptRoot)\Configs\$($Config).xml"
}
 #Check if the config exists
if (!(Test-Path($XML_Path))) 
{
    $errMsg = "File $($XML_Path) not found. Please run CreateConfig.ps1 first."
    Write-Error $errMsg
    return
}
#Read Config 

#Read Config File and Create Credential Object
[xml]$XMLDoc= Get-Content $XML_Path
$Server = $XmlDoc.Configuration.Server
$Port = $XMLDoc.Configuration.Port
$Username = $XMLDoc.Configuration.Username
$Password = $XMLDoc.Configuration.Password
$KeyFile = $XMLDoc.COnfiguration.KeyFile
$KeyString = $XMLDoc.COnfiguration.KeyString
$MyCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, ($Password | ConvertTo-SecureString)

#Check if Keyfile still exists if the key file exists open connection with key file SSH Session only needed for Move mode
if ($KeyFile -And (Test-Path("$($PSScriptRoot)\Keys\$($KeyFile)")) -And ($mode -eq "move")) 
{ 
    $KeyfilePath = "$($PSScriptRoot)\Keys\$($KeyFile)"
    #Create Commands for the later if section
    $Session = New-SFTPSession -ComputerName $Server -Credential $MyCredential -Port $Port -KeyFile $KeyfilePath
    $Get = {Get-SCPFolder -ComputerName $Server -Credential $MyCredential -Port $Port -RemoteFolde $src -LocalFolder $dst -KeyFile $KeyfilePath}
    $RemoveF = {Remove-SFTPItem -SessionId $Session.SessionID -Path $src -Force}
    $RemoveS = {Remove-SFTPSession $Session.SessionID}
    $New = {New-SFTPItem -SessionId $Session.SessionID -Path $src -ItemType Directory}
} 
#if a key is listed in the config but it doesn't exist anymore it will give the user the following error
elseif($KeyFile -And !(Test-Path("$($PSScriptRoot)\Keys\$($KeyFile)"))) 
{
    $errMsg = "Folder $($PSScriptRoot)\Key file which is in the config does't exist anymore. Please reover keyfile or create new configfile"
    Write-Error $errMsg
    return
}
#if a keystring is defined 
elseif($KeyString  -And ($mode -eq "move"))
{
    #Create Commands for the later if section
    $Session = New-SFTPSession -ComputerName $Server -Credential $MyCredential -Port $Port -KeyString $KeyString
    $Get = {Get-SCPFolder -ComputerName $Server -Credential $MyCredential -Port $Port -RemoteFolde $src -LocalFolder $dst -KeyString $KeyString}
    $RemoveF = {Remove-SFTPItem -SessionId $Session.SessionID -Path $src -Force}
    $RemoveS = {Remove-SFTPSession $Session.SessionID}
    $New = {New-SFTPItem -SessionId $Session.SessionID -Path $src -ItemType Directory}
}
#if no keyfile is defined then open the connection without keyfile
elseif(($mode -eq "move"))
{
    #Create Commands for the later if section
    $Session = New-SFTPSession -ComputerName $Server -Credential $MyCredential -Port $Port
    $Get = {Get-SCPFolder -ComputerName $Server -Credential $MyCredential -Port $Port -RemoteFolde $src -LocalFolder $dst}
    $RemoveF = {Remove-SFTPItem -SessionId $Session.SessionID -Path $src -Force}
    $RemoveS = {Remove-SFTPSession $Session.SessionID}
    $New = {New-SFTPItem -SessionId $Session.SessionID -Path $src -ItemType Directory}
}
else
{
#mach nix im moment
}
#if the user wants to upload to do
if($direction -eq "up")
{
    #to finish with sevi
    if($mode -eq "move")
    {
    #to finish with sev
    }
    elseif($mode -eq "up")
    {
           
    }
    else
    {
    #error message to be exrtreme
    }

}
#if the users wants to download
elseif($direction -eq "down")
{
    if($mode -eq "move")
    {
        #Download Content, Delete the folder and create it again
        Invoke-Command -ScriptBlock $Get
        Invoke-Command -ScriptBlock $RemoveF
        Invoke-Command -ScriptBlock $New

    }
    elseif($mode -eq "copy")
    {
        Invoke-Command -ScriptBlock $Get
    }
    else
    {
        $errMsg = "The mode must be copy or move"
        Write-Error $errMsg
        return
    }
}
#Error 
else
{
    $errMsg = "The direction has to be up or down"
    Write-Error $errMsg
    return
}
Invoke-Command -ScriptBlock $RemoveS
#close session
#Remove-SFTPSession $Session

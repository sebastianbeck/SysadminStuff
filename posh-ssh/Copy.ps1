<#
.SYNOPSIS
This script uses the config created with "CreateConfig.ps1" and connects to the sftp server.
It will copy files or complete folders to the sftp server. The Source and Destination Folder are the parameters.
TODO: 
- Add possibilty to change copy direction.
.DESCRIPTION:
You need to run the Create Config script first to run this script.
The Folder should look something like this:
/Path to Script
|----CreateConfig.ps1
|----Copy.ps1
|----Move.ps1
|----configs
|    |----config1.xml
|----keys
|    |----key1

After that it will create a config file in the configs folder. 
It is possible to create multiple config files. The config can only be used with the windows user which created the config file due to the way the password is saved.
.Dependencies: 
none as of yet
.PARAMETER Config
Defines the name of the config file to use
.PARAMETER src
Defines the path to the Source Directory/File. Needs to be the full path
.PARAMETER dst
Defines the path to the Destination Directory/File. Needs to be the full path
.PARAMETER direction
Defines if you want to upload or . It needs to be exactly "up" or "down" else it will fail
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
	$direction = "up"
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
    $errMsg = "Folder $($PSScriptRoot)\Keys not found. Please run CreateConfig.ps1 first."
    Write-Error $errMsg
    return
}
#Check if the Parameter Name has already.xml endig, if not attach .xml at the end of the path
if($name -like '*.xml')
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

#Check if Key file exists ?? I hope that normaly you should be able to use the script correct

#Read Config File and Create Credential Object
[xml]$XMLDoc= Get-Content $XML_Path
$Server = $XmlDoc.Configuration.Server
$Port = $XMLDoc.Configuration.Port
$Username = $XMLDoc.Configuration.Username
$Password = $XMLDoc.Configuration.Password
$KeyFile = $XMLDoc.COnfiguration.KeyFile

$MyCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, ($Password | ConvertTo-SecureString)

$Session = New-SFTPSession -ComputerName $Server -Credential $MyCredential -Port $Port

if($direction -eq "up")
{
   Set-SFTPFile -SessionId $Session -LocalFile $src -RemotePath $dst 
}
elseif($direction -eq "down")
{

}
#Error 
else
{

}


#Remove-SFTPSession $Sessio -Verbose


#to download
#Get-SFTPFile $Session -RemoteFile $dst -LocalPath $src -Overwrite 


"C:\Users\sebas\Desktop\poshssh\asdf.txt"

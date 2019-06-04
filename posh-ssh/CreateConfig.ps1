<#
.SYNOPSIS
This Script creates a config file for the other posh-ssh automation scripts. The user input is done via Parameters.

TODO: 

.DESCRIPTION:
This script will create two subfolders (if they don't already exist) in the folder where it gets started. Therefore it needs write permissions.
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

.PARAMETER Name
Defines the name of the config file.
.PARAMETER Computername
Defines the computername oder ip address of the sftp server (default=22)
.PARAMETER Port
Defines the Port on which the SFTP Server is listening.
.PARAMETER Credentials
Defines which Credentials should be used
.PARAMETER KeyFile
Defines the name of the keyfile, Please save the key file in the keys folder or else it will fail
#>
####################################################################################################
# Parameters
####################################################################################################
param(
    [parameter(Mandatory=$true)]	
    [string]
	$Name,
    [parameter(Mandatory=$true)]	
    [string]
	$ComputerName,
    [parameter(Mandatory=$false)]	
    [int]
	$Port="22",
    [parameter(Mandatory=$true)]	
    [System.Management.Automation.PSCredential]
    $Credential,
    [parameter(Mandatory=$false)]	
    [string]
	$KeyFile  
)
####################################################################################################
# Initialize
####################################################################################################

# Make sure this script is running in FullLanguage mode
<#if ($ExecutionContext.SessionState.LanguageMode -ne [System.Management.Automation.PSLanguageMode]::FullLanguage)
{
    $errMsg = "This script must run in FullLanguage mode, but is running in " + $ExecutionContext.SessionState.LanguageMode.ToString()
    Write-Error $errMsg
    return
}
Make sure that Posh-SSH is installed
if (!(Get-Module -Name Posh-SSH))
{
    $errMsg = "Module Posh-SSH is required. Install the Module with this command: Install-Module Posh-SSH"
    Write-Error $errMsg
    return
}#>
#Check if subfolder exist
if (!(Test-Path("$($PSScriptRoot)\Configs"))) { mkdir "$($PSScriptRoot)\Configs" | Out-Null }
if (!(Test-Path("$($PSScriptRoot)\Keys"))) { mkdir "$($PSScriptRoot)\Keys" | Out-Null }
#Check if the Config File has already.xml endig, if not attach .xml at the end of the path
if($name -like '*.xml')
{
    $XML_Path = "$($PSScriptRoot)\Configs\$($Name)"
}
else
{
    $XML_Path = "$($PSScriptRoot)\Configs\$($Name).xml"
}
#Create XML File and enter the settings. There are better ways to do this but it works
New-Item $XML_Path -ItemType File
Add-Content $XML_Path "<Configuration>"
Add-Content $XML_Path "<ComputerName>$($ComputerName)</ComputerName>"
Add-Content $XML_Path "<Port>$($Port)</Port>"
Add-Content $XML_Path "<UserName>$($Credential.Username)</UserName>"
Add-Content $XML_Path "<Password>$($Credential.Password | ConvertFrom-SecureString)</Password>"
Add-Content $XML_Path "<KeyFile>$($KeyFile)</KeyFile>"
Add-Content $XML_Path "</Configuration>"

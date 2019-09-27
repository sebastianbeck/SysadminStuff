<#
.SYNOPSIS
This Script creates a config file for https download. The user input is done via Parameters.
.Examples
./Create-Config.ps1 -Name Config1.xml -URL example.com -Port 2222 -Credential Jose
TODO: 
.DESCRIPTION:
This script create a config file in the folder where it gets started. Therefore it needs write permissions.
The Folder should look something like this:
/Path to Script
|----CreateConfig.ps1
|----Copy.ps1
|----config1.xml 
It is possible to create multiple config files. The config can only be used with the windows user which created the config file due to the way the password is saved.
.Dependencies: 
none as of yet
.PARAMETER Name
Defines the name of the config file.
.PARAMETER URL
Defines the URL or ip address of the file.
.PARAMETER Port
Defines the Port on which the server is listening.
.PARAMETER Credentials
Defines which Credentials should be used.
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
	$URL,
    [parameter(Mandatory=$false)]	
    [int]
	$Port,
    [parameter(Mandatory=$true)]	
    [System.Management.Automation.PSCredential]
    $Credential
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
}#>
#Check if the Config File has already.xml endig, if not attach .xml at the end of the path
if($name -like '*.xml')
{
    $XML_Path = "$($PSScriptRoot)\$($Name)"
}
else
{
    $XML_Path = "$($PSScriptRoot)\$($Name).xml"
}
#Create XML File and enter the settings. There are better ways to do this but it works
New-Item $XML_Path -ItemType File
Add-Content $XML_Path "<Configuration>"
Add-Content $XML_Path "<URL>$($URL)</URL>"
Add-Content $XML_Path "<Port>$($Port)</Port>"
Add-Content $XML_Path "<UserName>$($Credential.Username)</UserName>"
Add-Content $XML_Path "<Password>$($Credential.Password | ConvertFrom-SecureString)</Password>"
Add-Content $XML_Path "</Configuration>"

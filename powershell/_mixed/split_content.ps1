<#
.SYNOPSIS
This script splits the lines of a single file into multiple files. 
.TODO: 

.DESCRIPTION
This script splits the lines of a single file into multiple files. 
You can define the source file, the number of files to which the lines will be spilt, if it should be random
and if you need a "header" which will be the first line of every "spiltfile".
My use case for this script is for a phishing campaign with the getgophish software. 
In a phisng campaign you don't necessary want to send a mail to all users of your organisation. 
You want to create multiple test groups and with this script that is possible, even for large enviorments. 
Export all your users, in the format of surname, givenname, E-Mailaddress and Position if required, to a csv.
Run this script and create your test groups

.Dependencies
None at the moment.

.PARAMETER Source
This defines the source file. Please enter the fullpath or .\ to the file
.PARAMETER NumberOf
This defines the Number of "Splitfiles" which should be created.
.PARAMETER randomize
If this Parameter is set the lines are randomly split to the files.
.PARAMETER header
If you need a header in the files you can enter the path to the file which contains the header.
#>
####################################
#Params
####################################
param(
	#Defines the Source File
    [parameter(Mandatory=$true)]	
    [string]
	$Source,

    #Declares the amount of files
    [parameter(Mandatory=$true)]	
    [int]
	$NumberOf,

	#If set, randomizes what is written to which file
    [parameter(Mandatory=$false)]	
    [boolean]
	$Randomize=$false,

   	#If needed, you can write a header to each file 
    [parameter(Mandatory=$false)]	
    [string]
	$Header
)
#Creates Files with header Data if declared
#Define Variables needed
$path = [io.path]::GetDirectoryName($Source)
$name = [io.path]::GetFileName($Source)
    #Creates the amount of files decleared and inputs the header if required
    for ($i=0; $i -lt $NumberOf; $i++)
    {
        $File = "$($Path)\split$($i)_$($name)"
        New-Item $File -ItemType File
        if($Header -ne "")
        {
            $start = Get-Content -Path $Header -Encoding Default
            Add-Content $File $start
        }
    }
    $y=0 #initialize for the foreach loop
    if($Randomize)
    {
        #Split Data in the different files randomly
        foreach ($line in (Get-Content $Source))
        {
            $y= Get-Random -Maximum $NumberOf
            Add-Content "$($Path)\split$($y)_$($name)" $line
        }
    }
    else
    {
        #Split Data in the different files normal
        foreach ($line in (Get-Content $Source))
        {
            if($y -eq $NumberOf){$y=0}
            Add-Content "$($Path)\split$($y)_$($name)" $line
            $y++
        }
    }




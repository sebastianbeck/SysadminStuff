<#
.SYNOPSIS
If you embed PDF files into a office file it also saves which programm it should use to open it. 
Not every company uses the same pdf reader/writer and therefore sometimes you can be unable to open the pdf file.
This file extracts all embedded pdf files and saves them into a .zip.
You need to define the parameter file
.TODO: 
FIGURE out why the f i can't open the .xlsx files in the embedded folder.

.DESCRIPTION
Every office file is a zip file. You can rename it to .zip and then extract the data of it.
If files are embedded they are also stored in there. For example in an .xlsx file they are stored under ...\xl\embeddings.
The office files are stored with normal file extensions but other files f.E. .pdf are stored in the .bin format.
Unfortunately office writes some data in the beginning of the files so that it know which program to use. 
For this reason we can't just rename the file to *.pdf and open it. We need to remove the data which was added by office and save it.
This program does exactly that. 
It copies a office file, renames it to a zip and then extracts it. It reads the data of the .bin files in to a variable.
The variable is scanned for the file signature of pdfs. If it matches it will create a new file with only the needed data. 
Afterwards it will save all the pdfs in a .zip and removes the temporary data.
Some sources I used.
https://stackoverflow.com/questions/20935356/methods-to-hex-edit-binary-files-via-powershell
https://stackoverflow.com/questions/52778729/download-embedded-pdf-file-in-excel
https://www.howtogeek.com/50628/easily-extract-images-text-and-embedded-files-from-an-office-2007-document/
.Dependencies
No.
.PARAMETER Source
This parameter defines the source file. Use the full path to it.
.PARAMETER Destination
#>
####################################
#Params
####################################
param(
	#Defines the Source File
    [parameter(Mandatory=$false)]	
    [string]
	$file = "C:\test\word.docx"
)
#copy file and rename it to ZIP , get some Variables needed later
$file = Get-Item $file
$dir = $file.DirectoryName
Copy-Item $file "$($dir)\wip.zip"
#extract the archive
Expand-Archive -Path "$($dir)\wip.zip"  "$($dir)\wip\"

#define the file type and where to search for .bin files
if($file.Extension -eq ".xlsx")
{
    $source = "$($dir)\wip\xl\embeddings\"
}
if($file.Extension -eq ".docx")
{
    $source = "$($dir)\wip\word\embeddings\"
}
if($file.Extension -eq ".pptx")
{
    $source = "$($dir)\wip\ppt\embeddings\"
}

#For Each File where File name is .bin
$files = Get-ChildItem $Source  | ? {$_.Name -like "*.bin"}
#create pdfs
foreach($f in $files)
{
    #Create new Name for the files //If Possible figure out which name is linked to which ole object
    $Newname = $f -split (".bin")
    #Read .bin file in byte encoding
    $byteArray = Get-Content "$($source)$($f)" -Raw -Encoding Byte
    #convert bytearray to string
    $byteString = $byteArray.ForEach('ToString', 'X') -join ' '
    #search for the PDF signature hex values
    $byteString = $byteString -Match "25 50 44 46.*"
    #selecht the hex values starting from there
    $byteString = $matches[0]
    #convert string to byteArray
    [byte[]] $newByteArray = -split $byteString -replace '^', '0x'
    #write Content to new filename
    Set-Content -Path "$($source)$($NewName).pdf" -Encoding Byte -Value $newByteArray
}

#create zip with attachments and remove temporary folder
Compress-Archive -Path "$($Source)\*.pdf" -CompressionLevel Optimal -DestinationPath "$($dir)\embeddings.zip"
Remove-Item -Path "$($dir)\wip" -Force -Recurse
Remove-Item -Path "$($dir)\wip.zip"

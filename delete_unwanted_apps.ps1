#I copied this script from somewhere. Sadly I don't remeber where and so I can't give the awesome person credit
#This will uninstall all unwanted default apps. It won't uninstall the apps from $excludeApps.
    $excludedApps = '.*photos.*|.*calculator.*|.*alarms.*|.*sticky*.|.*soundrecorder*.|.*zunevideo*.|.*Microsoft.Xbox.TCUI*.'
    $unwantedApps = Get-AppxPackage -PackageTypeFilter Bundle | Where-Object {$_.Name -notmatch $excludedApps}
    If ($unwantedApps) {

        $unwantedApps | Remove-AppxPackage
    }

  

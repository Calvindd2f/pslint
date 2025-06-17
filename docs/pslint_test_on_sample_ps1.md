=== PowerShell Performance Analysis Report ===
Script: .\sample.ps1
Time: 2025-06-17 22:22:23

Summary:
Total Issues Found: 338

== ArrayAddition (40 issues) ==
Line 108:
Code: $script:TotalSpaceFreed += $spaceFreed
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 109:
    Code: $script:CleanupReport += [PSCustomObject]@{
                Location   = $Description
                Path       = $Path
                SpaceFreed = "$spaceFreed MB"
Status = "Success"
}
Suggestion: Consider using ArrayList or Generic List for better performance
Line 119:
Code: $script:ErrorLog += "Error cleaning $Description ($Path): $($_.Exception.Message)"
Suggestion: Consider using ArrayList or Generic List for better performance
Line 155:
Code: $script:ErrorLog += "Error processing browser cache $($browser.Key) for $Username : $($_.Exception.Message)"
Suggestion: Consider using ArrayList or Generic List for better performance
Line 211:
Code: $oldFiles += $file
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 228:
    Code: $sizeBefore += $file.Length
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 242:
    Code: $script:ErrorLog += "Error deleting old file $($file.FullName): $($_.Exception.Message)"
Suggestion: Consider using ArrayList or Generic List for better performance
Line 248:
Code: $script:TotalSpaceFreed += $sizeBeforeMB
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 249:
    Code: $script:CleanupReport += [PSCustomObject]@{
                        Location   = "$($folder.Key) Old Files - $Username"
                        Path       = $folderPath
                        SpaceFreed = "$sizeBeforeMB MB"
Status = "Success - $deletedCount files deleted"
                    }
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 259:
    Code: $script:ErrorLog += "Error processing old files in $($folder.Key) for $Username : $($_.Exception.Message)"
Suggestion: Consider using ArrayList or Generic List for better performance
Line 349:
Code: $script:ErrorLog += "Error processing location $($location.Key): $($_.Exception.Message)"
Suggestion: Consider using ArrayList or Generic List for better performance
Line 365:
Code: $ErrorLog += "Error processing user $Username : $($_.Exception.Message)"
Suggestion: Consider using ArrayList or Generic List for better performance
Line 402:
Code: $sizeBefore += Get-FolderSize -Path $bin.FullName
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 443:
    Code: $CleanupReport += [PSCustomObject]@{
                Location   = "Recycle Bin"
                Path       = "C:\`$Recycle.Bin"
SpaceFreed = "$sizeBefore MB"
                Status     = "Success"
            }
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 449:
    Code: $TotalSpaceFreed += $sizeBefore
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 454:
    Code: $ErrorLog += "Error emptying Recycle Bin: $($_.Exception.Message)"
Suggestion: Consider using ArrayList or Generic List for better performance
Line 468:
Code: $TotalSpaceFreed += $cleanupFreed
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 469:
    Code: $CleanupReport += [PSCustomObject]@{
                Location   = "Windows Disk Cleanup"
                Path       = "System Utility"
                SpaceFreed = "$cleanupFreed MB"
Status = "Success"
}
Suggestion: Consider using ArrayList or Generic List for better performance
Line 479:
Code: $ErrorLog += "Error running Disk Cleanup: $($_.Exception.Message)"
Suggestion: Consider using ArrayList or Generic List for better performance
Line 554:
Code: $totalGuidSpaceFreed += $folderSize
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 559:
    Code: $script:ErrorLog += "Error removing GUID folder $($guidFolder.FullName): $($_.Exception.Message)"
Suggestion: Consider using ArrayList or Generic List for better performance
Line 565:
Code: $script:ErrorLog += "Error scanning for GUID folders in $location : $($_.Exception.Message)"
Suggestion: Consider using ArrayList or Generic List for better performance
Line 571:
Code: $script:TotalSpaceFreed += $totalGuidSpaceFreed
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 572:
    Code: $script:CleanupReport += [PSCustomObject]@{
            Location   = "GUID Folders - $Username"
            Path       = $UserProfile
            SpaceFreed = "$totalGuidSpaceFreed MB"
Status = "Success - $totalGuidFoldersRemoved folders removed"
        }
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 624:
    Code: $oldFiles += $file
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 640:
    Code: $sizeBefore += $file.Length
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 654:
    Code: $script:ErrorLog += "Error deleting old file $($file.FullName): $($_.Exception.Message)"
Suggestion: Consider using ArrayList or Generic List for better performance
Line 660:
Code: $script:TotalSpaceFreed += $sizeBeforeMB
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 661:
    Code: $script:CleanupReport += [PSCustomObject]@{
                        Location   = "$($folder.Key) Old Files - $Username"
                        Path       = $folderPath
                        SpaceFreed = "$sizeBeforeMB MB"
Status = "Success - $deletedCount files deleted"
                    }
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 671:
    Code: $script:ErrorLog += "Error processing old files in $($folder.Key) for $Username`: $($_.Exception.Message)"
Suggestion: Consider using ArrayList or Generic List for better performance
Line 676:
Code: $script:ErrorLog += "Error processing old files in $($folder.Key) for $Username`: $($_.Exception.Message)"
Suggestion: Consider using ArrayList or Generic List for better performance
Line 760:
Code: $ErrorLog += "Error processing location $($location.Key): $($_.Exception.Message)"
Suggestion: Consider using ArrayList or Generic List for better performance
Line 773:
Code: $ErrorLog += "Error processing user $Username`: $($_.Exception.Message)"
Suggestion: Consider using ArrayList or Generic List for better performance
Line 807:
Code: $sizeBefore += Get-FolderSize -Path $bin.FullName
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 848:
    Code: $CleanupReport += [PSCustomObject]@{
            Location   = "Recycle Bin"
            Path       = "C:\`$Recycle.Bin"
SpaceFreed = "$sizeBefore MB"
            Status     = "Success"
        }
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 854:
    Code: $TotalSpaceFreed += $sizeBefore
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 859:
    Code: $ErrorLog += "Error emptying Recycle Bin: $($_.Exception.Message)"
Suggestion: Consider using ArrayList or Generic List for better performance
Line 873:
Code: $TotalSpaceFreed += $cleanupFreed
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 874:
    Code: $CleanupReport += [PSCustomObject]@{
            Location   = "Windows Disk Cleanup"
            Path       = "System Utility"
            SpaceFreed = "$cleanupFreed MB"
Status = "Success"
}
Suggestion: Consider using ArrayList or Generic List for better performance
Line 884:
Code: $ErrorLog += "Error running Disk Cleanup: $($\_.Exception.Message)"
Suggestion: Consider using ArrayList or Generic List for better performance

== CmdletPipelineWrapping (4 issues) ==
Line 461:
Code: Get-WmiObject -Class Win32*LogicalDisk | Where-Object { $*.DeviceID -eq "C:" } | Select-Object -ExpandProperty FreeSpace
Suggestion: Consider reducing pipeline complexity
Line 464:
Code: Get-WmiObject -Class Win32*LogicalDisk | Where-Object { $*.DeviceID -eq "C:" } | Select-Object -ExpandProperty FreeSpace
Suggestion: Consider reducing pipeline complexity
Line 866:
Code: Get-WmiObject -Class Win32*LogicalDisk | Where-Object { $*.DeviceID -eq "C:" } | Select-Object -ExpandProperty FreeSpace
Suggestion: Consider reducing pipeline complexity
Line 869:
Code: Get-WmiObject -Class Win32*LogicalDisk | Where-Object { $*.DeviceID -eq "C:" } | Select-Object -ExpandProperty FreeSpace
Suggestion: Consider reducing pipeline complexity

== DynamicObjectCreation (8 issues) ==
Line 109:
Code: [PSCustomObject]@{
Location = $Description
                Path       = $Path
                SpaceFreed = "$spaceFreed MB"
Status = "Success"
}
Suggestion: Consider using classes or structured objects
Line 249:
Code: [PSCustomObject]@{
Location = "$($folder.Key) Old Files - $Username"
                        Path       = $folderPath
                        SpaceFreed = "$sizeBeforeMB MB"
Status = "Success - $deletedCount files deleted"
                    }
    Suggestion: Consider using classes or structured objects
  Line 443:
    Code: [PSCustomObject]@{
                Location   = "Recycle Bin"
                Path       = "C:\`$Recycle.Bin"
SpaceFreed = "$sizeBefore MB"
                Status     = "Success"
            }
    Suggestion: Consider using classes or structured objects
  Line 469:
    Code: [PSCustomObject]@{
                Location   = "Windows Disk Cleanup"
                Path       = "System Utility"
                SpaceFreed = "$cleanupFreed MB"
Status = "Success"
}
Suggestion: Consider using classes or structured objects
Line 572:
Code: [PSCustomObject]@{
Location = "GUID Folders - $Username"
            Path       = $UserProfile
            SpaceFreed = "$totalGuidSpaceFreed MB"
Status = "Success - $totalGuidFoldersRemoved folders removed"
        }
    Suggestion: Consider using classes or structured objects
  Line 661:
    Code: [PSCustomObject]@{
                        Location   = "$($folder.Key) Old Files - $Username"
                        Path       = $folderPath
                        SpaceFreed = "$sizeBeforeMB MB"
Status = "Success - $deletedCount files deleted"
                    }
    Suggestion: Consider using classes or structured objects
  Line 848:
    Code: [PSCustomObject]@{
            Location   = "Recycle Bin"
            Path       = "C:\`$Recycle.Bin"
SpaceFreed = "$sizeBefore MB"
            Status     = "Success"
        }
    Suggestion: Consider using classes or structured objects
  Line 874:
    Code: [PSCustomObject]@{
            Location   = "Windows Disk Cleanup"
            Path       = "System Utility"
            SpaceFreed = "$cleanupFreed MB"
Status = "Success"
}
Suggestion: Consider using classes or structured objects

== LargeCollectionLookup (17 issues) ==
Line 109:
Code: @{
Location = $Description
                Path       = $Path
                SpaceFreed = "$spaceFreed MB"
Status = "Success"
}
Suggestion: Consider using Dictionary<TKey,TValue> for large collections
Line 132:
Code: @{
"Chrome Cache" = "$UserProfile\AppData\Local\Google\Chrome\User Data\Default\Cache"
        "Chrome Cache2" = "$UserProfile\AppData\Local\Google\Chrome\User Data\Default\Cache2"
"Edge Cache" = "$UserProfile\AppData\Local\Microsoft\Edge\User Data\Default\Cache"
        "Firefox Cache" = "$UserProfile\AppData\Local\Mozilla\Firefox\Profiles\*\cache2"
"IE Cache" = "$UserProfile\AppData\Local\Microsoft\Windows\INetCache"
        "IE Cookies"    = "$UserProfile\AppData\Local\Microsoft\Windows\INetCookies"
}
Suggestion: Consider using Dictionary<TKey,TValue> for large collections
Line 183:
Code: @{
"Downloads" = "$UserProfile\Downloads"
            "Documents" = "$UserProfile\Documents"
}
Suggestion: Consider using Dictionary<TKey,TValue> for large collections
Line 249:
Code: @{
Location = "$($folder.Key) Old Files - $Username"
                        Path       = $folderPath
                        SpaceFreed = "$sizeBeforeMB MB"
Status = "Success - $deletedCount files deleted"
                    }
    Suggestion: Consider using Dictionary<TKey,TValue> for large collections
  Line 313:
    Code: @{
                "User Temp - $Username"               = "$UserPath\AppData\Local\Temp"
"User Temp2 - $Username"              = "$UserPath\AppData\Local\Tmp"
"User Temp Roaming - $Username"       = "$UserPath\AppData\Roaming\Temp"
"User Temp LocalLow - $Username"      = "$UserPath\AppData\LocalLow\Temp"
"Recent Items - $Username"            = "$UserPath\AppData\Roaming\Microsoft\Windows\Recent"
"Thumbnail Cache - $Username"         = "$UserPath\AppData\Local\Microsoft\Windows\Explorer"
"Windows Error Reports - $Username"   = "$UserPath\AppData\Local\Microsoft\Windows\WER"
"CrashDumps - $Username"              = "$UserPath\AppData\Local\CrashDumps"
"Adobe Cache - $Username"             = "$UserPath\AppData\Local\Adobe\*\Cache"
"Teams Cache - $Username"             = "$UserPath\AppData\Roaming\Microsoft\Teams\tmp"
"Teams Cache2 - $Username"            = "$UserPath\AppData\Roaming\Microsoft\Teams\Cache"
"Skype Cache - $Username"             = "$UserPath\AppData\Roaming\Skype\*\chatsync"
"Discord Cache - $Username"           = "$UserPath\AppData\Roaming\discord\Cache"
"Spotify Cache - $Username"           = "$UserPath\AppData\Local\Spotify\Storage"
"Steam Logs - $Username"              = "$UserPath\AppData\Local\Steam\logs"
"Windows Installer Cache - $Username" = "$UserPath\AppData\Local\Microsoft\Windows\INetCache\IE"
"Office Cache - $Username"            = "$UserPath\AppData\Local\Microsoft\Office\*\OfficeFileCache"
"OneDrive Temp - $Username"           = "$UserPath\AppData\Local\Microsoft\OneDrive\logs"
}
Suggestion: Consider using Dictionary<TKey,TValue> for large collections
Line 373:
Code: @{
"Windows Temp" = "$env:WINDIR\Temp"
        "System Temp"           = "$env:TEMP"
"System32 Temp" = "$env:WINDIR\System32\config\systemprofile\AppData\Local\Temp"
        "Prefetch"              = "$env:WINDIR\Prefetch"
"Software Distribution" = "$env:WINDIR\SoftwareDistribution\Download"
        "CBS Logs"              = "$env:WINDIR\Logs\CBS"
"DISM Logs" = "$env:WINDIR\Logs\DISM"
        "Windows Update Logs"   = "$env:WINDIR\WindowsUpdate.log*"
"Memory Dumps" = "$env:WINDIR\Minidump"
        "Error Reports"         = "$env:ALLUSERSPROFILE\Microsoft\Windows\WER"
"Delivery Optimization" = "$env:WINDIR\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Logs"
        "IIS Logs"              = "$env:WINDIR\System32\LogFiles\W3SVC*"
"Event Trace Logs" = "$env:WINDIR\System32\LogFiles\WMI"
    }
    Suggestion: Consider using Dictionary<TKey,TValue> for large collections
  Line 443:
    Code: @{
                Location   = "Recycle Bin"
                Path       = "C:\`$Recycle.Bin"
SpaceFreed = "$sizeBefore MB"
                Status     = "Success"
            }
    Suggestion: Consider using Dictionary<TKey,TValue> for large collections
  Line 469:
    Code: @{
                Location   = "Windows Disk Cleanup"
                Path       = "System Utility"
                SpaceFreed = "$cleanupFreed MB"
Status = "Success"
}
Suggestion: Consider using Dictionary<TKey,TValue> for large collections
Line 496:
Code: @{
TotalSpaceFreedMB = [math]::Round($TotalSpaceFreed, 2)
        TotalSpaceFreedGB = [math]::Round($TotalSpaceFreed / 1024, 2)
LocationsCleaned = $CleanupReport.Count
        ErrorCount        = $ErrorLog.Count
        Status            = if ($ErrorLog.Count -eq 0) { "Success" }else { "Warning" }
}
Suggestion: Consider using Dictionary<TKey,TValue> for large collections
Line 572:
Code: @{
Location = "GUID Folders - $Username"
            Path       = $UserProfile
            SpaceFreed = "$totalGuidSpaceFreed MB"
Status = "Success - $totalGuidFoldersRemoved folders removed"
        }
    Suggestion: Consider using Dictionary<TKey,TValue> for large collections
  Line 596:
    Code: @{
        "Downloads" = "$UserProfile\Downloads"
"Documents" = "$UserProfile\Documents"
    }
    Suggestion: Consider using Dictionary<TKey,TValue> for large collections
  Line 661:
    Code: @{
                        Location   = "$($folder.Key) Old Files - $Username"
                        Path       = $folderPath
                        SpaceFreed = "$sizeBeforeMB MB"
Status = "Success - $deletedCount files deleted"
                    }
    Suggestion: Consider using Dictionary<TKey,TValue> for large collections
  Line 730:
    Code: @{
            "User Temp - $Username"             = "$UserPath\AppData\Local\Temp"
"User Temp2 - $Username"            = "$UserPath\AppData\Local\Tmp"
"Recent Items - $Username"          = "$UserPath\AppData\Roaming\Microsoft\Windows\Recent"
"Thumbnail Cache - $Username"       = "$UserPath\AppData\Local\Microsoft\Windows\Explorer"
"Windows Error Reports - $Username" = "$UserPath\AppData\Local\Microsoft\Windows\WER"
"CrashDumps - $Username"            = "$UserPath\AppData\Local\CrashDumps"
"Adobe Cache - $Username"           = "$UserPath\AppData\Local\Adobe\*\Cache"
"Teams Cache - $Username"           = "$UserPath\AppData\Roaming\Microsoft\Teams\tmp"
"Skype Cache - $Username"           = "$UserPath\AppData\Roaming\Skype\*\chatsync"
"Discord Cache - $Username"         = "$UserPath\AppData\Roaming\discord\Cache"
"Spotify Cache - $Username"         = "$UserPath\AppData\Local\Spotify\Storage"
"Steam Logs - $Username"            = "$UserPath\AppData\Local\Steam\logs"
}
Suggestion: Consider using Dictionary<TKey,TValue> for large collections
Line 781:
Code: @{
"Windows Temp" = "$env:WINDIR\Temp"
    "System Temp"           = "$env:TEMP"
"Prefetch" = "$env:WINDIR\Prefetch"
    "Software Distribution" = "$env:WINDIR\SoftwareDistribution\Download"
"CBS Logs" = "$env:WINDIR\Logs\CBS"
    "DISM Logs"             = "$env:WINDIR\Logs\DISM"
"Windows Update Logs" = "$env:WINDIR\WindowsUpdate.log*"
    "Memory Dumps"          = "$env:WINDIR\Minidump"
"Error Reports" = "$env:ALLUSERSPROFILE\Microsoft\Windows\WER"
    "Delivery Optimization" = "$env:WINDIR\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Logs"
}
Suggestion: Consider using Dictionary<TKey,TValue> for large collections
Line 848:
Code: @{
Location = "Recycle Bin"
Path = "C:\`$Recycle.Bin"
            SpaceFreed = "$sizeBefore MB"
Status = "Success"
}
Suggestion: Consider using Dictionary<TKey,TValue> for large collections
Line 874:
Code: @{
Location = "Windows Disk Cleanup"
Path = "System Utility"
SpaceFreed = "$cleanupFreed MB"
            Status     = "Success"
        }
    Suggestion: Consider using Dictionary<TKey,TValue> for large collections
  Line 901:
    Code: @{
    TotalSpaceFreedMB = [math]::Round($TotalSpaceFreed, 2)
TotalSpaceFreedGB = [math]::Round($TotalSpaceFreed / 1024, 2)
    LocationsCleaned  = $CleanupReport.Count
    ErrorCount        = $ErrorLog.Count
    Status            = if ($ErrorLog.Count -eq 0) { "Success" }else { "Warning" }
}
Suggestion: Consider using Dictionary<TKey,TValue> for large collections

== OutputSuppression (4 issues) ==
Line 435:
Code: [System.Runtime.Interopservices.Marshal]::ReleaseComObject($recycleBin) | Out-Null
    Suggestion: Consider using [void] for better performance
  Line 438:
    Code: [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null
Suggestion: Consider using [void] for better performance
Line 840:
Code: [System.Runtime.Interopservices.Marshal]::ReleaseComObject($recycleBin) | Out-Null
    Suggestion: Consider using [void] for better performance
  Line 843:
    Code: [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null
Suggestion: Consider using [void] for better performance

== StringAddition (214 issues) ==
Line 52:
Code: "Error getting folder size for $Path : $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 108:
Code: $script:TotalSpaceFreed += $spaceFreed
    Suggestion: Consider using -Join or String Buider for better performance
  Line 109:
    Code: $script:CleanupReport += [PSCustomObject]@{
                Location   = $Description
                Path       = $Path
                SpaceFreed = "$spaceFreed MB"
Status = "Success"
}
Suggestion: Consider using -Join or String Buider for better performance
Line 112:
Code: "$spaceFreed MB"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 115:
    Code: "✓ $Description`: $spaceFreed MB freed"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 119:
    Code: $script:ErrorLog += "Error cleaning $Description ($Path): $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 119:
Code: "Error cleaning $Description ($Path): $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 120:
Code: "Error cleaning $Description : $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 133:
Code: "$UserProfile\AppData\Local\Google\Chrome\User Data\Default\Cache"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 134:
    Code: "$UserProfile\AppData\Local\Google\Chrome\User Data\Default\Cache2"
Suggestion: Consider using -Join or String Buider for better performance
Line 135:
Code: "$UserProfile\AppData\Local\Microsoft\Edge\User Data\Default\Cache"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 136:
    Code: "$UserProfile\AppData\Local\Mozilla\Firefox\Profiles\*\cache2"
Suggestion: Consider using -Join or String Buider for better performance
Line 137:
Code: "$UserProfile\AppData\Local\Microsoft\Windows\INetCache"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 138:
    Code: "$UserProfile\AppData\Local\Microsoft\Windows\INetCookies"
Suggestion: Consider using -Join or String Buider for better performance
Line 149:
Code: "$($browser.Key) - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 155:
    Code: $script:ErrorLog += "Error processing browser cache $($browser.Key) for $Username : $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 155:
Code: "Error processing browser cache $($browser.Key) for $Username : $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 184:
Code: "$UserProfile\Downloads"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 185:
    Code: "$UserProfile\Documents"
Suggestion: Consider using -Join or String Buider for better performance
Line 195:
Code: " Scanning $($folder.Key) for files older than $FileAgeThresholdDays days..."
    Suggestion: Consider using -Join or String Buider for better performance
  Line 199:
    Code: "    No files found in $($folder.Key)"
Suggestion: Consider using -Join or String Buider for better performance
Line 211:
Code: $oldFiles += $file
    Suggestion: Consider using -Join or String Buider for better performance
  Line 221:
    Code: "    No old files found in $($folder.Key)"
Suggestion: Consider using -Join or String Buider for better performance
Line 228:
Code: $sizeBefore += $file.Length
    Suggestion: Consider using -Join or String Buider for better performance
  Line 242:
    Code: $script:ErrorLog += "Error deleting old file $($file.FullName): $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 242:
Code: "Error deleting old file $($file.FullName): $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 248:
Code: $script:TotalSpaceFreed += $sizeBeforeMB
    Suggestion: Consider using -Join or String Buider for better performance
  Line 249:
    Code: $script:CleanupReport += [PSCustomObject]@{
                        Location   = "$($folder.Key) Old Files - $Username"
                        Path       = $folderPath
                        SpaceFreed = "$sizeBeforeMB MB"
Status = "Success - $deletedCount files deleted"
                    }
    Suggestion: Consider using -Join or String Buider for better performance
  Line 250:
    Code: "$($folder.Key) Old Files - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 252:
    Code: "$sizeBeforeMB MB"
Suggestion: Consider using -Join or String Buider for better performance
Line 253:
Code: "Success - $deletedCount files deleted"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 255:
    Code: "    ✓ $($folder.Key): $deletedCount old files deleted, $sizeBeforeMB MB freed"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 259:
    Code: $script:ErrorLog += "Error processing old files in $($folder.Key) for $Username : $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 259:
Code: "Error processing old files in $($folder.Key) for $Username : $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 260:
Code: " Error processing old files in $($folder.Key): $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 284:
Code: "Found $($UserProfiles.Count) user profiles to process"
Suggestion: Consider using -Join or String Buider for better performance
Line 287:
Code: "Failed to enumerate user profiles: $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 300:
Code: "Skipping invalid user profile path: $UserPath"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 306:
    Code: "Skipping profile with empty username: $UserPath"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 310:
    Code: "`nProcessing user: $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 314:
    Code: "User Temp - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 314:
    Code: "$UserPath\AppData\Local\Temp"
Suggestion: Consider using -Join or String Buider for better performance
Line 315:
Code: "User Temp2 - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 315:
    Code: "$UserPath\AppData\Local\Tmp"
Suggestion: Consider using -Join or String Buider for better performance
Line 316:
Code: "User Temp Roaming - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 316:
    Code: "$UserPath\AppData\Roaming\Temp"
Suggestion: Consider using -Join or String Buider for better performance
Line 317:
Code: "User Temp LocalLow - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 317:
    Code: "$UserPath\AppData\LocalLow\Temp"
Suggestion: Consider using -Join or String Buider for better performance
Line 318:
Code: "Recent Items - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 318:
    Code: "$UserPath\AppData\Roaming\Microsoft\Windows\Recent"
Suggestion: Consider using -Join or String Buider for better performance
Line 319:
Code: "Thumbnail Cache - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 319:
    Code: "$UserPath\AppData\Local\Microsoft\Windows\Explorer"
Suggestion: Consider using -Join or String Buider for better performance
Line 320:
Code: "Windows Error Reports - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 320:
    Code: "$UserPath\AppData\Local\Microsoft\Windows\WER"
Suggestion: Consider using -Join or String Buider for better performance
Line 321:
Code: "CrashDumps - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 321:
    Code: "$UserPath\AppData\Local\CrashDumps"
Suggestion: Consider using -Join or String Buider for better performance
Line 322:
Code: "Adobe Cache - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 322:
    Code: "$UserPath\AppData\Local\Adobe\*\Cache"
Suggestion: Consider using -Join or String Buider for better performance
Line 323:
Code: "Teams Cache - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 323:
    Code: "$UserPath\AppData\Roaming\Microsoft\Teams\tmp"
Suggestion: Consider using -Join or String Buider for better performance
Line 324:
Code: "Teams Cache2 - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 324:
    Code: "$UserPath\AppData\Roaming\Microsoft\Teams\Cache"
Suggestion: Consider using -Join or String Buider for better performance
Line 325:
Code: "Skype Cache - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 325:
    Code: "$UserPath\AppData\Roaming\Skype\*\chatsync"
Suggestion: Consider using -Join or String Buider for better performance
Line 326:
Code: "Discord Cache - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 326:
    Code: "$UserPath\AppData\Roaming\discord\Cache"
Suggestion: Consider using -Join or String Buider for better performance
Line 327:
Code: "Spotify Cache - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 327:
    Code: "$UserPath\AppData\Local\Spotify\Storage"
Suggestion: Consider using -Join or String Buider for better performance
Line 328:
Code: "Steam Logs - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 328:
    Code: "$UserPath\AppData\Local\Steam\logs"
Suggestion: Consider using -Join or String Buider for better performance
Line 329:
Code: "Windows Installer Cache - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 329:
    Code: "$UserPath\AppData\Local\Microsoft\Windows\INetCache\IE"
Suggestion: Consider using -Join or String Buider for better performance
Line 330:
Code: "Office Cache - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 330:
    Code: "$UserPath\AppData\Local\Microsoft\Office\*\OfficeFileCache"
Suggestion: Consider using -Join or String Buider for better performance
Line 331:
Code: "OneDrive Temp - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 331:
    Code: "$UserPath\AppData\Local\Microsoft\OneDrive\logs"
Suggestion: Consider using -Join or String Buider for better performance
Line 349:
Code: $script:ErrorLog += "Error processing location $($location.Key): $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 349:
Code: "Error processing location $($location.Key): $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 365:
Code: $ErrorLog += "Error processing user $Username : $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 365:
Code: "Error processing user $Username : $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 366:
Code: "Error processing user $Username : $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 374:
Code: "$env:WINDIR\Temp"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 375:
    Code: "$env:TEMP"
Suggestion: Consider using -Join or String Buider for better performance
Line 376:
Code: "$env:WINDIR\System32\config\systemprofile\AppData\Local\Temp"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 377:
    Code: "$env:WINDIR\Prefetch"
Suggestion: Consider using -Join or String Buider for better performance
Line 378:
Code: "$env:WINDIR\SoftwareDistribution\Download"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 379:
    Code: "$env:WINDIR\Logs\CBS"
Suggestion: Consider using -Join or String Buider for better performance
Line 380:
Code: "$env:WINDIR\Logs\DISM"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 381:
    Code: "$env:WINDIR\WindowsUpdate.log*"
Suggestion: Consider using -Join or String Buider for better performance
Line 382:
Code: "$env:WINDIR\Minidump"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 383:
    Code: "$env:ALLUSERSPROFILE\Microsoft\Windows\WER"
Suggestion: Consider using -Join or String Buider for better performance
Line 384:
Code: "$env:WINDIR\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Logs"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 385:
    Code: "$env:WINDIR\System32\LogFiles\W3SVC*"
Suggestion: Consider using -Join or String Buider for better performance
Line 386:
Code: "$env:WINDIR\System32\LogFiles\WMI"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 402:
    Code: $sizeBefore += Get-FolderSize -Path $bin.FullName
    Suggestion: Consider using -Join or String Buider for better performance
  Line 443:
    Code: $CleanupReport += [PSCustomObject]@{
                Location   = "Recycle Bin"
                Path       = "C:\`$Recycle.Bin"
SpaceFreed = "$sizeBefore MB"
                Status     = "Success"
            }
    Suggestion: Consider using -Join or String Buider for better performance
  Line 446:
    Code: "$sizeBefore MB"
Suggestion: Consider using -Join or String Buider for better performance
Line 449:
Code: $TotalSpaceFreed += $sizeBefore
    Suggestion: Consider using -Join or String Buider for better performance
  Line 450:
    Code: "✓ Recycle Bin: $sizeBefore MB freed"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 454:
    Code: $ErrorLog += "Error emptying Recycle Bin: $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 454:
Code: "Error emptying Recycle Bin: $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 455:
Code: "Error emptying Recycle Bin: $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 468:
Code: $TotalSpaceFreed += $cleanupFreed
    Suggestion: Consider using -Join or String Buider for better performance
  Line 469:
    Code: $CleanupReport += [PSCustomObject]@{
                Location   = "Windows Disk Cleanup"
                Path       = "System Utility"
                SpaceFreed = "$cleanupFreed MB"
Status = "Success"
}
Suggestion: Consider using -Join or String Buider for better performance
Line 472:
Code: "$cleanupFreed MB"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 475:
    Code: "✓ Windows Disk Cleanup: $cleanupFreed MB freed"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 479:
    Code: $ErrorLog += "Error running Disk Cleanup: $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 479:
Code: "Error running Disk Cleanup: $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 480:
Code: "Error running Disk Cleanup: $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 485:
Code: "Total Space Freed: $([math]::Round($TotalSpaceFreed, 2)) MB ($([math]::Round($TotalSpaceFreed / 1024, 2)) GB)"
Suggestion: Consider using -Join or String Buider for better performance
Line 486:
Code: "Locations Cleaned: $($CleanupReport.Count)"
Suggestion: Consider using -Join or String Buider for better performance
Line 487:
Code: "Errors Encountered: $($ErrorLog.Count)"
Suggestion: Consider using -Join or String Buider for better performance
Line 504:
Code: "`nDATTO_OUTPUT: $($OutputData | ConvertTo-Json -Compress)"
Suggestion: Consider using -Join or String Buider for better performance
Line 518:
Code: "$UserProfile"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 519:
    Code: "$UserProfile\AppData\Local"
Suggestion: Consider using -Join or String Buider for better performance
Line 520:
Code: "$UserProfile\AppData\Roaming"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 521:
    Code: "$UserProfile\AppData\LocalLow"
Suggestion: Consider using -Join or String Buider for better performance
Line 548:
Code: " Skipping GUID folder with critical files: $($guidFolder.Name)"
Suggestion: Consider using -Join or String Buider for better performance
Line 554:
Code: $totalGuidSpaceFreed += $folderSize
    Suggestion: Consider using -Join or String Buider for better performance
  Line 556:
    Code: "Removed GUID folder: $($guidFolder.FullName) ($folderSize MB)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 559:
    Code: $script:ErrorLog += "Error removing GUID folder $($guidFolder.FullName): $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 559:
Code: "Error removing GUID folder $($guidFolder.FullName): $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 565:
Code: $script:ErrorLog += "Error scanning for GUID folders in $location : $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 565:
Code: "Error scanning for GUID folders in $location : $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 571:
Code: $script:TotalSpaceFreed += $totalGuidSpaceFreed
    Suggestion: Consider using -Join or String Buider for better performance
  Line 572:
    Code: $script:CleanupReport += [PSCustomObject]@{
            Location   = "GUID Folders - $Username"
            Path       = $UserProfile
            SpaceFreed = "$totalGuidSpaceFreed MB"
Status = "Success - $totalGuidFoldersRemoved folders removed"
        }
    Suggestion: Consider using -Join or String Buider for better performance
  Line 573:
    Code: "GUID Folders - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 575:
    Code: "$totalGuidSpaceFreed MB"
Suggestion: Consider using -Join or String Buider for better performance
Line 576:
Code: "Success - $totalGuidFoldersRemoved folders removed"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 578:
    Code: "    ✓ GUID Folders: $totalGuidFoldersRemoved folders removed, $totalGuidSpaceFreed MB freed"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 597:
    Code: "$UserProfile\Downloads"
Suggestion: Consider using -Join or String Buider for better performance
Line 598:
Code: "$UserProfile\Documents"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 608:
    Code: "  Scanning $($folder.Key) for files older than $FileAgeThresholdDays days..."
    Suggestion: Consider using -Join or String Buider for better performance
  Line 612:
    Code: "    No files found in $($folder.Key)"
Suggestion: Consider using -Join or String Buider for better performance
Line 624:
Code: $oldFiles += $file
    Suggestion: Consider using -Join or String Buider for better performance
  Line 633:
    Code: "    No old files found in $($folder.Key)"
Suggestion: Consider using -Join or String Buider for better performance
Line 640:
Code: $sizeBefore += $file.Length
    Suggestion: Consider using -Join or String Buider for better performance
  Line 654:
    Code: $script:ErrorLog += "Error deleting old file $($file.FullName): $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 654:
Code: "Error deleting old file $($file.FullName): $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 660:
Code: $script:TotalSpaceFreed += $sizeBeforeMB
    Suggestion: Consider using -Join or String Buider for better performance
  Line 661:
    Code: $script:CleanupReport += [PSCustomObject]@{
                        Location   = "$($folder.Key) Old Files - $Username"
                        Path       = $folderPath
                        SpaceFreed = "$sizeBeforeMB MB"
Status = "Success - $deletedCount files deleted"
                    }
    Suggestion: Consider using -Join or String Buider for better performance
  Line 662:
    Code: "$($folder.Key) Old Files - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 664:
    Code: "$sizeBeforeMB MB"
Suggestion: Consider using -Join or String Buider for better performance
Line 665:
Code: "Success - $deletedCount files deleted"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 667:
    Code: "    ✓ $($folder.Key): $deletedCount old files deleted, $sizeBeforeMB MB freed"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 671:
    Code: $script:ErrorLog += "Error processing old files in $($folder.Key) for $Username`: $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 671:
Code: "Error processing old files in $($folder.Key) for $Username`: $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 672:
Code: " Error processing old files in $($folder.Key): $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 676:
Code: $script:ErrorLog += "Error processing old files in $($folder.Key) for $Username`: $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 676:
Code: "Error processing old files in $($folder.Key) for $Username`: $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 677:
Code: " Error processing old files in $($folder.Key): $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 701:
Code: "Found $($UserProfiles.Count) user profiles to process"
Suggestion: Consider using -Join or String Buider for better performance
Line 704:
Code: "Failed to enumerate user profiles: $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 717:
Code: "Skipping invalid user profile path: $UserPath"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 723:
    Code: "Skipping profile with empty username: $UserPath"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 727:
    Code: "`nProcessing user: $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 731:
    Code: "User Temp - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 731:
    Code: "$UserPath\AppData\Local\Temp"
Suggestion: Consider using -Join or String Buider for better performance
Line 732:
Code: "User Temp2 - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 732:
    Code: "$UserPath\AppData\Local\Tmp"
Suggestion: Consider using -Join or String Buider for better performance
Line 733:
Code: "Recent Items - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 733:
    Code: "$UserPath\AppData\Roaming\Microsoft\Windows\Recent"
Suggestion: Consider using -Join or String Buider for better performance
Line 734:
Code: "Thumbnail Cache - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 734:
    Code: "$UserPath\AppData\Local\Microsoft\Windows\Explorer"
Suggestion: Consider using -Join or String Buider for better performance
Line 735:
Code: "Windows Error Reports - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 735:
    Code: "$UserPath\AppData\Local\Microsoft\Windows\WER"
Suggestion: Consider using -Join or String Buider for better performance
Line 736:
Code: "CrashDumps - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 736:
    Code: "$UserPath\AppData\Local\CrashDumps"
Suggestion: Consider using -Join or String Buider for better performance
Line 737:
Code: "Adobe Cache - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 737:
    Code: "$UserPath\AppData\Local\Adobe\*\Cache"
Suggestion: Consider using -Join or String Buider for better performance
Line 738:
Code: "Teams Cache - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 738:
    Code: "$UserPath\AppData\Roaming\Microsoft\Teams\tmp"
Suggestion: Consider using -Join or String Buider for better performance
Line 739:
Code: "Skype Cache - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 739:
    Code: "$UserPath\AppData\Roaming\Skype\*\chatsync"
Suggestion: Consider using -Join or String Buider for better performance
Line 740:
Code: "Discord Cache - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 740:
    Code: "$UserPath\AppData\Roaming\discord\Cache"
Suggestion: Consider using -Join or String Buider for better performance
Line 741:
Code: "Spotify Cache - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 741:
    Code: "$UserPath\AppData\Local\Spotify\Storage"
Suggestion: Consider using -Join or String Buider for better performance
Line 742:
Code: "Steam Logs - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 742:
    Code: "$UserPath\AppData\Local\Steam\logs"
Suggestion: Consider using -Join or String Buider for better performance
Line 760:
Code: $ErrorLog += "Error processing location $($location.Key): $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 760:
Code: "Error processing location $($location.Key): $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 773:
Code: $ErrorLog += "Error processing user $Username`: $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 773:
Code: "Error processing user $Username`: $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 774:
Code: "Error processing user $Username`: $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 782:
Code: "$env:WINDIR\Temp"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 783:
    Code: "$env:TEMP"
Suggestion: Consider using -Join or String Buider for better performance
Line 784:
Code: "$env:WINDIR\Prefetch"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 785:
    Code: "$env:WINDIR\SoftwareDistribution\Download"
Suggestion: Consider using -Join or String Buider for better performance
Line 786:
Code: "$env:WINDIR\Logs\CBS"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 787:
    Code: "$env:WINDIR\Logs\DISM"
Suggestion: Consider using -Join or String Buider for better performance
Line 788:
Code: "$env:WINDIR\WindowsUpdate.log*"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 789:
    Code: "$env:WINDIR\Minidump"
Suggestion: Consider using -Join or String Buider for better performance
Line 790:
Code: "$env:ALLUSERSPROFILE\Microsoft\Windows\WER"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 791:
    Code: "$env:WINDIR\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Logs"
Suggestion: Consider using -Join or String Buider for better performance
Line 807:
Code: $sizeBefore += Get-FolderSize -Path $bin.FullName
    Suggestion: Consider using -Join or String Buider for better performance
  Line 848:
    Code: $CleanupReport += [PSCustomObject]@{
            Location   = "Recycle Bin"
            Path       = "C:\`$Recycle.Bin"
SpaceFreed = "$sizeBefore MB"
            Status     = "Success"
        }
    Suggestion: Consider using -Join or String Buider for better performance
  Line 851:
    Code: "$sizeBefore MB"
Suggestion: Consider using -Join or String Buider for better performance
Line 854:
Code: $TotalSpaceFreed += $sizeBefore
    Suggestion: Consider using -Join or String Buider for better performance
  Line 855:
    Code: "✓ Recycle Bin: $sizeBefore MB freed"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 859:
    Code: $ErrorLog += "Error emptying Recycle Bin: $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 859:
Code: "Error emptying Recycle Bin: $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 860:
Code: "Error emptying Recycle Bin: $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 873:
Code: $TotalSpaceFreed += $cleanupFreed
    Suggestion: Consider using -Join or String Buider for better performance
  Line 874:
    Code: $CleanupReport += [PSCustomObject]@{
            Location   = "Windows Disk Cleanup"
            Path       = "System Utility"
            SpaceFreed = "$cleanupFreed MB"
Status = "Success"
}
Suggestion: Consider using -Join or String Buider for better performance
Line 877:
Code: "$cleanupFreed MB"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 880:
    Code: "✓ Windows Disk Cleanup: $cleanupFreed MB freed"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 884:
    Code: $ErrorLog += "Error running Disk Cleanup: $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 884:
Code: "Error running Disk Cleanup: $($_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 885:
Code: "Error running Disk Cleanup: $($\_.Exception.Message)"
Suggestion: Consider using -Join or String Buider for better performance
Line 890:
Code: "Total Space Freed: $([math]::Round($TotalSpaceFreed, 2)) MB ($([math]::Round($TotalSpaceFreed / 1024, 2)) GB)"
Suggestion: Consider using -Join or String Buider for better performance
Line 891:
Code: "Locations Cleaned: $($CleanupReport.Count)"
Suggestion: Consider using -Join or String Buider for better performance
Line 892:
Code: "Errors Encountered: $($ErrorLog.Count)"
Suggestion: Consider using -Join or String Buider for better performance
Line 909:
Code: "`nDATTO_OUTPUT: $($OutputData | ConvertTo-Json -Compress)"
Suggestion: Consider using -Join or String Buider for better performance

== WriteHostUsage (51 issues) ==
Line 115:
Code: Write-Host "✓ $Description`: $spaceFreed MB freed" -ForegroundColor Green
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
Line 177:
Code: Write-Host " Old file cleanup disabled - skipping Downloads/Documents" -ForegroundColor Gray
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 195:
    Code: Write-Host "  Scanning $($folder.Key) for files older than $FileAgeThresholdDays days..." -ForegroundColor Yellow
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
Line 199:
Code: Write-Host " No files found in $($folder.Key)" -ForegroundColor Gray
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 221:
    Code: Write-Host "    No old files found in $($folder.Key)" -ForegroundColor Gray
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 255:
    Code: Write-Host "    ✓ $($folder.Key): $deletedCount old files deleted, $sizeBeforeMB MB freed" -ForegroundColor Green
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
Line 265:
Code: Write-Host "=== Datto RMM Disk Cleanup Script ===" -ForegroundColor Cyan
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 266:
    Code: Write-Host "Starting cleanup process..." -ForegroundColor Yellow
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
Line 284:
Code: Write-Host "Found $($UserProfiles.Count) user profiles to process" -ForegroundColor Yellow
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 310:
    Code: Write-Host "`nProcessing user: $Username" -ForegroundColor Cyan
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
Line 370:
Code: Write-Host "`nCleaning system-wide locations..." -ForegroundColor Cyan
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 394:
    Code: Write-Host "`nEmptying Recycle Bin..." -ForegroundColor Yellow
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 450:
    Code: Write-Host "✓ Recycle Bin: $sizeBefore MB freed" -ForegroundColor Green
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
Line 459:
Code: Write-Host "`nRunning Windows Disk Cleanup..." -ForegroundColor Yellow
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 475:
    Code: Write-Host "✓ Windows Disk Cleanup: $cleanupFreed MB freed" -ForegroundColor Green
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 484:
    Code: Write-Host "`n=== CLEANUP SUMMARY ===" -ForegroundColor Green
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 485:
    Code: Write-Host "Total Space Freed: $([math]::Round($TotalSpaceFreed, 2)) MB ($([math]::Round($TotalSpaceFreed / 1024, 2)) GB)" -ForegroundColor Green
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 486:
    Code: Write-Host "Locations Cleaned: $($CleanupReport.Count)" -ForegroundColor Green
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 487:
    Code: Write-Host "Errors Encountered: $($ErrorLog.Count)" -ForegroundColor $(if ($ErrorLog.Count -eq 0) { 'Green' }else { 'Red' })
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 491:
    Code: Write-Host "`n=== ERRORS ===" -ForegroundColor Red
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
Line 492:
Code: Write-Host $_ -ForegroundColor Red
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
Line 504:
Code: Write-Host "`nDATTO_OUTPUT: $($OutputData | ConvertTo-Json -Compress)" -ForegroundColor Magenta
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 508:
    Code: Write-Host "`nCleanup completed successfully!" -ForegroundColor Green
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 512:
    Code: Write-Host "`nCleanup completed with warnings. Check error log." -ForegroundColor Yellow
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
Line 524:
Code: Write-Host " Scanning for GUID-named folders..." -ForegroundColor Yellow
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 548:
    Code: Write-Host "    Skipping GUID folder with critical files: $($guidFolder.Name)" -ForegroundColor Gray
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 578:
    Code: Write-Host "    ✓ GUID Folders: $totalGuidFoldersRemoved folders removed, $totalGuidSpaceFreed MB freed" -ForegroundColor Green
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
Line 581:
Code: Write-Host " No GUID folders found to remove" -ForegroundColor Gray
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 590:
    Code: Write-Host "  Old file cleanup disabled - skipping Downloads/Documents" -ForegroundColor Gray
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
Line 608:
Code: Write-Host " Scanning $($folder.Key) for files older than $FileAgeThresholdDays days..." -ForegroundColor Yellow
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
Line 612:
Code: Write-Host " No files found in $($folder.Key)" -ForegroundColor Gray
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 633:
    Code: Write-Host "    No old files found in $($folder.Key)" -ForegroundColor Gray
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 667:
    Code: Write-Host "    ✓ $($folder.Key): $deletedCount old files deleted, $sizeBeforeMB MB freed" -ForegroundColor Green
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
Line 682:
Code: Write-Host "=== Datto RMM Disk Cleanup Script ===" -ForegroundColor Cyan
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 683:
    Code: Write-Host "Starting cleanup process..." -ForegroundColor Yellow
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
Line 701:
Code: Write-Host "Found $($UserProfiles.Count) user profiles to process" -ForegroundColor Yellow
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 727:
    Code: Write-Host "`nProcessing user: $Username" -ForegroundColor Cyan
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
Line 778:
Code: Write-Host "`nCleaning system-wide locations..." -ForegroundColor Cyan
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 799:
    Code: Write-Host "`nEmptying Recycle Bin..." -ForegroundColor Yellow
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 855:
    Code: Write-Host "✓ Recycle Bin: $sizeBefore MB freed" -ForegroundColor Green
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
Line 864:
Code: Write-Host "`nRunning Windows Disk Cleanup..." -ForegroundColor Yellow
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 880:
    Code: Write-Host "✓ Windows Disk Cleanup: $cleanupFreed MB freed" -ForegroundColor Green
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 889:
    Code: Write-Host "`n=== CLEANUP SUMMARY ===" -ForegroundColor Green
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 890:
    Code: Write-Host "Total Space Freed: $([math]::Round($TotalSpaceFreed, 2)) MB ($([math]::Round($TotalSpaceFreed / 1024, 2)) GB)" -ForegroundColor Green
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 891:
    Code: Write-Host "Locations Cleaned: $($CleanupReport.Count)" -ForegroundColor Green
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 892:
    Code: Write-Host "Errors Encountered: $($ErrorLog.Count)" -ForegroundColor $(if ($ErrorLog.Count -eq 0) { 'Green' }else { 'Red' })
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 896:
    Code: Write-Host "`n=== ERRORS ===" -ForegroundColor Red
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
Line 897:
Code: Write-Host $_ -ForegroundColor Red
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
Line 909:
Code: Write-Host "`nDATTO_OUTPUT: $($OutputData | ConvertTo-Json -Compress)" -ForegroundColor Magenta
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 913:
    Code: Write-Host "`nCleanup completed successfully!" -ForegroundColor Green
Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 917:
    Code: Write-Host "`nCleanup completed with warnings. Check error log." -ForegroundColor Yellow
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)

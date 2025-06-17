
=== PowerShell Performance Analysis Report ===
Script: .\sample.ps1
Time: 2025-06-17 22:57:49

Summary:
Total Issues Found: 181

== ArrayAddition (24 issues) ==
  Line 108:
    Code: $script:TotalSpaceFreed += $spaceFreed
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 109:
    Code: $script:CleanupReport.Add([PSCustomObject]@{
                Location   = $Description
                Path       = $Path
                SpaceFreed = "$spaceFreed MB"
                Status     = "Success"
            })
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 119:
    Code: $script:ErrorLog.Add("Error cleaning $Description ($Path): $($_.Exception.Message)")
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 155:
    Code: $script:ErrorLog.Add("Error processing browser cache $($browser.Key) for $Username : $($_.Exception.Message)")
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 210:
    Code: $totalGuidSpaceFreed += $folderSize
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 215:
    Code: $script:ErrorLog.Add("Error removing GUID folder $($guidFolder.FullName): $($_.Exception.Message)")
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 221:
    Code: $script:ErrorLog.Add("Error scanning for GUID folders in $location : $($_.Exception.Message)")
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 227:
    Code: $script:TotalSpaceFreed += $totalGuidSpaceFreed
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 228:
    Code: $script:CleanupReport.Add([PSCustomObject]@{
            Location   = "GUID Folders - $Username"
            Path       = $UserProfile
            SpaceFreed = "$totalGuidSpaceFreed MB"
            Status     = "Success - $totalGuidFoldersRemoved folders removed"
        })
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 280:
    Code: $oldFiles.Add($file)
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 297:
    Code: $sizeBefore += $file.Length
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 311:
    Code: $script:ErrorLog.Add("Error deleting old file $($file.FullName): $($_.Exception.Message)")
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 317:
    Code: $script:TotalSpaceFreed += $sizeBeforeMB
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 318:
    Code: $script:CleanupReport.Add([PSCustomObject]@{
                    Location   = "$($folder.Key) Old Files - $Username"
                    Path       = $folderPath
                    SpaceFreed = "$sizeBeforeMB MB"
                    Status     = "Success - $deletedCount files deleted"
                })
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 328:
    Code: $script:ErrorLog.Add("Error processing old files in $($folder.Key) for $Username : $($_.Exception.Message)")
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 418:
    Code: $script:ErrorLog.Add("Error processing location $($location.Key): $($_.Exception.Message)")
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 434:
    Code: $ErrorLog.Add("Error processing user $Username : $($_.Exception.Message)")
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 471:
    Code: $sizeBefore += Get-FolderSize -Path $bin.FullName
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 512:
    Code: $CleanupReport.Add([PSCustomObject]@{
            Location   = "Recycle Bin"
            Path       = "C:\`$Recycle.Bin"
            SpaceFreed = "$sizeBefore MB"
            Status     = "Success"
        })
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 518:
    Code: $TotalSpaceFreed += $sizeBefore
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 523:
    Code: $ErrorLog.Add("Error emptying Recycle Bin: $($_.Exception.Message)")
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 537:
    Code: $TotalSpaceFreed += $cleanupFreed
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 538:
    Code: $CleanupReport.Add([PSCustomObject]@{
            Location   = "Windows Disk Cleanup"
            Path       = "System Utility"
            SpaceFreed = "$cleanupFreed MB"
            Status     = "Success"
        })
    Suggestion: Consider using ArrayList or Generic List for better performance
  Line 548:
    Code: $ErrorLog.Add("Error running Disk Cleanup: $($_.Exception.Message)")
    Suggestion: Consider using ArrayList or Generic List for better performance

== DynamicObjectCreation (5 issues) ==
  Line 109:
    Code: [PSCustomObject]@{
                Location   = $Description
                Path       = $Path
                SpaceFreed = "$spaceFreed MB"
                Status     = "Success"
            }
    Suggestion: Consider using classes or structured objects
  Line 228:
    Code: [PSCustomObject]@{
            Location   = "GUID Folders - $Username"
            Path       = $UserProfile
            SpaceFreed = "$totalGuidSpaceFreed MB"
            Status     = "Success - $totalGuidFoldersRemoved folders removed"
        }
    Suggestion: Consider using classes or structured objects
  Line 318:
    Code: [PSCustomObject]@{
                    Location   = "$($folder.Key) Old Files - $Username"
                    Path       = $folderPath
                    SpaceFreed = "$sizeBeforeMB MB"
                    Status     = "Success - $deletedCount files deleted"
                }
    Suggestion: Consider using classes or structured objects
  Line 512:
    Code: [PSCustomObject]@{
            Location   = "Recycle Bin"
            Path       = "C:\`$Recycle.Bin"
            SpaceFreed = "$sizeBefore MB"
            Status     = "Success"
        }
    Suggestion: Consider using classes or structured objects
  Line 538:
    Code: [PSCustomObject]@{
            Location   = "Windows Disk Cleanup"
            Path       = "System Utility"
            SpaceFreed = "$cleanupFreed MB"
            Status     = "Success"
        }
    Suggestion: Consider using classes or structured objects

== LargeCollectionLookup (10 issues) ==
  Line 109:
    Code: @{
                Location   = $Description
                Path       = $Path
                SpaceFreed = "$spaceFreed MB"
                Status     = "Success"
            }
    Suggestion: Consider using Dictionary<TKey,TValue> for large collections
  Line 132:
    Code: @{
        "Chrome Cache"  = "$UserProfile\AppData\Local\Google\Chrome\User Data\Default\Cache"
        "Chrome Cache2" = "$UserProfile\AppData\Local\Google\Chrome\User Data\Default\Cache2"
        "Edge Cache"    = "$UserProfile\AppData\Local\Microsoft\Edge\User Data\Default\Cache"
        "Firefox Cache" = "$UserProfile\AppData\Local\Mozilla\Firefox\Profiles\*\cache2"
        "IE Cache"      = "$UserProfile\AppData\Local\Microsoft\Windows\INetCache"
        "IE Cookies"    = "$UserProfile\AppData\Local\Microsoft\Windows\INetCookies"
    }
    Suggestion: Consider using Dictionary<TKey,TValue> for large collections
  Line 228:
    Code: @{
            Location   = "GUID Folders - $Username"
            Path       = $UserProfile
            SpaceFreed = "$totalGuidSpaceFreed MB"
            Status     = "Success - $totalGuidFoldersRemoved folders removed"
        }
    Suggestion: Consider using Dictionary<TKey,TValue> for large collections
  Line 252:
    Code: @{
        "Downloads" = "$UserProfile\Downloads"
        "Documents" = "$UserProfile\Documents"
    }
    Suggestion: Consider using Dictionary<TKey,TValue> for large collections
  Line 318:
    Code: @{
                    Location   = "$($folder.Key) Old Files - $Username"
                    Path       = $folderPath
                    SpaceFreed = "$sizeBeforeMB MB"
                    Status     = "Success - $deletedCount files deleted"
                }
    Suggestion: Consider using Dictionary<TKey,TValue> for large collections
  Line 382:
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
  Line 442:
    Code: @{
    "Windows Temp"          = "$env:WINDIR\Temp"
    "System Temp"           = "$env:TEMP"
    "System32 Temp"         = "$env:WINDIR\System32\config\systemprofile\AppData\Local\Temp"
    "Prefetch"              = "$env:WINDIR\Prefetch"
    "Software Distribution" = "$env:WINDIR\SoftwareDistribution\Download"
    "CBS Logs"              = "$env:WINDIR\Logs\CBS"
    "DISM Logs"             = "$env:WINDIR\Logs\DISM"
    "Windows Update Logs"   = "$env:WINDIR\WindowsUpdate.log*"
    "Memory Dumps"          = "$env:WINDIR\Minidump"
    "Error Reports"         = "$env:ALLUSERSPROFILE\Microsoft\Windows\WER"
    "Delivery Optimization" = "$env:WINDIR\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Logs"
    "IIS Logs"              = "$env:WINDIR\System32\LogFiles\W3SVC*"
    "Event Trace Logs"      = "$env:WINDIR\System32\LogFiles\WMI"
}
    Suggestion: Consider using Dictionary<TKey,TValue> for large collections
  Line 512:
    Code: @{
            Location   = "Recycle Bin"
            Path       = "C:\`$Recycle.Bin"
            SpaceFreed = "$sizeBefore MB"
            Status     = "Success"
        }
    Suggestion: Consider using Dictionary<TKey,TValue> for large collections
  Line 538:
    Code: @{
            Location   = "Windows Disk Cleanup"
            Path       = "System Utility"
            SpaceFreed = "$cleanupFreed MB"
            Status     = "Success"
        }
    Suggestion: Consider using Dictionary<TKey,TValue> for large collections
  Line 565:
    Code: @{
    TotalSpaceFreedMB = [math]::Round($TotalSpaceFreed, 2)
    TotalSpaceFreedGB = [math]::Round($TotalSpaceFreed / 1024, 2)
    LocationsCleaned  = $CleanupReport.Count
    ErrorCount        = $ErrorLog.Count
    Status            = if ($ErrorLog.Count -eq 0) { "Success" }else { "Warning" }
}
    Suggestion: Consider using Dictionary<TKey,TValue> for large collections

== StringAddition (114 issues) ==
  Line 52:
    Code: "Error getting folder size for $Path : $($_.Exception.Message)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 108:
    Code: $script:TotalSpaceFreed += $spaceFreed
    Suggestion: Consider using -Join or String Buider for better performance
  Line 112:
    Code: "$spaceFreed MB"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 115:
    Code: "✓ $Description`: $spaceFreed MB freed"
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
    Code: "Error processing browser cache $($browser.Key) for $Username : $($_.Exception.Message)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 174:
    Code: "$UserProfile"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 175:
    Code: "$UserProfile\AppData\Local"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 176:
    Code: "$UserProfile\AppData\Roaming"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 177:
    Code: "$UserProfile\AppData\LocalLow"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 204:
    Code: "    Skipping GUID folder with critical files: $($guidFolder.Name)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 210:
    Code: $totalGuidSpaceFreed += $folderSize
    Suggestion: Consider using -Join or String Buider for better performance
  Line 212:
    Code: "Removed GUID folder: $($guidFolder.FullName) ($folderSize MB)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 215:
    Code: "Error removing GUID folder $($guidFolder.FullName): $($_.Exception.Message)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 221:
    Code: "Error scanning for GUID folders in $location : $($_.Exception.Message)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 227:
    Code: $script:TotalSpaceFreed += $totalGuidSpaceFreed
    Suggestion: Consider using -Join or String Buider for better performance
  Line 229:
    Code: "GUID Folders - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 231:
    Code: "$totalGuidSpaceFreed MB"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 232:
    Code: "Success - $totalGuidFoldersRemoved folders removed"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 234:
    Code: "    ✓ GUID Folders: $totalGuidFoldersRemoved folders removed, $totalGuidSpaceFreed MB freed"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 253:
    Code: "$UserProfile\Downloads"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 254:
    Code: "$UserProfile\Documents"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 264:
    Code: "  Scanning $($folder.Key) for files older than $FileAgeThresholdDays days..."
    Suggestion: Consider using -Join or String Buider for better performance
  Line 268:
    Code: "    No files found in $($folder.Key)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 290:
    Code: "    No old files found in $($folder.Key)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 297:
    Code: $sizeBefore += $file.Length
    Suggestion: Consider using -Join or String Buider for better performance
  Line 311:
    Code: "Error deleting old file $($file.FullName): $($_.Exception.Message)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 317:
    Code: $script:TotalSpaceFreed += $sizeBeforeMB
    Suggestion: Consider using -Join or String Buider for better performance
  Line 319:
    Code: "$($folder.Key) Old Files - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 321:
    Code: "$sizeBeforeMB MB"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 322:
    Code: "Success - $deletedCount files deleted"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 324:
    Code: "    ✓ $($folder.Key): $deletedCount old files deleted, $sizeBeforeMB MB freed"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 328:
    Code: "Error processing old files in $($folder.Key) for $Username : $($_.Exception.Message)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 329:
    Code: "  Error processing old files in $($folder.Key): $($_.Exception.Message)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 353:
    Code: "Found $($UserProfiles.Count) user profiles to process"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 356:
    Code: "Failed to enumerate user profiles: $($_.Exception.Message)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 369:
    Code: "Skipping invalid user profile path: $UserPath"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 375:
    Code: "Skipping profile with empty username: $UserPath"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 379:
    Code: "`nProcessing user: $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 383:
    Code: "User Temp - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 383:
    Code: "$UserPath\AppData\Local\Temp"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 384:
    Code: "User Temp2 - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 384:
    Code: "$UserPath\AppData\Local\Tmp"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 385:
    Code: "User Temp Roaming - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 385:
    Code: "$UserPath\AppData\Roaming\Temp"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 386:
    Code: "User Temp LocalLow - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 386:
    Code: "$UserPath\AppData\LocalLow\Temp"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 387:
    Code: "Recent Items - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 387:
    Code: "$UserPath\AppData\Roaming\Microsoft\Windows\Recent"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 388:
    Code: "Thumbnail Cache - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 388:
    Code: "$UserPath\AppData\Local\Microsoft\Windows\Explorer"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 389:
    Code: "Windows Error Reports - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 389:
    Code: "$UserPath\AppData\Local\Microsoft\Windows\WER"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 390:
    Code: "CrashDumps - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 390:
    Code: "$UserPath\AppData\Local\CrashDumps"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 391:
    Code: "Adobe Cache - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 391:
    Code: "$UserPath\AppData\Local\Adobe\*\Cache"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 392:
    Code: "Teams Cache - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 392:
    Code: "$UserPath\AppData\Roaming\Microsoft\Teams\tmp"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 393:
    Code: "Teams Cache2 - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 393:
    Code: "$UserPath\AppData\Roaming\Microsoft\Teams\Cache"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 394:
    Code: "Skype Cache - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 394:
    Code: "$UserPath\AppData\Roaming\Skype\*\chatsync"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 395:
    Code: "Discord Cache - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 395:
    Code: "$UserPath\AppData\Roaming\discord\Cache"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 396:
    Code: "Spotify Cache - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 396:
    Code: "$UserPath\AppData\Local\Spotify\Storage"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 397:
    Code: "Steam Logs - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 397:
    Code: "$UserPath\AppData\Local\Steam\logs"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 398:
    Code: "Windows Installer Cache - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 398:
    Code: "$UserPath\AppData\Local\Microsoft\Windows\INetCache\IE"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 399:
    Code: "Office Cache - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 399:
    Code: "$UserPath\AppData\Local\Microsoft\Office\*\OfficeFileCache"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 400:
    Code: "OneDrive Temp - $Username"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 400:
    Code: "$UserPath\AppData\Local\Microsoft\OneDrive\logs"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 418:
    Code: "Error processing location $($location.Key): $($_.Exception.Message)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 434:
    Code: "Error processing user $Username : $($_.Exception.Message)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 435:
    Code: "Error processing user $Username : $($_.Exception.Message)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 443:
    Code: "$env:WINDIR\Temp"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 444:
    Code: "$env:TEMP"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 445:
    Code: "$env:WINDIR\System32\config\systemprofile\AppData\Local\Temp"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 446:
    Code: "$env:WINDIR\Prefetch"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 447:
    Code: "$env:WINDIR\SoftwareDistribution\Download"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 448:
    Code: "$env:WINDIR\Logs\CBS"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 449:
    Code: "$env:WINDIR\Logs\DISM"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 450:
    Code: "$env:WINDIR\WindowsUpdate.log*"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 451:
    Code: "$env:WINDIR\Minidump"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 452:
    Code: "$env:ALLUSERSPROFILE\Microsoft\Windows\WER"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 453:
    Code: "$env:WINDIR\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Logs"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 454:
    Code: "$env:WINDIR\System32\LogFiles\W3SVC*"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 455:
    Code: "$env:WINDIR\System32\LogFiles\WMI"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 471:
    Code: $sizeBefore += Get-FolderSize -Path $bin.FullName
    Suggestion: Consider using -Join or String Buider for better performance
  Line 515:
    Code: "$sizeBefore MB"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 518:
    Code: $TotalSpaceFreed += $sizeBefore
    Suggestion: Consider using -Join or String Buider for better performance
  Line 519:
    Code: "✓ Recycle Bin: $sizeBefore MB freed"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 523:
    Code: "Error emptying Recycle Bin: $($_.Exception.Message)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 524:
    Code: "Error emptying Recycle Bin: $($_.Exception.Message)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 537:
    Code: $TotalSpaceFreed += $cleanupFreed
    Suggestion: Consider using -Join or String Buider for better performance
  Line 541:
    Code: "$cleanupFreed MB"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 544:
    Code: "✓ Windows Disk Cleanup: $cleanupFreed MB freed"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 548:
    Code: "Error running Disk Cleanup: $($_.Exception.Message)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 549:
    Code: "Error running Disk Cleanup: $($_.Exception.Message)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 554:
    Code: "Total Space Freed: $([math]::Round($TotalSpaceFreed, 2)) MB ($([math]::Round($TotalSpaceFreed / 1024, 2)) GB)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 555:
    Code: "Locations Cleaned: $($CleanupReport.Count)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 556:
    Code: "Errors Encountered: $($ErrorLog.Count)"
    Suggestion: Consider using -Join or String Buider for better performance
  Line 573:
    Code: "`nDATTO_OUTPUT: $($OutputData | ConvertTo-Json -Compress)"
    Suggestion: Consider using -Join or String Buider for better performance

== WriteHostUsage (28 issues) ==
  Line 115:
    Code: Write-Host "✓ $Description`: $spaceFreed MB freed" -ForegroundColor Green
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 180:
    Code: Write-Host "  Scanning for GUID-named folders..." -ForegroundColor Yellow
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 204:
    Code: Write-Host "    Skipping GUID folder with critical files: $($guidFolder.Name)" -ForegroundColor Gray
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 234:
    Code: Write-Host "    ✓ GUID Folders: $totalGuidFoldersRemoved folders removed, $totalGuidSpaceFreed MB freed" -ForegroundColor Green
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 237:
    Code: Write-Host "    No GUID folders found to remove" -ForegroundColor Gray
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 246:
    Code: Write-Host "  Old file cleanup disabled - skipping Downloads/Documents" -ForegroundColor Gray
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 264:
    Code: Write-Host "  Scanning $($folder.Key) for files older than $FileAgeThresholdDays days..." -ForegroundColor Yellow
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 268:
    Code: Write-Host "    No files found in $($folder.Key)" -ForegroundColor Gray
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 290:
    Code: Write-Host "    No old files found in $($folder.Key)" -ForegroundColor Gray
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 324:
    Code: Write-Host "    ✓ $($folder.Key): $deletedCount old files deleted, $sizeBeforeMB MB freed" -ForegroundColor Green
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 334:
    Code: Write-Host "=== Datto RMM Disk Cleanup Script ===" -ForegroundColor Cyan
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 335:
    Code: Write-Host "Starting cleanup process..." -ForegroundColor Yellow
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 353:
    Code: Write-Host "Found $($UserProfiles.Count) user profiles to process" -ForegroundColor Yellow
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 379:
    Code: Write-Host "`nProcessing user: $Username" -ForegroundColor Cyan
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 439:
    Code: Write-Host "`nCleaning system-wide locations..." -ForegroundColor Cyan
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 463:
    Code: Write-Host "`nEmptying Recycle Bin..." -ForegroundColor Yellow
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 519:
    Code: Write-Host "✓ Recycle Bin: $sizeBefore MB freed" -ForegroundColor Green
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 528:
    Code: Write-Host "`nRunning Windows Disk Cleanup..." -ForegroundColor Yellow
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 544:
    Code: Write-Host "✓ Windows Disk Cleanup: $cleanupFreed MB freed" -ForegroundColor Green
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 553:
    Code: Write-Host "`n=== CLEANUP SUMMARY ===" -ForegroundColor Green
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 554:
    Code: Write-Host "Total Space Freed: $([math]::Round($TotalSpaceFreed, 2)) MB ($([math]::Round($TotalSpaceFreed / 1024, 2)) GB)" -ForegroundColor Green
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 555:
    Code: Write-Host "Locations Cleaned: $($CleanupReport.Count)" -ForegroundColor Green
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 556:
    Code: Write-Host "Errors Encountered: $($ErrorLog.Count)" -ForegroundColor $(if ($ErrorLog.Count -eq 0) { 'Green' }else { 'Red' })
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 560:
    Code: Write-Host "`n=== ERRORS ===" -ForegroundColor Red
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 561:
    Code: Write-Host $_ -ForegroundColor Red
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 573:
    Code: Write-Host "`nDATTO_OUTPUT: $($OutputData | ConvertTo-Json -Compress)" -ForegroundColor Magenta
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 577:
    Code: Write-Host "`nCleanup completed successfully!" -ForegroundColor Green
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)
  Line 581:
    Code: Write-Host "`nCleanup completed with warnings. Check error log." -ForegroundColor Yellow
    Suggestion: Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline($message)

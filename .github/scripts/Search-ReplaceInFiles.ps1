function Search-ReplaceInFiles
{
    param (
        [Parameter()]
        [string]$FolderPath = [System.Environment]::CurrentDirectory,
        [Parameter(Mandatory = $true)]
        [string]$SearchKeyword,
        [Parameter(Mandatory = $true)]
        [string]$ReplaceWith,
        [Parameter(Mandatory = $false)]
        [string]$FileFilter = "*.*"
    )
    if (-not (Test-Path -Path $FolderPath))
    {
        Write-Error "Folder path does not exist: $FolderPath"
        return
    }
    try
    {
        $files = Get-ChildItem -Path $FolderPath -Filter $FileFilter -File -Recurse
        foreach ($file in $files)
        {
            Write-Host "Processing file: $($file.FullName)"
            $content = Get-Content -Path $file.FullName -Raw
            if ($content -match [regex]::Escape($SearchKeyword))
            {
                Write-Host "Found match in: $($file.FullName)" -ForegroundColor Green
                $newContent = $content -replace [regex]::Escape($SearchKeyword), $ReplaceWith
                $newContent | Set-Content -Path $file.FullName -Force
                Write-Host "Replaced '$SearchKeyword' with '$ReplaceWith'" -ForegroundColor Yellow
            }
        }
    }
    catch
    {
        Write-Error "An error occurred: $_"
    }
}

# Function: Search and Replace String in Files Recursively
# Description: This function searches for the string 'Function' in files within the provided input path, and replaces it with the provided replacement string.
#              It processes all files recursively within the directory structure.

function Replace-FunctionInFiles
{
    param (
        # Path to the directory that contains files to be searched
        [string]$InputPath,
        # The replacement string that will replace 'Function'
        [string]$ReplacementString
    )
    # Recursively retrieve all files from the input directory.
    Get-ChildItem -Path $InputPath -Recurse -File | ForEach-Object {
        $filePath = $_.FullName  # Get full file path
        # Try to handle each file
        try
        {
            # Read the content of the current file.
            # We are using Get-Content to retrieve the file content as an array of strings (each line as an element)
            $fileContent = Get-Content -Path $filePath
            # Initialize a flag to determine if any replacements are made
            $replacementMade = $false
            # Loop through each line and search for the 'Function' string.
            # We're using a simple for loop to track line numbers easily.
            for ($i = 0; $i -lt $fileContent.Length; $i++)
            {
                # Use -match operator to find occurrences of the string 'Function'.
                # You can make it case-insensitive by changing 'Function' to '(?i)Function'
                if ($fileContent[$i] -match 'Function')
                {
                    $lineNumber = $i + 1  # Adjust for 0-based index (PowerShell arrays are 0-based)
                    Write-Host "Found 'Function' in file: $filePath at line $lineNumber"
                    # Perform the replacement.
                    # Use the -replace operator to substitute 'Function' with the replacement string.
                    $fileContent[$i] = $fileContent[$i] -replace 'Function', $ReplacementString
                    # Set the replacementMade flag to true if a replacement occurs
                    $replacementMade = $true
                }
            }
            # If any replacements were made, overwrite the file with the updated content.
            if ($replacementMade)
            {
                # Use Set-Content to write the modified content back to the file.
                # This will overwrite the file with the updated lines.
                $fileContent | Set-Content -Path $filePath
                Write-Host "Replaced 'Function' in file: $filePath"
            }
        }
        catch
        {
            # Catch any errors that occur during file processing (e.g., access issues).
            Write-Warning "Error processing file $filePath: $_"
        }
    }
}
# Usage Example:
# Call the function, providing the input path and the replacement string.
# Replace all occurrences of 'Function' with 'MyNewFunction'.
$inputPath = 'C:\path\to\your\input\folder'  # Replace with your input folder path
$replacementString = 'MyNewFunction'         # Replace with the desired replacement string
Replace-FunctionInFiles -InputPath $inputPath -ReplacementString $replacementString

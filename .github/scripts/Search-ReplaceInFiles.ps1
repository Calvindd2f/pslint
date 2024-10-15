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
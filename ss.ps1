$t = $tool
$actionBtn.Add_Click({
    Write-ConsoleLog "Selected tool: $($t.Name) [Type: $($t.Type)]"
    $statusTitle.Text = $t.Name
    $statusSub.Text = $t.Desc
    $statusBadge.Text = $t.Type

    # Ensure install directory exists
    if (!(Test-Path $installDir)) {
        New-Item -ItemType Directory -Force -Path $installDir | Out-Null
    }

    if ($t.Type -eq "GitHub" -or $t.Type -eq "Web" -or $t.Type -eq "Link") {
        # Check if the URL points directly to a zip file or executable
        if ($t.URL -match "\.zip$") {
            Write-ConsoleLog "Downloading zip archive for $($t.Name)..."
            $fileName = [System.IO.Path]::GetFileName($t.URL)
            $destinationZip = Join-Path $installDir $fileName
            $extractPath = Join-Path $installDir ($t.Name -replace '[^\w]', '_')

            try {
                # Download file
                Invoke-WebRequest -Uri $t.URL -OutFile $destinationZip -UseBasicParsing
                Write-ConsoleLog "Download complete. Extracting to $extractPath..."

                # Extract zip
                if (!(Test-Path $extractPath)) { New-Item -ItemType Directory -Force -Path $extractPath | Out-Null }
                Expand-Archive -Path $destinationZip -DestinationPath $extractPath -Force
                
                Write-ConsoleLog "Successfully extracted $($t.Name)."
                Start-Process "explorer.exe" $extractPath
            } catch {
                Write-ConsoleLog "Error downloading/extracting $($t.Name): $_"
            }
        } elseif ($t.URL -match "\.exe$") {
            Write-ConsoleLog "Downloading executable for $($t.Name)..."
            $fileName = [System.IO.Path]::GetFileName($t.URL)
            $destinationExe = Join-Path $installDir $fileName

            try {
                Invoke-WebRequest -Uri $t.URL -OutFile $destinationExe -UseBasicParsing
                Write-ConsoleLog "Download complete. Launching $($t.Name)..."
                Start-Process $destinationExe
            } catch {
                Write-ConsoleLog "Error downloading/running $($t.Name): $_"
            }
        } else {
            Write-ConsoleLog "Opening URL for $($t.Name): $($t.URL)"
            Start-Process $t.URL
        }
    } elseif ($t.Type -eq "Cmd") {
        Write-ConsoleLog "Executing inline command for $($t.Name)..."
        try {
            Invoke-Expression $t.Command
            Write-ConsoleLog "Successfully executed command for $($t.Name)."
        } catch {
            Write-ConsoleLog "Error executing command: $_"
        }
    }
})

npm install 
npm install -g nlf 
# Run nlf and capture its output to a file
nlf > output.txt
# Check if output.txt was created and has content
if (-not (Test-Path "output.txt") -or (Get-Content "output.txt").Length -eq 0) {
    Write-Error "Error: output.txt was not created or is empty."
    exit 1
}
# Display output.txt for debugging purposes
Write-Host "Contents of output.txt:"
Get-Content "output.txt" | Write-Host
# Extract lines containing "[license(s): ...]" from output.txt (adapted to match the nlf output structure)
Select-String -Path "output.txt" -Pattern "license\(s\): .+" | ForEach-Object { $_.Line } | Set-Content "sbom-licenses.txt"
# Ensure that sbom-licenses.txt exists and has content before proceeding
if (-not (Test-Path "sbom-licenses.txt") -or (Get-Content "sbom-licenses.txt").Length -eq 0) {
    Write-Error "Error: sbom-licenses.txt does not exist or is empty."
    exit 1
}
# Parse sbom-licenses.txt and format the output into licenses_parsed.txt
Get-Content "sbom-licenses.txt" | ForEach-Object {
    if ($_ -match '@([^@]*)@([^ ]*) \[license\(s\): (.*)\]') {
        "{0,-80} {1,-40} {2}" -f $matches[1].Trim(), $matches[2].Trim(), $matches[3].Trim()
    } elseif ($_ -match '([^@]*)@([^ ]*) \[license\(s\): (.*)\]') {
        "{0,-80} {1,-40} {2}" -f $matches[1].Trim(), $matches[2].Trim(), $matches[3].Trim()
    } else {
        $_
    }
} | Sort-Object | Set-Content "licenses_parsed.txt"
# Verify if licenses_parsed.txt has been successfully created and populated
if (-not (Test-Path "licenses_parsed.txt") -or (Get-Content "licenses_parsed.txt").Length -eq 0) {
    Write-Error "Error: licenses_parsed.txt was not created or is empty."
    exit 1
}
Write-Host "licenses_parsed.txt has been successfully created and populated."



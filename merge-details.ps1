# Define file paths
$latestDependenciesFile = "latest-dependencies.txt"
$licensesParsedFile = "licenses_parsed.txt"
$outputFile = "sbom-result.txt"
# Read latest dependencies
$latestDependencies = @{ }
Get-Content $latestDependenciesFile | ForEach-Object {
    if ($_ -match '^(.*?)\s+(\d+\.\d+\.\d+)\s*$') {
        $dependency = $matches[1].Trim()
        $latestVersion = $matches[2].Trim()
        $latestDependencies[$dependency] = $latestVersion
    }
}
# Read licenses parsed
$licensesParsed = @{ }
Get-Content $licensesParsedFile | ForEach-Object {
    if ($_ -match '^(.*?)\s+(\d+\.\d+\.\d+)\s+(.+)$') {
        $dependency = $matches[1].Trim()
        $version = $matches[2].Trim()
        $license = $matches[3].Trim()
        $licensesParsed[$dependency] = @{ Version = $version; License = $license }
    }
}
# Prepare output
$output = @()
foreach ($dep in $licensesParsed.Keys) {
    $licenseInfo = $licensesParsed[$dep]
    $latestVersion = if ($latestDependencies.ContainsKey($dep)) { $latestDependencies[$dep] } else { $licenseInfo.Version }
    # Check if versions are different and mark them with **
    $currentVersion = $licenseInfo.Version
    if ($currentVersion -ne $latestVersion) {
        $currentVersion += "**"
        $latestVersion += "**"
    }
    $output += [PSCustomObject]@{
        Dependency = $dep
        CurrentVersion = $currentVersion
        LatestVersion = $latestVersion
        License = $licenseInfo.License
    }
}
foreach ($dep in $latestDependencies.Keys) {
    if (-not $licensesParsed.ContainsKey($dep)) {
        $output += [PSCustomObject]@{
            Dependency = $dep
            CurrentVersion = "N/A"
            LatestVersion = $latestDependencies[$dep]
            License = "N/A"
        }
    }
}
# Exclude rows with all "N/A" values
$output = $output | Where-Object {
    $_.CurrentVersion -ne "N/A" -or
    $_.LatestVersion -ne "N/A" -or
    $_.License -ne "N/A"
}
# Write output to file
$output | Format-Table -AutoSize | Out-File $outputFile -Encoding UTF8

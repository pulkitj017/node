# Path to the Node.js project
$projectPath = "./"
# Navigate to the project directory
Set-Location -Path $projectPath
# Read the package.json file and parse it as JSON
$packageJson = Get-Content package.json | Out-String | ConvertFrom-Json
# Fetch the list of dependencies and devDependencies
$dependencies = $packageJson.dependencies.PSObject.Properties.Name
$devDependencies = $packageJson.devDependencies.PSObject.Properties.Name
$allDependencies = $dependencies + $devDependencies
# Initialize an array to store the results
$results = @()
# Loop through each dependency and get the latest version
foreach ($dependency in $allDependencies) {
    $latestVersion = npm show $dependency version
    $results += [PSCustomObject]@{
        Dependency = $dependency
        LatestVersion = $latestVersion
    }
}
# Output the results to a text file in a tabular format
$results | Format-Table -AutoSize | Out-File -FilePath "latest-dependencies.txt"
# Print a message indicating that the operation is complete
Write-Output "Latest versions of dependencies have been written to latest-dependencies.txt"
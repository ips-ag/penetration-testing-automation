param (
    [string]$envFile
)

# Dictionary to store loaded variables
$loadedVars = @{}

# Check if .env file exists
if (Test-Path $envFile) {
    # Load environment variables from .env file
    Get-Content $envFile | ForEach-Object {
        if ($_ -match "^(.*?)=(.*)$") {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            Set-Item -Path "Env:$key" -Value $value
            $loadedVars[$key] = $value  # Store for printing later
        }
    }
    Write-Output "✅ Loaded environment variables from $envFile"
} else {
    Write-Output "⚠️ No .env file found. Assuming Azure DevOps environment variables are used."
}

# Print only loaded variables, masking CLIENT_SECRET for security
Write-Output "`n🔍 Environment Variables:"
foreach ($key in $loadedVars.Keys) {
    if ($key -eq "CLIENT_SECRET") {
        Write-Output "$key=********"
    } else {
        Write-Output "$key=$($loadedVars[$key])"
    }
}

# Convert CLIENT_SECRET to SecureString
$secureSecret = ConvertTo-SecureString $env:NVD_API_KEY -AsPlainText -Force

# Execute the main script
.\Pentest-Run.ps1 `
    -ScanType $env:SCAN_TYPE `
    -TargetPath $env:TARGET_PATH `
    -TargetURL $env:TARGET_URL `
    -OutputPath $env:OUTPUT_PATH `
    -NVDApiKey $secureSecret

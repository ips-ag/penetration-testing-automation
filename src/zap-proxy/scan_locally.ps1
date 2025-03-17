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
Write-Output ""

# Convert CLIENT_SECRET to SecureString
$secureSecret = ConvertTo-SecureString $env:CLIENT_SECRET -AsPlainText -Force

# Execute the main script
.\openapi_scan.ps1 -client_id $env:CLIENT_ID -client_secret $secureSecret -scope $env:SCOPE -tokenUri $env:TOKEN_URI -swaggerJson $env:SWAGGER_JSON -workDir $env:WORK_DIR

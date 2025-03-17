param (
    [string]$client_id,
    [securestring]$client_secret,
    [string]$scope,
    [string]$tokenUri,
    [string]$swaggerJson,
    [string]$workDir  # Added parameter for working directory
)

# Convert SecureString to Plain Text
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($client_secret)
$client_secret_plain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# Step 1: Fetch Access Token
try {
    $tokenResponse = Invoke-RestMethod -Method Post -Uri $tokenUri `
        -Body @{
            grant_type = "client_credentials"
            client_id = $client_id
            client_secret = $client_secret_plain
            scope = $scope
        }
    $access_token = $tokenResponse.access_token
    Write-Output "✅ Access Token Retrieved!"
} catch {
    Write-Output "❌ Failed to Get Access Token!"
    Write-Output $_.Exception.Message
    exit 1  # Stop execution if token retrieval fails
}

# Set environment variables
$env:ZAP_AUTH_HEADER_VALUE = "Bearer $access_token"
$env:ZAP_AUTH_HEADER = "Authorization"

# Ensure work directory exists
if (-Not (Test-Path $workDir)) {
    Write-Output "❌ Work directory '$workDir' does not exist!"
    exit 1
}

Write-Output "🚀 Pulling OWASP ZAP latest image..."
# Pull the latest zaproxy/zap-stable image
docker image pull ghcr.io/zaproxy/zaproxy:latest

# Step 2: Run OWASP ZAP Docker Scan with the Token
Write-Output "🚀 Running OWASP ZAP scan..."
docker run --rm -v "${workDir}:/zap/wrk" `
    -e ZAP_AUTH_HEADER_VALUE=$env:ZAP_AUTH_HEADER_VALUE `
    -e ZAP_AUTH_HEADER=$env:ZAP_AUTH_HEADER `
    -t ghcr.io/zaproxy/zaproxy:latest zap-api-scan.py `
    -t $swaggerJson `
    -f openapi `
    -r zap_report.html

Write-Output "✅ Scan Completed! Report saved in ${workDir}\zap_report.html"

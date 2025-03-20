# Parameter block must be at the top of the script
param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("Baseline", "Full", "API", IgnoreCase = $true)]
    [string]$scanType,

    [ValidateScript({
        if ($scanType -ieq "api" -and [string]::IsNullOrEmpty($_)) {
            throw "client_id is required for API scan."
        }
        $true
    })]
    [string]$client_id,

    [ValidateScript({
        if ($scanType -ieq "api" -and -not $_) {
            throw "client_secret is required for API scan."
        }
        $true
    })]
    [SecureString]$client_secret,

    [ValidateScript({
        if ($scanType -ieq "api" -and [string]::IsNullOrEmpty($_)) {
            throw "scope is required for API scan."
        }
        $true
    })]
    [string]$scope,

    [ValidateScript({
        if ($scanType -ieq "api" -and [string]::IsNullOrEmpty($_)) {
            throw "tokenUri is required for API scan."
        }
        $true
    })]
    [string]$tokenUri,

    [ValidateScript({
        if ($scanType -ieq "api" -and ($_ -notmatch "swagger.json$")) {
            throw "targetUrl must end with 'swagger.json' for API scan."
        }
        $true
    })]
    [string]$targetUrl,

    [Parameter(Mandatory=$true)]
    [string]$workDir
)

# Rest of the script
try {
    $null = Get-Command docker -ErrorAction Stop
    docker info --format '{{.ServerVersion}}' | Out-Null
} catch {
    Write-Error "Docker is not installed or not running. Please ensure Docker is available."
    exit 1
}

$workDir = [System.IO.Path]::GetFullPath($workDir)
if (-not (Test-Path $workDir)) {
    Write-Output "⚠️ Work directory '$workDir' does not exist. Creating..."
    New-Item -ItemType Directory -Path $workDir -Force | Out-Null
}

Write-Output "🚀 Pulling OWASP ZAP latest image..."
docker image pull ghcr.io/zaproxy/zaproxy:latest | Out-Null

$zapScript = switch ($scanType.ToLower()) {
    "baseline" { "zap-baseline.py" }
    "full"     { "zap-full-scan.py" }
    "api"      { "zap-api-scan.py" }
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportName = "$($zapScript -replace '\.py$','')_$timestamp"
$volumeMapping = if ($PSVersionTable.PSVersion.Major -ge 6) {
    "$($workDir):/zap/wrk"
} else {
    "$($workDir -replace '\\','/'):/zap/wrk"
}

Write-Output "🚀 Running OWASP ZAP $scanType scan..."
if ($scanType -ieq "api") {
    try {
        $cred = New-Object System.Management.Automation.PSCredential("dummy", $client_secret)
        $client_secret_plain = $cred.GetNetworkCredential().Password

        $tokenResponse = Invoke-RestMethod -Method Post -Uri $tokenUri `
            -Body @{
                grant_type    = "client_credentials"
                client_id     = $client_id
                client_secret = $client_secret_plain
                scope         = $scope
            } `
            -ErrorAction Stop

        # if (-not $tokenResponse?.access_token) {
        #     throw "Invalid token response format! Expected 'access_token' but got: $($tokenResponse | ConvertTo-Json -Depth 3)"
        # }

        $access_token = $tokenResponse.access_token
        Write-Output "✅ Access Token Retrieved!"
    } catch {
        Write-Error "❌ Failed to Get Access Token: $($_.Exception.Message)"
        exit 1
    } finally {
        $client_secret_plain = $null
    }

    docker run --rm -v $volumeMapping `
        -e ZAP_AUTH_HEADER_VALUE="Bearer $access_token" `
        -e ZAP_AUTH_HEADER="Authorization" `
        -t ghcr.io/zaproxy/zaproxy:latest $zapScript `
        -t $targetUrl `
        -f openapi `
        -r "$reportName.html" `
        -J "$reportName.json"
} else {
    docker run --rm -v $volumeMapping `
        -t ghcr.io/zaproxy/zaproxy:latest $zapScript `
        -t $targetUrl `
        -r "$reportName.html" `
        -J "$reportName.json"
}

Write-Output "✅ Scan Completed! Reports saved in ${workDir}\${reportName}.(html/json)"
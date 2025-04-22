param (
    [string]$swaggerUrl,  # Swagger API URL
    [string]$port = "3000",  # Port for Threat Dragon
    [string]$workDir
)

# Define container name
$containerName = "threat-dragon"

# Ensure necessary directories exist
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$workDir = Join-Path -Path $workDir -ChildPath $timestamp
if (!(Test-Path $workDir)) {
    Write-Output "📁 Creating directory: $workDir"
    New-Item -ItemType Directory -Path $workDir | Out-Null
}

# Pull and run Threat Dragon in Docker
Write-Output "📦 Pulling Threat Dragon image..."
docker pull owasp/threat-dragon:stable

Write-Output "🚀 Starting OWASP Threat Dragon..."
docker run -d -p "$port`:3000" -v "${workDir}:/app/models" --name $containerName owasp/threat-dragon:stable

Start-Sleep -Seconds 5  # Ensure container is up

$jsonFile = "$workDir\threat-model.json"
$htmlReport = "$workDir\threat-report.html"
$jsonReport = "$workDir\threat-report.json"

# Convert Swagger to Threat Dragon JSON
if ($swaggerUrl) {
    Write-Output "🔄 Converting Swagger to Threat Model..."
    .\Convert-SwaggerToThreatDragon.ps1 -swaggerUrl $swaggerUrl -outputFolder $workDir
    Write-Output "✅ Threat model saved: $workDir\threat-model.json"
} else {
    Write-Output "⚠️ No Swagger URL provided. Skipping conversion."
}

# **Automatically Analyze Threat Model**
Write-Output "📊 Analyzing Threat Model and Generating Reports..."

if (Test-Path $jsonFile) {
    $threatModel = Get-Content -Raw -Path $jsonFile | ConvertFrom-Json
    $threats = $threatModel.threats

    if ($threats.Count -gt 0) {
        $threats | ConvertTo-Json -Depth 3 | Set-Content -Path $jsonReport
        Write-Output "✅ JSON Report saved at: $jsonReport"
        
        .\Generate-Report.ps1 -jsonReport $jsonReport -htmlOutput $htmlReport
    } else {
        Write-Output "⚠️ No threats found in the model."
    }
} else {
    Write-Output "❌ No Threat Model JSON file found. Report generation skipped."
}

# Stop and remove container
Write-Output "🛑 Stopping and removing Threat Dragon..."
docker stop $containerName
docker rm $containerName

Write-Output "✅ Threat modeling complete. Reports generated and container removed."
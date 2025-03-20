param (
    [string]$swaggerUrl,  # Swagger API URL
    [string]$port = "3000",  # Port for Threat Dragon
    [string]$dataPath = "$HOME\threat-models",  # Storage for threat models
    [string]$reportPath = "$HOME\threat-reports"  # Output for reports
)

# Define container name
$containerName = "threat-dragon"

# Ensure necessary directories exist
foreach ($path in @($dataPath, $reportPath)) {
    if (!(Test-Path $path)) {
        Write-Output "📁 Creating directory: $path"
        New-Item -ItemType Directory -Path $path | Out-Null
    }
}

# Pull and run Threat Dragon in Docker
Write-Output "📦 Pulling Threat Dragon image..."
docker pull owasp/threat-dragon:stable

Write-Output "🚀 Starting OWASP Threat Dragon..."
docker run -d -p "$port`:3000" -v "${dataPath}:/app/models" --name $containerName owasp/threat-dragon:stable

Start-Sleep -Seconds 5  # Ensure container is up

# Convert Swagger to Threat Dragon JSON
if ($swaggerUrl) {
    Write-Output "🔄 Converting Swagger to Threat Model..."
    .\Convert-SwaggerToThreatDragon.ps1 -swaggerUrl $swaggerUrl -outputFolder $dataPath
    Write-Output "✅ Threat model saved: $dataPath\threat-model.json"
} else {
    Write-Output "⚠️ No Swagger URL provided. Skipping conversion."
}

# **Automatically Analyze Threat Model**
Write-Output "📊 Analyzing Threat Model and Generating Reports..."

$jsonFile = "$dataPath\threat-model.json"
$htmlReport = "$reportPath\threat-report.html"
$jsonReport = "$reportPath\threat-report.json"

if (Test-Path $jsonFile) {
    $threatModel = Get-Content -Raw -Path $jsonFile | ConvertFrom-Json
    $threats = $threatModel.threats

    if ($threats.Count -gt 0) {
        $threats | ConvertTo-Json -Depth 3 | Set-Content -Path $jsonReport
        Write-Output "✅ JSON Report saved at: $jsonReport"

        # Generate HTML Report
        $htmlContent = "<html><head><title>Threat Model Report</title></head><body>"
        $htmlContent += "<h1>Threat Model Report</h1><ul>"
        
        foreach ($threat in $threats) {
            $htmlContent += "<li><strong>$($threat.title)</strong>: $($threat.description)</li>"
        }

        $htmlContent += "</ul></body></html>"
        $htmlContent | Set-Content -Path $htmlReport
        Write-Output "✅ HTML Report saved at: $htmlReport"
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
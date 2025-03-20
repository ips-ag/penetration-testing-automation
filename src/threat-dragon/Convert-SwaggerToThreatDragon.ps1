param (
    [string]$swaggerUrl = "http://localhost:5000/swagger/v1/swagger.json", # Default Swagger URL
    [string]$outputFolder = "." # Default output folder (current directory)
)

# Ensure output folder exists
if (!(Test-Path $outputFolder)) {
    Write-Output "⚠️ Output directory '$outputFolder' does not exist. Creating..."
    New-Item -ItemType Directory -Path $outputFolder | Out-Null
}

# Define output file path
$outputFile = Join-Path -Path $outputFolder -ChildPath "threat-model.json"

# Download Swagger JSON
Write-Host "Downloading Swagger JSON from: $swaggerUrl"
try {
    $swaggerJson = Invoke-RestMethod -Uri $swaggerUrl -ErrorAction Stop
} catch {
    Write-Host "Failed to download Swagger JSON. Check the URL."
    exit 1
}

# Initialize Threat Dragon JSON structure
$threatModel = @{
    summary = "Threat Model for .NET API"
    detail = "Generated from Swagger"
    version = "1.0"
    boundaries = @("Internet", "Internal Network")
    dataflows = @()
    threats = @()
}

# Extract API Endpoints
if ($swaggerJson.PSObject.Properties["paths"]) {
    foreach ($path in $swaggerJson.paths.PSObject.Properties) {
        $endpoint = $path.Name
        foreach ($method in $path.Value.PSObject.Properties) {
            $httpMethod = $method.Name
            $operationId = $method.Value.operationId

            # Add API call as a data flow
            $threatModel.dataflows += @{
                id = (New-Guid).Guid
                name = "$httpMethod $endpoint"
                source = "Client"
                target = "API Gateway"
                protocol = "HTTPS"
                data = "JSON Payload"
            }

            # Add a basic STRIDE-based threat for each endpoint
            $threatModel.threats += @{
                id = (New-Guid).Guid
                name = "Potential Threat in $operationId"
                description = "Threat related to $httpMethod $endpoint"
                category = "Information Disclosure"
                mitigation = "Ensure authentication & encryption"
                severity = "Medium"
            }
        }
    }
}

# Convert to JSON and save
$threatModelJson = $threatModel | ConvertTo-Json -Depth 10
$threatModelJson | Set-Content $outputFile

Write-Host "Threat model generated at: $outputFile"
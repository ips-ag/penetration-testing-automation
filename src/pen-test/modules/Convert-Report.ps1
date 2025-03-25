function Convert-Report {
    param (
        [string]$Scanner,   # Tool Name (e.g., OWASP ZAP, Snyk, Trivy, etc.)
        [string]$Category,  # SAST, SCA, DAST, SECRETS, IaC
        [string]$ReportPath # Path to the report file (JSON, XML, CSV)
    )

    # Check if file exists
    if (!(Test-Path $ReportPath)) {
        Write-Host "File not found: $ReportPath"
        return
    }

    # Get file extension
    $fileExtension = [System.IO.Path]::GetExtension($ReportPath)

    # Initialize raw data variable
    $rawData = $null

    # Detect file type and parse accordingly
    if ($fileExtension -eq ".json") {
        $rawData = Get-Content -Path $ReportPath | ConvertFrom-Json
    }
    elseif ($fileExtension -eq ".xml") {
        $rawData = [xml](Get-Content -Path $ReportPath)
    }
    elseif ($fileExtension -eq ".csv") {
        $rawData = Import-Csv -Path $ReportPath
    }
    else {
        Write-Host "Unsupported file format: $fileExtension"
        return
    }

    # Process vulnerabilities based on detected format
    if ($rawData -is [array]) {
        $vulnerabilities = $rawData
    } elseif ($rawData.PSObject.Properties["vulnerabilities"]) {
        $vulnerabilities = $rawData.vulnerabilities
    } else {
        Write-Host "No vulnerabilities found in report: $ReportPath"
        return
    }

    foreach ($item in $vulnerabilities) {
        # Normalize different fields from different scanners
        $normalizedEntry = @{
            scanner        = $Scanner
            category       = $Category
            id            = $item.id ?? $item.ID ?? $item.vuln_id ?? "N/A"
            name          = $item.name ?? $item.title ?? "Unknown Vulnerability"
            severity      = $item.severity ?? $item.risk ?? $item.impact ?? "Unknown"
            cvss_score    = $item.cvss_score ?? $item.cvss ?? "N/A"
            description   = $item.description ?? $item.details ?? "No description available"
            location      = $item.location ?? $item.file ?? $item.url ?? "N/A"
            recommendation = $item.recommendation ?? $item.fix ?? "No fix available"
        }

        # Add to aggregated results
        $aggregatedResults += $normalizedEntry
    }
}
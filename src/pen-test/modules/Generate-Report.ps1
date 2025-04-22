# Load aggregated JSON data
$reportData = Get-Content -Path "C:\Reports\AggregatedResults.json" | ConvertFrom-Json

# Function to generate remediation suggestions based on standard security policies
function Get-RemediationSuggestion {
    param ($Category)
    switch ($Category) {
        "SAST" { return "Review the affected code and follow secure coding best practices (e.g., OWASP ASVS)." }
        "SCA" { return "Upgrade dependencies to the latest secure versions and check for known vulnerabilities." }
        "DAST" { return "Sanitize inputs, enforce strong authentication, and apply security patches for web vulnerabilities." }
        "SECRETS" { return "Remove hardcoded secrets, rotate credentials, and use a secure vault like Azure Key Vault or HashiCorp Vault." }
        "IAC" { return "Follow Infrastructure-as-Code best practices and apply security policies (e.g., CIS benchmarks)." }
        default { return "Refer to security best practices for remediation steps." }
    }
}

# Enhance the HTML report with remediation suggestions
$htmlContent = @"
<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Penetration Testing Risk Report</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 text-gray-900">
    <div class="container mx-auto p-6">
        <h1 class="text-3xl font-bold text-center mb-6">🛡️ Penetration Testing Risk Report</h1>
        <div class="overflow-x-auto">
            <table class="w-full bg-white shadow-md rounded-lg border border-gray-200">
                <thead>
                    <tr class="bg-gray-800 text-white">
                        <th class="p-3 text-left">ID</th>
                        <th class="p-3 text-left">Category</th>
                        <th class="p-3 text-left">Severity</th>
                        <th class="p-3 text-left">Description</th>
                        <th class="p-3 text-left">Recommendation</th>
                    </tr>
                </thead>
                <tbody>
"@

foreach ($item in $reportData) {
    $remediation = Get-RemediationSuggestion -Category $item.category
    $severityClass = switch ($item.severity) {
        "Critical" { "bg-red-600 text-white" }
        "High" { "bg-orange-500 text-white" }
        "Medium" { "bg-yellow-400" }
        "Low" { "bg-green-400" }
        default { "bg-gray-200" }
    }
    $htmlContent += @"
                    <tr class="border-b border-gray-300">
                        <td class="p-3">$($item.id)</td>
                        <td class="p-3">$($item.category)</td>
                        <td class="p-3 font-bold $severityClass text-center rounded">$($item.severity)</td>
                        <td class="p-3">$($item.description)</td>
                        <td class="p-3">$remediation</td>
                    </tr>
"@
}

$htmlContent += @"
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
"@

$htmlPath = "C:\Reports\PenTest_Risk_Report.html"
$htmlContent | Set-Content -Path $htmlPath -Encoding UTF8
Write-Host "✅ HTML Report with remediation suggestions generated at: $htmlPath"
Start-Process $htmlPath
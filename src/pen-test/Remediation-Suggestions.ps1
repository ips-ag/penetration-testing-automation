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

# Check the test results and post comments in CI/CD
foreach ($item in $reportData) {
    $remediation = Get-RemediationSuggestion -Category $item.category
    $comment = "❗ Security Issue Detected:
    - **ID:** $($item.id)
    - **Category:** $($item.category)
    - **Severity:** $($item.severity)
    - **Description:** $($item.description)
    - **Recommendation:** $remediation"

    if ($env:GITHUB_ACTIONS) {
        # GitHub Actions: Post a comment on the PR
        Write-Host "::warning::$comment"
    }
    elseif ($env:TF_BUILD) {
        # Azure DevOps: Post a comment to the pipeline logs
        Write-Host "##vso[task.logissue type=warning]$comment"
    }
}

Write-Host "✅ CI/CD remediation suggestions posted."

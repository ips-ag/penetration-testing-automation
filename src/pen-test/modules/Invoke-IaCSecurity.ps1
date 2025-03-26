function Invoke-IaCSecurity {
    param (
        [string]$TargetPath = "$PWD",
        [string]$OutputPath = "$PWD"
    )

    try {
        $ResolvedTargetPath = Resolve-Path -Path $TargetPath -ErrorAction Stop
        $ResolvedOutputPath = Resolve-Path -Path $OutputPath -ErrorAction Stop

        if (!(Test-Path -Path $ResolvedOutputPath)) {
            New-Item -ItemType Directory -Path $ResolvedOutputPath -Force | Out-Null
        }

        $ReportFile = "$ResolvedOutputPath\iac-report.txt"

        Write-Host "🚀 Running Checkov (IaC Security Scan) in Docker on: ${ResolvedTargetPath}" -ForegroundColor Cyan
        Write-Host "📁 Saving report to: ${ReportFile}" -ForegroundColor Yellow

        $dockerCmd = "docker run --rm " `
        + "-v `"${ResolvedTargetPath}:/src`" " `
        + "-v `"${ResolvedOutputPath}:/report`" " `
        + "bridgecrew/checkov -d /src --output json " `
        + "--output-file-path /report"

        # Execute the Docker command using the Invoke-DockerCommand function
        .${PSScriptRoot}\Invoke-DockerCommand.ps1 -DockerCommand $dockerCmd

        Write-Host "✅ Checkov scan completed. Report saved to: ${ReportFile}" -ForegroundColor Green
    }
    catch {
        Write-Error "❌ Checkov scan failed: $($_.Exception.Message)"
        exit 1
    }
}
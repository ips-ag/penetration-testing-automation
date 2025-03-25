function Invoke-SecretsScan {
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

        $ReportFile = "/report/secrets-report.json"

        Write-Host "🚀 Running GitLeaks (Secrets Detection) in Docker on: ${ResolvedTargetPath}" -ForegroundColor Cyan
        Write-Host "📁 Saving report to: ${ReportFile}" -ForegroundColor Yellow

        $dockerCmd = "docker run --rm -v `"${ResolvedTargetPath}:/src`" -v `"${ResolvedOutputPath}:/report`" zricethezav/gitleaks detect -s /src -r $ReportFile"

        # Execute the Docker command using the Invoke-DockerCommand function
        .${PSScriptRoot}\Invoke-DockerCommand.ps1 -DockerCommand $dockerCmd

        Write-Host "✅ GitLeaks scan completed. Report saved to: ${ResolvedOutputPath}\secrets-report.json" -ForegroundColor Green
    }
    catch {
        Write-Error "❌ GitLeaks scan failed: $($_.Exception.Message)"
        exit 1
    }
}
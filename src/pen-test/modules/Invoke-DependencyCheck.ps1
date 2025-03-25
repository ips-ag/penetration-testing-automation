function Invoke-DependencyCheck {
    param (
        [string]$TargetPath = "$PWD",
        [string]$OutputPath = "$PWD",
        [securestring]$NVDApiKey
    )

    try {
        $ResolvedTargetPath = Resolve-Path -Path $TargetPath -ErrorAction Stop
        $ResolvedOutputPath = Resolve-Path -Path $OutputPath -ErrorAction Stop

        if (!(Test-Path -Path $ResolvedOutputPath)) {
            New-Item -ItemType Directory -Path $ResolvedOutputPath -Force | Out-Null
        }

        $ReportFile = "/report/dependency-report.html"

        Write-Host "🚀 Running OWASP Dependency-Check (SCA) in Docker on: ${ResolvedTargetPath}" -ForegroundColor Cyan
        Write-Host "📁 Saving report to: ${ReportFile}" -ForegroundColor Yellow

        $dockerCmd = "docker run --rm -v `"${ResolvedTargetPath}:/src`" -v `"${ResolvedOutputPath}:/report`" owasp/dependency-check --scan /src --format HTML --out $ReportFile"

        # Execute the Docker command using the Invoke-DockerCommand function
        .${PSScriptRoot}\Invoke-DockerCommand.ps1 -DockerCommand $dockerCmd

        Write-Host "✅ Dependency-Check scan completed. Report saved to: ${ResolvedOutputPath}\dependency-report.html" -ForegroundColor Green
    }
    catch {
        Write-Error "❌ Dependency-Check scan failed: $($_.Exception.Message)"
        exit 1
    }
    
}

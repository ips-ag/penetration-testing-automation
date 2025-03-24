function Invoke-ZAP {
    param (
        [string]$TargetURL = "http://localhost:5000",
        [string]$OutputPath = "$PWD"
    )
    try {
        if ($TargetURL -notmatch "^https?://") {
            Write-Host "❌ Invalid URL: ${TargetURL}. Please provide a valid HTTP/HTTPS URL." -ForegroundColor Red
            return
        }
    
        $ResolvedOutputPath = Resolve-Path -Path $OutputPath -ErrorAction Stop
    
        if (!(Test-Path -Path $ResolvedOutputPath)) {
            New-Item -ItemType Directory -Path $ResolvedOutputPath -Force | Out-Null
        }
    
        $ReportFile = "/zap/wrk/zap_report.html"
    
        Write-Host "🚀 Running OWASP ZAP (DAST) in Docker on: ${TargetURL}" -ForegroundColor Cyan
        Write-Host "📁 Saving report to: ${ReportFile}" -ForegroundColor Yellow
    
        $dockerCmd = "docker run --rm -v `"${ResolvedOutputPath}:/zap/wrk`" -t ghcr.io/zaproxy/zaproxy:latest zap-full-scan.py -t `"$TargetURL`" -r $ReportFile -a"

        # Execute the Docker command using the Invoke-DockerCommand function
        .${PSScriptRoot}\Invoke-DockerCommand.ps1 -DockerCommand $dockerCmd
    
        Write-Host "✅ OWASP ZAP scan completed. Report saved to: ${ResolvedOutputPath}\zap_report.html" -ForegroundColor Green
    }
    catch {
        Write-Error "❌ OWASP ZAP scan failed: $($_.Exception.Message)"
        exit 1
    }
}

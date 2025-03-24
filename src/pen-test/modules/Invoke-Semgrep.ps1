function Invoke-Semgrep {
    param (
        [string]$TargetPath = "$PWD",
        [string]$Language = "",  
        [string]$OutputPath = "$PWD"
    )

    try {
        $ResolvedTargetPath = Resolve-Path -Path $TargetPath -ErrorAction Stop
        $ResolvedOutputPath = Resolve-Path -Path $OutputPath -ErrorAction Stop

        if (!(Test-Path -Path $ResolvedOutputPath)) {
            New-Item -ItemType Directory -Path $ResolvedOutputPath -Force | Out-Null
        }

        $OutputFile = "/src/semgrep-report.json"

        Write-Host "🚀 Running Semgrep (SAST) in Docker on: ${ResolvedTargetPath}" -ForegroundColor Cyan

        $SemgrepCmd = "semgrep scan --config=auto --json"
        if ($Language -ne "") {
            Write-Host "🔍 Language specified: ${Language}" -ForegroundColor Yellow
            $SemgrepCmd += " --lang=${Language}"
        }
        else {
            Write-Host "🔍 Scanning all languages" -ForegroundColor Yellow
        }

        Write-Host "📁 Saving report to: ${OutputFile}" -ForegroundColor Yellow

        $dockerCmd = "docker run --rm -v `"${ResolvedTargetPath}:/src`" returntocorp/semgrep bash -c `"$SemgrepCmd /src | tee $OutputFile`""
        .${PSScriptRoot}\Invoke-DockerCommand.ps1 -DockerCommand $dockerCmd

        Move-Item -Path "${ResolvedTargetPath}\semgrep-report.json" -Destination "${ResolvedOutputPath}\semgrep-report.json" -Force

        Write-Host "✅ Semgrep scan completed. Report saved to: ${ResolvedOutputPath}\semgrep-report.json" -ForegroundColor Green
    }
    catch {
        Write-Error "❌ Semgrep scan failed: $($_.Exception.Message)"
        exit 1
    }    
}

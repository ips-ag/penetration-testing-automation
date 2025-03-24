. "$PSScriptRoot\Invoke-Semgrep.ps1"
. "$PSScriptRoot\Invoke-DependencyCheck.ps1"
. "$PSScriptRoot\Invoke-ZAP.ps1"

function Invoke-AllScans {
    param (
        [string]$TargetPath = "$PWD",
        [string]$TargetURL = "http://localhost:5000",
        [string]$OutputPath = "$PWD",
        [string]$Language = ""  
    )
    try {
        Write-Host "🚀 Starting all penetration tests..." -ForegroundColor Cyan

        if (!(Test-Path -Path ${OutputPath})) {
            New-Item -ItemType Directory -Path ${OutputPath} -Force | Out-Null
        }

        Write-Host "`n🔍 Running Semgrep (SAST)..." -ForegroundColor Yellow
        Invoke-Semgrep -TargetPath ${TargetPath} -Language ${Language} -OutputPath ${OutputPath}

        Write-Host "`n🔍 Running OWASP Dependency-Check (SCA)..." -ForegroundColor Yellow
        Invoke-DependencyCheck -TargetPath ${TargetPath} -OutputPath ${OutputPath}

        Write-Host "`n🔍 Running OWASP ZAP (DAST)..." -ForegroundColor Yellow
        Invoke-ZAP -TargetURL ${TargetURL} -OutputPath ${OutputPath}

        Write-Host "`n✅ All scans completed! Reports are saved in: ${OutputPath}" -ForegroundColor Green
    }
    catch {
        Write-Error "❌ ll scans failed: $($_.Exception.Message)"
        exit 1
    }    
}

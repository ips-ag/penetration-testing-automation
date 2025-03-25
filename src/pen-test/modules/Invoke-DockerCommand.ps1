param (
    [Parameter(Mandatory = $true)]
    [string]$DockerCommand
)

Write-Host "🚀 Executing Docker command:" -ForegroundColor Cyan
Write-Host $DockerCommand -ForegroundColor Cyan

# Execute the command and capture STDERR and STDOUT
$output = Invoke-Expression $DockerCommand 2>&1
$exitCode = $LASTEXITCODE

# Detect if Docker is stopped
if ($exitCode -eq 127 -or $output -match "docker: command not found") {
    throw "🚨 Critical Error: Docker is not running or not installed! Please start Docker and try again."
}

# Detect Docker-specific errors
if ($exitCode -ne 0) {
    if ($output -match "Cannot connect to the Docker daemon" -or
        $output -match "error during connect" -or
        $output -match "Is the docker daemon running?" -or
        $output -match "dial unix /var/run/docker.sock" -or
        $output -match "Error response from daemon") {
        throw "🚨 Docker Error Detected! Exit code ${exitCode}:`n$output"
    }
    else {
        Write-Host "⚠️ Non-Docker error occurred. Exit code ${exitCode}:`n$output" -ForegroundColor Yellow
    }
}
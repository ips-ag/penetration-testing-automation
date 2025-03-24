param (
    [Parameter(Mandatory = $true)]
    [string]$DockerCommand
)

function Invoke-DockerCommand {
    param(
        [string]$Command
    )
    Write-Host "🚀 Executing Docker command:" -ForegroundColor Cyan
    Write-Host $Command -ForegroundColor Cyan

    # Execute the command and capture STDERR and STDOUT
    $output = Invoke-Expression $Command 2>&1

    # Check if Docker returned a non-zero exit code
    if ($LASTEXITCODE -ne 0) {
        throw "Docker command failed with exit code ${LASTEXITCODE}:`n$output"
    }
}

# Run the Docker command passed to the script
Invoke-DockerCommand -Command $DockerCommand

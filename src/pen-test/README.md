# Pentest-Run.ps1

## Overview
`Pentest-Run.ps1` is a PowerShell script that automates various security scans, including Static Application Security Testing (SAST), Software Composition Analysis (SCA), and Dynamic Application Security Testing (DAST). It integrates multiple security tools to help identify vulnerabilities in source code and web applications.

## Features
- **SAST**: Runs Semgrep to analyze source code for security flaws.
- **SCA**: Uses OWASP Dependency-Check to detect vulnerable dependencies.
- **DAST**: Executes OWASP ZAP to perform dynamic security testing on web applications.
- **Flexible Execution**: Allows running individual scans or all scans at once.
- **Customizable Parameters**: Set target paths, URLs, and output directories.

## Prerequisites
- Windows PowerShell (recommended version 5.1 or later)
- Required security tools installed:
  - [Semgrep](https://semgrep.dev/)
  - [OWASP Dependency-Check](https://jeremylong.github.io/DependencyCheck/)
  - [OWASP ZAP](https://www.zaproxy.org/)
- Ensure the `PenTest` PowerShell module is available in `modules/PenTest.psm1`.

## Usage
### Running the script
```powershell
.\Pentest-Run.ps1 -ScanType <SCAN_TYPE> -TargetPath <TARGET_PATH> -TargetURL <TARGET_URL> -OutputPath <OUTPUT_PATH>
```

### Parameters
| Parameter   | Description                                                        | Default Value          |
|------------|--------------------------------------------------------------------|------------------------|
| `ScanType` | Type of scan to run: `SAST`, `SCA`, `DAST`, or `ALL`.              | `ALL`                  |
| `TargetPath` | Directory path for SAST and SCA scans.                          | Current directory (`$PWD`) |
| `TargetURL` | URL to scan with DAST.                                           | `https://github.com/`  |
| `OutputPath` | Directory where reports will be saved.                          | Current directory (`$PWD`) |

### Example Commands
#### Run all security scans
```powershell
.\Pentest-Run.ps1 -ScanType ALL -TargetPath "C:\Projects\MyApp" -TargetURL "https://myapp.com" -OutputPath "C:\SecurityReports"
```

#### Run only SAST (Static Analysis) scan
```powershell
.\Pentest-Run.ps1 -ScanType SAST -TargetPath "C:\Projects\MyApp" -OutputPath "C:\SecurityReports"
```

#### Run DAST (Dynamic Analysis) scan on a web application
```powershell
.\Pentest-Run.ps1 -ScanType DAST -TargetURL "https://myapp.com" -OutputPath "C:\SecurityReports"
```

## Script Workflow
1. **Checks Output Directory**: Ensures the specified output path exists or creates it.
2. **Loads PenTest Module**: Imports the `PenTest.psm1` module.
3. **Executes the Specified Scan(s)**:
   - Runs Semgrep for SAST.
   - Runs OWASP Dependency-Check for SCA.
   - Runs OWASP ZAP for DAST.
4. **Saves Reports**: The scan results are stored in the specified output directory.

## Troubleshooting
- **PenTest Module Not Found**: Ensure `PenTest.psm1` exists in `modules/` and is correctly referenced in the script.
- **Command Not Recognized**: Ensure Semgrep, OWASP Dependency-Check, and OWASP ZAP are installed and available in your system's PATH.
- **Permission Issues**: Run PowerShell as an administrator if needed.

## License
This project is licensed under the MIT License.

## Contributors
- [Your Name]
- Contributions welcome! Feel free to submit pull requests.

## Acknowledgments
- [OWASP ZAP](https://www.zaproxy.org/)
- [Semgrep](https://semgrep.dev/)
- [OWASP Dependency-Check](https://jeremylong.github.io/DependencyCheck/)


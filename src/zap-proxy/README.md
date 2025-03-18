# OWASP ZAP API Scan Automation

This project automates an **OWASP ZAP API scan** using PowerShell.  
It supports both **local execution with a `.env` file** and **CI/CD execution in Azure DevOps**.

---

## 🚀 Prerequisites

### **1️⃣ Install Required Tools**
Ensure you have the following installed on your system:
- [PowerShell 7+](https://github.com/PowerShell/PowerShell)
- [Docker](https://www.docker.com/)

---

## 🏃 **How to Run the Script**

### **1️⃣ Local Execution (Using `.env` file)**

#### **Step 1: Create a `.env` file**
Create a file named `local.config.env` in the root directory and add the following details:

```ini
CLIENT_ID=my-client-id
CLIENT_SECRET=my-secret
SCOPE=read write
TOKEN_URI=https://example.com/oauth/token
SWAGGER_JSON=https://example.com/swagger.json
WORK_DIR=D:\Zap
```

#### **Step 2: Executing with the env file**
```powershell
./scan_locally.ps1 -envFile "local.config.env"
```

---

### **2️⃣ CI/CD Execution in Azure DevOps**

#### **Step 1: Add Environment Variables to Azure DevOps Pipeline**
In your Azure DevOps pipeline, define the environment variables under `variables`:

```yaml
variables:
  CLIENT_ID: $(client-id)
  CLIENT_SECRET: $(client-secret)
  SCOPE: "read write"
  TOKEN_URI: "https://example.com/oauth/token"
  SWAGGER_JSON: "https://example.com/swagger.json"
  WORK_DIR: "D:\Zap"
```

#### **Step 2: Run the PowerShell Script in Your Pipeline**
Add the following task to your `azure-pipelines.yml` file:

```yaml
- task: PowerShell@2
  displayName: "Run OWASP ZAP API Scan"
  inputs:
    targetType: 'inline'
    script: |
      $secureSecret = ConvertTo-SecureString $env:CLIENT_SECRET -AsPlainText -Force
      ./openapi_scan.ps1 -client_id $env:CLIENT_ID -client_secret $secureSecret -scope $env:SCOPE -tokenUri $env:TOKEN_URI -swaggerJson $env:SWAGGER_JSON -workDir $env:WORK_DIR
```

---

## ⚙ **Configuration Options**
The script accepts the following parameters:

| Parameter         | Description |
|------------------|-------------|
| `-envFile`       | Path to the environment file (for local execution). |
| `-clientId`      | OAuth client ID (can be set via environment variables). |
| `-clientSecret`  | OAuth client secret (can be set via environment variables). |
| `-scope`         | OAuth scope (optional, defaults to `read`). |
| `-tokenUri`      | OAuth token endpoint. |
| `-swaggerJson`   | URL to the Swagger API specification. |
| `-workDir`       | Local working directory for ZAP files. |

---

## 📊 **Interpreting Results**
After execution, ZAP will generate a report in **HTML format** inside the specified `WORK_DIR`. 

### **Example Report Path**
```
D:\Zap\zap_report.html
```

To review scan results:
1. Open the report in a browser.
2. Check for vulnerabilities listed under **Alerts**.
3. Review the **Risk Level** (Low, Medium, High) for detected issues.

---

## 🤝 **Contributing**
Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a feature branch.
3. Commit your changes.
4. Submit a pull request.

---

## 📄 **License**
This project is licensed under the [MIT License](LICENSE).


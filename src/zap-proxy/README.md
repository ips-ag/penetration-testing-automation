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

For API Scan - see [config.api-scan.env](./config.api-scan.env)
```ini
CLIENT_ID=your-client-id
CLIENT_SECRET=your-client-secret
SCOPE=your-scope
TOKEN_URI=https://example.com/oauth/token
TARGET_URL=https://example.com/swagger.json
WORK_DIR=D:\Zap
SCAN_TYPE=API
```
For Baseline/Full Scan - see [config.full-scan.env](config.full-scan.env) and [config.baseline-scan.env](./config.baseline-scan.env)
```ini
TARGET_URL=https://github.com
WORK_DIR=D:\Zap
SCAN_TYPE=Baseline
```

#### **Step 2: Execute the Script Using the `.env` File**
```powershell
./scan_locally.ps1 -envFile "local.config.env"
```

---

### **2️⃣ CI/CD Execution in Azure DevOps**

Refer to the [`azure-pipelines.yml`](./azure-pipelines.yml) file for configuring the scan in your Azure DevOps pipeline.

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
| `-targetUrl`     | URL to the Swagger API specification or target application. |
| `-workDir`       | Local working directory for ZAP files. |
| `-scanType`      | Type of scan (`API`, `Baseline`, or `Full`). |

---

## 📊 **Interpreting Results**
After execution, ZAP will generate a report in **HTML and JSON format** inside the specified `WORK_DIR`. 

### **Example Report Path**
```
D:\Zap\*.(html/json)
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
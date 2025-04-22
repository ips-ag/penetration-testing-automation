param (
    [string]$jsonReport = "threat-report.json",
    [string]$htmlOutput = "threat-report.html"
)

# Read and parse JSON
$threats = Get-Content -Raw -Path $jsonReport | ConvertFrom-Json
$jsonData = $threats | ConvertTo-Json -Depth 10 -Compress  # Ensure JSON is a valid one-liner for JS

# Escape JSON properly for JavaScript
$jsonEscaped = $jsonData -replace '"', '\"'  # Escape double quotes
$jsonEscaped = $jsonEscaped -replace "`r?`n", ""  # Remove newlines

# Write HTML file
$htmlContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OWASP Threat Dragon Report</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .severity-high { background-color: #e53e3e; color: white; padding: 4px 8px; border-radius: 4px; }
        .severity-medium { background-color: #dd6b20; color: white; padding: 4px 8px; border-radius: 4px; }
        .severity-low { background-color: #38a169; color: white; padding: 4px 8px; border-radius: 4px; }
        .dark-mode, .dark-mode tr { background-color: #1a202c; color: white; }
        .dark-mode table { background-color: #2d3748; }
        .dark-mode th, .dark-mode td { border-color: #4a5568; }
        .dark-mode h2 { background-color: dimgrey; }
    </style>
</head>
<body class="p-6">
    <div class="max-w-4xl mx-auto">
        <button class="bg-gray-800 text-white px-4 py-2 rounded mb-4 float-right" onclick="toggleDarkMode()">🌙 Dark Mode</button>
        <h1 class="text-3xl font-bold mb-6">Threat Model Report</h1>
        <button class="bg-green-500 text-white px-4 py-2 rounded mb-4" onclick="downloadJSON()">📥 Download JSON</button>

        <div id="report"></div>
    </div>

    <script>
        const threats = JSON.parse('
'@ + $jsonEscaped;
$htmlContent += @'
');  // Inserted safely
        function toggleCategory(id) {
            document.getElementById(id).classList.toggle("hidden");
        }

        function toggleDarkMode() {
            document.body.classList.toggle("dark-mode");
        }

        function downloadJSON() {
            const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(threats, null, 2));
            const dlAnchorElem = document.createElement('a');
            dlAnchorElem.setAttribute("href", dataStr);
            dlAnchorElem.setAttribute("download", "threat-report.json");
            dlAnchorElem.click();
        }

        function renderReport() {
            const reportDiv = document.getElementById("report");
            const groupedThreats = {};

            threats.forEach(threat => {
                if (!groupedThreats[threat.category]) {
                    groupedThreats[threat.category] = [];
                }
                groupedThreats[threat.category].push(threat);
            });

            let html = "";
            for (const category in groupedThreats) {
                html += `<div class="mb-6">
                            <h2 class="text-xl font-bold bg-blue-200 px-4 py-2 cursor-pointer" onclick="toggleCategory('${category.replace(/\s/g, '')}')">
                                 ${category} ( ${groupedThreats[category].length} threats )
                            </h2>
                            <table id="${category.replace(/\s/g, '')}" class="w-full border-collapse bg-white shadow-md rounded-lg mt-2">
                                <thead>
                                    <tr class="bg-gray-200">
                                        <th class="border p-2">Name</th>
                                        <th class="border p-2">Description</th>
                                        <th class="border p-2">Severity</th>
                                        <th class="border p-2">Mitigation</th>
                                    </tr>
                                </thead>
                                <tbody>`;

                groupedThreats[category].forEach(threat => {
                    let severityClass = threat.severity === "High" ? "severity-high" : threat.severity === "Medium" ? "severity-medium" : "severity-low";
                    html += `
                        <tr class="border">
                            <td class="border p-2">${threat.name}</td>
                            <td class="border p-2">${threat.description}</td>
                            <td class="border p-2 ${severityClass}">${threat.severity}</td>
                            <td class="border p-2">${threat.mitigation}</td>
                        </tr>
                    `;
                });

                html += `</tbody></table></div>`;
            }

            reportDiv.innerHTML = html;
        }

        renderReport();
    </script>
</body>
</html>
'@

# Write the HTML content to file using Set-Content to preserve characters
Set-Content -Path $htmlOutput -Value $htmlContent -Encoding utf8
Write-Output "✅ Threat report generated: $htmlOutput"
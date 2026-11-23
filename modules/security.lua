
-- LSAI Security Scanner
-- Version: 0.1.0
-- Static analysis only. Never executes scanned code.

local Security = {
    Version = "0.1.0",
    LastReport = {},
    TotalScans = 0
}

local patterns = {
    {
        Name = "Dynamic Code Execution",
        Pattern = "loadstring",
        Severity = "High",
        Description = "Dynamic code compilation detected."
    },
    {
        Name = "Remote Code Loading",
        Pattern = "HttpGet",
        Severity = "Warning",
        Description = "Remote content retrieval detected."
    },
    {
        Name = "Request API",
        Pattern = "request",
        Severity = "Warning",
        Description = "Network request reference detected."
    },
    {
        Name = "File Modification",
        Pattern = "writefile",
        Severity = "Warning",
        Description = "File writing reference detected."
    },
    {
        Name = "File Deletion",
        Pattern = "delfile",
        Severity = "Warning",
        Description = "File deletion reference detected."
    },
    {
        Name = "Environment Access",
        Pattern = "getgenv",
        Severity = "Warning",
        Description = "Environment access reference detected."
    },
    {
        Name = "Debug Access",
        Pattern = "debug.",
        Severity = "Warning",
        Description = "Debug library reference detected."
    }
}

function Security:Scan(source)
    if type(source) ~= "string" then
        return false, "Invalid source input."
    end

    local report = {
        Findings = {},
        TotalFindings = 0,
        Status = "Clean",
        ScannedCharacters = #source
    }

    local normalizedSource = string.lower(source)

    for _, item in ipairs(patterns) do
        local pattern = string.lower(item.Pattern)

        if string.find(normalizedSource, pattern, 1, true) then
            table.insert(report.Findings, {
                Name = item.Name,
                Severity = item.Severity,
                Description = item.Description
            })

            report.TotalFindings =
                report.TotalFindings + 1
        end
    end

    if report.TotalFindings > 0 then
        report.Status = "Review Required"
    end

    self.TotalScans = self.TotalScans + 1
    self.LastReport = report

    return true, report
end

function Security:GetLastReport()
    return self.LastReport
end

function Security:GetStatistics()
    return {
        TotalScans = self.TotalScans,
        LastFindings = self.LastReport.TotalFindings or 0
    }
end

function Security:ClearReport()
    self.LastReport = {}
end

return Security



-- LSAI - Main Entry Point
-- Version: 0.2.0
-- Default language: English
-- Safe static Lua analyzer

local LSAI = {
    Name = "LSAI",
    Version = "0.2.0",
    Language = "en",
    Status = "Starting",
    Modules = {},
    Diagnostics = {},
    ScanResults = {}
}

local function log(message)
    if type(warn) == "function" then
        warn("[LSAI] " .. tostring(message))
    else
        print("[LSAI] " .. tostring(message))
    end
end

-- Static analysis rules.
-- Matches are warnings, not proof of malicious behavior.

local rules = {
    {
        name = "Dynamic code loading",
        pattern = "loadstring",
        severity = "Review"
    },
    {
        name = "HTTP request",
        pattern = "httpget",
        severity = "Review"
    },
    {
        name = "Request function",
        pattern = "request",
        severity = "Review"
    },
    {
        name = "File writing",
        pattern = "writefile",
        severity = "Review"
    },
    {
        name = "File deletion",
        pattern = "delfile",
        severity = "Review"
    },
    {
        name = "Environment access",
        pattern = "getgenv",
        severity = "Review"
    },
    {
        name = "Function hooking",
        pattern = "hookfunction",
        severity = "Review"
    },
    {
        name = "Metatable access",
        pattern = "getrawmetatable",
        severity = "Review"
    }
}

function LSAI:Diagnostic(name, status, message)
    self.Diagnostics[name] = {
        Status = status,
        Message = message or ""
    }

    log(name .. ": " .. status)

    if message then
        log(message)
    end
end

-- Scan source as TEXT only.
-- Never compiles or executes the inspected code.

function LSAI:ScanText(source)
    if type(source) ~= "string" then
        return false, "Input must be a string"
    end

    local findings = {}
    local lineNumber = 0

    for line in (source .. "\n"):gmatch("(.-)\n") do
        lineNumber = lineNumber + 1

        local lowered = line:lower()

        for _, rule in ipairs(rules) do
            if lowered:find(rule.pattern, 1, true) then
                table.insert(findings, {
                    Rule = rule.name,
                    Severity = rule.severity,
                    Line = lineNumber
                })
            end
        end
    end

    self.ScanResults = findings

    return true, findings
end

function LSAI:GetReport()
    local report = {
        "========== LSAI REPORT ==========",
        "Version: " .. self.Version,
        "Status: " .. self.Status,
        "Findings: " .. tostring(#self.ScanResults)
    }

    for _, finding in ipairs(self.ScanResults) do
        table.insert(
            report,
            "["
                .. finding.Severity
                .. "] "
                .. finding.Rule
                .. " - Line "
                .. finding.Line
        )
    end

    table.insert(report, "=================================")

    return table.concat(report, "\n")
end

function LSAI:Start()
    log("Starting LSAI...")
    log("Version: " .. self.Version)

    self:Diagnostic(
        "Static Scanner",
        "Ready",
        "Text analysis enabled"
    )

    self:Diagnostic(
        "Remote Execution",
        "Disabled",
        "Unverified code is never executed"
    )

    self.Status = "Ready"

    log("LSAI started successfully")
    log("Status: " .. self.Status)

    return true
end

LSAI:Start()

return LSAI

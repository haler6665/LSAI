
--[[
    LSAI Security Module
    Version: 0.1.0

    Static Lua source analyzer.
    Does not execute scanned code.
]]

local Security = {}

Security.Name = "LSAI Security"
Security.Version = "0.1.0"
Security.Status = "Ready"

-- Risk levels
Security.Levels = {
    NONE = "NONE",
    LOW = "LOW",
    MEDIUM = "MEDIUM",
    HIGH = "HIGH",
    CRITICAL = "CRITICAL"
}

-- Detection database
local Rules = {
    {
        id = "D001",
        name = "Dynamic code loading",
        patterns = {
            "loadstring",
            "load%s*%("
        },
        severity = 20,
        description = "Possible dynamic code execution."
    },
    {
        id = "D002",
        name = "Remote source access",
        patterns = {
            "HttpGet",
            "HttpGetAsync",
            "request%s*%(",
            "http_request"
        },
        severity = 15,
        description = "Possible external network communication."
    },
    {
        id = "D003",
        name = "File modification",
        patterns = {
            "writefile",
            "appendfile",
            "delfile",
            "makefolder"
        },
        severity = 15,
        description = "Possible local file modification."
    },
    {
        id = "D004",
        name = "File reading",
        patterns = {
            "readfile",
            "listfiles",
            "isfile",
            "isfolder"
        },
        severity = 8,
        description = "Possible local file access."
    },
    {
        id = "D005",
        name = "Environment access",
        patterns = {
            "getgenv",
            "getrenv",
            "getfenv",
            "setfenv"
        },
        severity = 12,
        description = "Possible access to execution environment."
    },
    {
        id = "D006",
        name = "Obfuscation indicators",
        patterns = {
            "string%.char",
            "string%.byte",
            "table%.concat",
            "bit32%.bxor"
        },
        severity = 8,
        description = "Possible string construction or code obfuscation."
    },
    {
        id = "D007",
        name = "Suspicious environment functions",
        patterns = {
            "gethui",
            "identifyexecutor",
            "checkcaller"
        },
        severity = 10,
        description = "Possible executor-specific environment usage."
    }
}

-- Count occurrences
local function CountMatches(source, pattern)
    local count = 0
    local position = 1

    while true do
        local startIndex, endIndex =
            source:find(pattern, position)

        if not startIndex then
            break
        end

        count = count + 1
        position = endIndex + 1
    end

    return count
end

-- Find matching line numbers
local function FindLines(source, pattern)
    local lines = {}
    local lineNumber = 0

    for line in (source .. "\n"):gmatch("(.-)\n") do
        lineNumber = lineNumber + 1

        if line:find(pattern) then
            table.insert(lines, lineNumber)
        end
    end

    return lines
end

-- Risk calculation
local function GetLevel(score)
    if score >= 80 then
        return Security.Levels.CRITICAL
    elseif score >= 55 then
        return Security.Levels.HIGH
    elseif score >= 30 then
        return Security.Levels.MEDIUM
    elseif score > 0 then
        return Security.Levels.LOW
    end

    return Security.Levels.NONE
end

-- Main scan function
function Security.Scan(source)
    if type(source) ~= "string" then
        return nil, "Source must be a string."
    end

    if #source > 1000000 then
        return nil, "Source is too large."
    end

    local results = {
        success = true,
        version = Security.Version,
        findings = {},
        score = 0,
        level = Security.Levels.NONE,
        scannedBytes = #source
    }

    local totalWeight = 0

    for _, rule in ipairs(Rules) do
        for _, pattern in ipairs(rule.patterns) do
            local count = CountMatches(source, pattern)

            if count > 0 then
                local finding = {
                    id = rule.id,
                    name = rule.name,
                    description = rule.description,
                    severity = rule.severity,
                    count = count,
                    lines = FindLines(source, pattern)
                }

                table.insert(results.findings, finding)

                totalWeight = totalWeight +
                    math.min(rule.severity * count, rule.severity * 3)

                break
            end
        end
    end

    results.score = math.min(totalWeight, 100)
    results.level = GetLevel(results.score)
    results.findingCount = #results.findings

    return results
end

-- Get available rules
function Security.GetRules()
    local copy = {}

    for index, rule in ipairs(Rules) do
        copy[index] = {
            id = rule.id,
            name = rule.name,
            severity = rule.severity,
            description = rule.description
        }
    end

    return copy
end

-- Format report
function Security.FormatReport(results)
    if type(results) ~= "table" then
        return "Invalid scan result."
    end

    local output = {
        "LSAI SECURITY REPORT",
        "Version: " .. Security.Version,
        "Risk: " .. results.level,
        "Score: " .. results.score .. "/100",
        "Findings: " .. results.findingCount,
        "Scanned bytes: " .. results.scannedBytes,
        "-------------------------"
    }

    for _, finding in ipairs(results.findings) do
        table.insert(output, finding.id .. " - " .. finding.name)
        table.insert(output, finding.description)
        table.insert(output, "Occurrences: " .. finding.count)
        table.insert(output, "-------------------------")
    end

    if results.findingCount == 0 then
        table.insert(output, "No known indicators detected.")
    end

    return table.concat(output, "\n")
end

return Security

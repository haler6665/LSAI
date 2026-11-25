
--[[
    LSAI Security Module
    Version: 0.5.0

    Static Lua source analyzer.
    Does not execute scanned code.
]]

local Security = {}

Security.Name = "LSAI Security"
Security.Version = "0.5.0"
Security.Status = "Ready"

Security.Levels = {
    NONE = "NONE",
    LOW = "LOW",
    MEDIUM = "MEDIUM",
    HIGH = "HIGH",
    CRITICAL = "CRITICAL"
}

local MAX_SOURCE_SIZE = 1000000
local MAX_FINDINGS = 100

-- Detection rules
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
        description = "Possible string construction or obfuscation."
    },
    {
        id = "D007",
        name = "Executor-specific functions",
        patterns = {
            "gethui",
            "identifyexecutor",
            "checkcaller"
        },
        severity = 10,
        description = "Possible executor-specific environment usage."
    }
}

local function CopyTable(source)
    local result = {}

    for key, value in pairs(source) do
        if type(value) == "table" then
            result[key] = CopyTable(value)
        else
            result[key] = value
        end
    end

    return result
end

local function CountMatches(source, pattern)
    local count = 0
    local position = 1

    while position <= #source do
        local startIndex, endIndex = source:find(pattern, position)

        if not startIndex then
            break
        end

        count = count + 1
        position = endIndex + 1

        -- Avoid infinite loops on empty matches.
        if endIndex < startIndex then
            position = startIndex + 1
        end
    end

    return count
end

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

local function SafePattern(pattern)
    if type(pattern) ~= "string" then
        return false
    end

    local ok = pcall(function()
        ("test"):find(pattern)
    end)

    return ok
end

function Security.Scan(source)
    if type(source) ~= "string" then
        return nil, "Source must be a string."
    end

    if #source > MAX_SOURCE_SIZE then
        return nil, "Source is too large."
    end

    local results = {
        success = true,
        version = Security.Version,
        findings = {},
        score = 0,
        level = Security.Levels.NONE,
        scannedBytes = #source,
        findingCount = 0,
        warnings = {}
    }

    local totalWeight = 0

    for _, rule in ipairs(Rules) do
        local totalCount = 0
        local matchedLines = {}
        local seenLines = {}

        for _, pattern in ipairs(rule.patterns) do
            if SafePattern(pattern) then
                local count = CountMatches(source, pattern)
                totalCount = totalCount + count

                local lines = FindLines(source, pattern)

                for _, lineNumber in ipairs(lines) do
                    if not seenLines[lineNumber] then
                        seenLines[lineNumber] = true
                        table.insert(matchedLines, lineNumber)
                    end
                end
            else
                table.insert(
                    results.warnings,
                    "Invalid detection pattern in rule " .. rule.id
                )
            end
        end

        if totalCount > 0 then
            table.sort(matchedLines)

            local finding = {
                id = rule.id,
                name = rule.name,
                description = rule.description,
                severity = rule.severity,
                count = totalCount,
                lines = matchedLines
            }

            if #results.findings < MAX_FINDINGS then
                table.insert(results.findings, finding)
            end

            totalWeight = totalWeight +
                math.min(rule.severity * totalCount, rule.severity * 3)
        end
    end

    results.score = math.min(totalWeight, 100)
    results.level = GetLevel(results.score)
    results.findingCount = #results.findings

    return results
end

function Security.GetRules()
    local result = {}

    for index, rule in ipairs(Rules) do
        result[index] = {
            id = rule.id,
            name = rule.name,
            severity = rule.severity,
            description = rule.description,
            patterns = CopyTable(rule.patterns)
        }
    end

    return result
end

function Security.GetLevel(score)
    if type(score) ~= "number" then
        return nil
    end

    return GetLevel(math.max(0, math.min(score, 100)))
end

function Security.FormatReport(results)
    if type(results) ~= "table" then
        return "Invalid scan result."
    end

    if type(results.findings) ~= "table"
        or type(results.score) ~= "number"
        or type(results.level) ~= "string" then
        return "Invalid scan result."
    end

    local output = {
        "LSAI SECURITY REPORT",
        "Version: " .. Security.Version,
        "Risk: " .. results.level,
        "Score: " .. results.score .. "/100",
        "Findings: " .. tostring(results.findingCount or #results.findings),
        "Scanned bytes: " .. tostring(results.scannedBytes or 0),
        "-------------------------"
    }

    for _, finding in ipairs(results.findings) do
        if type(finding) == "table" then
            table.insert(
                output,
                tostring(finding.id) .. " - " .. tostring(finding.name)
            )

            table.insert(output, tostring(finding.description))
            table.insert(output, "Occurrences: " .. tostring(finding.count))

            if type(finding.lines) == "table" and #finding.lines > 0 then
                table.insert(
                    output,
                    "Lines: " .. table.concat(finding.lines, ", ")
                )
            end

            table.insert(output, "-------------------------")
        end
    end

    if #results.findings == 0 then
        table.insert(output, "No known indicators detected.")
    end

    if type(results.warnings) == "table" then
        for _, warning in ipairs(results.warnings) do
            table.insert(output, "Warning: " .. tostring(warning))
        end
    end

    table.insert(
        output,
        "Note: Static analysis cannot guarantee that source code is safe."
    )

    return table.concat(output, "\n")
end

function Security.GetInfo()
    return {
        Name = Security.Name,
        Version = Security.Version,
        Status = Security.Status,
        RuleCount = #Rules,
        MaxSourceSize = MAX_SOURCE_SIZE,
        MaxFindings = MAX_FINDINGS,
        ExecutesCode = false
    }
end

return Security

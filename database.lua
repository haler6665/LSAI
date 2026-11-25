
--[[
    LSAI Database
    Version: 0.4.0
    Runtime: Standard Lua
    Storage: In-Memory
]]

local Database = {
    Version = "0.4.0",

    Settings = {
        Language = "en",
        Theme = "Dark",
        Animations = true,
        Notifications = true
    },

    Statistics = {
        TotalScans = 0,
        CleanScans = 0,
        WarningScans = 0,
        HighRiskScans = 0
    },

    History = {},
    MaxHistory = 100
}

local function copyTable(source)
    local result = {}

    for key, value in pairs(source) do
        if type(value) == "table" then
            result[key] = copyTable(value)
        else
            result[key] = value
        end
    end

    return result
end

function Database.GetSetting(key)
    return Database.Settings[key]
end

function Database.SetSetting(key, value)
    if Database.Settings[key] == nil then
        return false, "Unknown setting"
    end

    local expectedType = type(Database.Settings[key])

    if type(value) ~= expectedType then
        return false, "Invalid setting type"
    end

    Database.Settings[key] = value

    return true
end

function Database.GetSettings()
    return copyTable(Database.Settings)
end

function Database.AddScan(result)
    if type(result) ~= "table" then
        return false, "Invalid scan result"
    end

    local level = tostring(result.level or result.Level or "UNKNOWN")
    local entry = {
        Level = level,
        Score = tonumber(result.score or result.Score) or 0,
        Findings = tonumber(result.count or result.Count) or 0,
        Timestamp = os.time()
    }

    Database.Statistics.TotalScans =
        Database.Statistics.TotalScans + 1

    if level == "NONE" then
        Database.Statistics.CleanScans =
            Database.Statistics.CleanScans + 1
    elseif level == "LOW" or level == "MEDIUM" then
        Database.Statistics.WarningScans =
            Database.Statistics.WarningScans + 1
    elseif level == "HIGH" or level == "CRITICAL" then
        Database.Statistics.HighRiskScans =
            Database.Statistics.HighRiskScans + 1
    end

    table.insert(Database.History, 1, entry)

    while #Database.History > Database.MaxHistory do
        table.remove(Database.History)
    end

    return true
end

function Database.GetHistory()
    return copyTable(Database.History)
end

function Database.GetStatistics()
    return copyTable(Database.Statistics)
end

function Database.ClearHistory()
    Database.History = {}

    Database.Statistics = {
        TotalScans = 0,
        CleanScans = 0,
        WarningScans = 0,
        HighRiskScans = 0
    }

    return true
end

function Database.GetInfo()
    return {
        Version = Database.Version,
        Storage = "In-Memory",
        HistoryCount = #Database.History,
        MaxHistory = Database.MaxHistory
    }
end

return Database

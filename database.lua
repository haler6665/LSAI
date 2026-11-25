
--[[
    LSAI Database
    Version: 0.5.0

    In-memory storage:
    - Settings
    - Scan history
    - Statistics

    This module does not access files or the network.
]]

local Database = {
    Name = "LSAI Database",
    Version = "0.5.0",
    Initialized = false
}

local DEFAULT_SETTINGS = {
    Language = "en",
    Theme = "Dark",
    Animations = true,
    Notifications = true,
    AutoScan = false,
    ScanLevel = "Normal"
}

local settings = {}
local history = {}
local statistics = {
    TotalScans = 0,
    Safe = 0,
    Warnings = 0,
    Dangerous = 0
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

function Database.Initialize()
    settings = copyTable(DEFAULT_SETTINGS)
    history = {}

    statistics = {
        TotalScans = 0,
        Safe = 0,
        Warnings = 0,
        Dangerous = 0
    }

    Database.Initialized = true
    return true
end

function Database.GetSetting(key)
    if type(key) ~= "string" then
        return nil
    end

    return settings[key]
end

function Database.SetSetting(key, value)
    if type(key) ~= "string" or key == "" then
        return false, "Invalid setting key"
    end

    local defaultValue = DEFAULT_SETTINGS[key]

    if defaultValue == nil then
        return false, "Unknown setting"
    end

    if type(value) ~= type(defaultValue) then
        return false, "Invalid setting value type"
    end

    settings[key] = value
    return true
end

function Database.GetSettings()
    return copyTable(settings)
end

function Database.ResetSettings()
    settings = copyTable(DEFAULT_SETTINGS)
    return true
end

function Database.AddScan(result)
    if type(result) ~= "table" then
        return false, "Invalid scan result"
    end

    local status = result.Status

    if status ~= "Safe"
        and status ~= "Warning"
        and status ~= "Dangerous" then
        return false, "Invalid scan status"
    end

    local entry = {
        Status = status,
        Score = tonumber(result.Score) or 0,
        Timestamp = os.time()
    }

    table.insert(history, 1, entry)
    statistics.TotalScans = statistics.TotalScans + 1

    if status == "Safe" then
        statistics.Safe = statistics.Safe + 1
    elseif status == "Warning" then
        statistics.Warnings = statistics.Warnings + 1
    else
        statistics.Dangerous = statistics.Dangerous + 1
    end

    return true
end

function Database.GetHistory(limit)
    limit = tonumber(limit) or #history
    limit = math.max(0, math.floor(limit))

    local result = {}

    for index = 1, math.min(limit, #history) do
        result[index] = copyTable(history[index])
    end

    return result
end

function Database.ClearHistory()
    history = {}
    return true
end

function Database.GetStatistics()
    return copyTable(statistics)
end

function Database.GetInfo()
    return {
        Name = Database.Name,
        Version = Database.Version,
        Initialized = Database.Initialized,
        HistoryCount = #history,
        Storage = "Memory only"
    }
end

Database.Initialize()

return Database

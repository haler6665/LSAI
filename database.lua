
-- LSAI Database
-- Version: 0.1.0

local Database = {
    Version = "0.1.0",
    Language = "en",

    Modules = {
        security = true,
        instructions = true,
        device = true,
        interface = true,
        settings = true,
        macros = true
    },

    Settings = {
        Theme = "Dark",
        WeakPerformanceMode = true,
        Notifications = true,
        AutoScan = false
    },

    Statistics = {
        TotalScans = 0,
        DetectedIssues = 0
    }
}

function Database:Get(key)
    return self.Settings[key]
end

function Database:Set(key, value)
    if self.Settings[key] == nil then
        return false
    end

    self.Settings[key] = value
    return true
end

function Database:GetModuleStatus(name)
    return self.Modules[name] == true
end

function Database:SetModuleStatus(name, enabled)
    if self.Modules[name] == nil then
        return false
    end

    self.Modules[name] = enabled == true
    return true
end

function Database:RecordScan(issues)
    self.Statistics.TotalScans =
        self.Statistics.TotalScans + 1

    self.Statistics.DetectedIssues =
        self.Statistics.DetectedIssues + (issues or 0)
end

function Database:GetStatistics()
    return self.Statistics
end

return Database


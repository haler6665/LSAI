
-- LSAI Settings
-- Version: 0.1.0

local Settings = {
    Version = "0.1.0",

    Values = {
        Language = "en",
        Theme = "Dark",
        WeakPerformanceMode = true,
        Notifications = true,
        AutoScan = false,
        SoundEffects = true
    }
}

local allowedValues = {
    Language = {
        en = true,
        ru = true
    },

    Theme = {
        Dark = true,
        Light = true
    }
}

function Settings:Get(key)
    return self.Values[key]
end

function Settings:Set(key, value)
    if self.Values[key] == nil then
        return false, "Unknown setting."
    end

    if key == "Language" or key == "Theme" then
        if not allowedValues[key][value] then
            return false, "Invalid value."
        end
    elseif type(self.Values[key]) == "boolean" then
        if type(value) ~= "boolean" then
            return false, "Expected boolean."
        end
    else
        return false, "Unsupported setting."
    end

    self.Values[key] = value
    return true
end

function Settings:GetAll()
    local result = {}

    for key, value in pairs(self.Values) do
        result[key] = value
    end

    return result
end

function Settings:Reset()
    self.Values = {
        Language = "en",
        Theme = "Dark",
        WeakPerformanceMode = true,
        Notifications = true,
        AutoScan = false,
        SoundEffects = true
    }

    return true
end

return Settings


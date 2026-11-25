
-- LSAI Settings Module
-- Version: 0.4.0

local Settings = {
    Version = "0.4.0",
    Status = "Ready"
}

local Database
local Localization
local LanguageDatabase

local Defaults = {
    Language = "en",
    Theme = "Dark",
    Animations = true,
    Notifications = true,
    AutoScan = false,
    ScanLevel = "Advanced"
}

local AllowedThemes = {
    Dark = true,
    Light = true
}

local AllowedScanLevels = {
    Basic = true,
    Advanced = true,
    Deep = true
}

function Settings.Initialize(dependencies)
    dependencies = dependencies or {}

    Database = dependencies.Database
    Localization = dependencies.Localization
    LanguageDatabase = dependencies.LanguageDatabase

    if not Database then
        Settings.Status = "Error"
        return false, "Database module is required"
    end

    for key, value in pairs(Defaults) do
        if Database.GetSetting(key) == nil then
            Database.SetSetting(key, value)
        end
    end

    Settings.Status = "Ready"
    return true
end

function Settings.Get(key)
    if not Database then
        return nil
    end

    return Database.GetSetting(key)
end

function Settings.GetAll()
    if not Database then
        return nil
    end

    local result = {}

    for key, defaultValue in pairs(Defaults) do
        local value = Database.GetSetting(key)

        if value == nil then
            value = defaultValue
        end

        result[key] = value
    end

    return result
end

function Settings.SetLanguage(code)
    if not Database then
        return false, "Settings are not initialized"
    end

    if type(code) ~= "string" then
        return false, "Invalid language code"
    end

    if LanguageDatabase then
        local language = LanguageDatabase.Get(code)

        if not language then
            return false, "Language is not in the language database"
        end
    end

    local translationCode = code

    if Localization and not Localization.HasLanguage(translationCode) then
        local baseCode = code:match("^([^-]+)")

        if baseCode and Localization.HasLanguage(baseCode) then
            translationCode = baseCode
        else
            translationCode = "en"
        end
    end

    if Localization then
        local success = Localization.SetLanguage(translationCode)

        if not success then
            return false, "Could not change interface language"
        end
    end

    Database.SetSetting("Language", code)

    return true, {
        SelectedLanguage = code,
        InterfaceLanguage = translationCode
    }
end

function Settings.SetTheme(theme)
    if not AllowedThemes[theme] then
        return false, "Unsupported theme"
    end

    Database.SetSetting("Theme", theme)
    return true
end

function Settings.SetAnimations(enabled)
    if type(enabled) ~= "boolean" then
        return false, "Expected a boolean value"
    end

    Database.SetSetting("Animations", enabled)
    return true
end

function Settings.SetNotifications(enabled)
    if type(enabled) ~= "boolean" then
        return false, "Expected a boolean value"
    end

    Database.SetSetting("Notifications", enabled)
    return true
end

function Settings.SetAutoScan(enabled)
    if type(enabled) ~= "boolean" then
        return false, "Expected a boolean value"
    end

    Database.SetSetting("AutoScan", enabled)
    return true
end

function Settings.SetScanLevel(level)
    if not AllowedScanLevels[level] then
        return false, "Unsupported scan level"
    end

    Database.SetSetting("ScanLevel", level)
    return true
end

function Settings.Reset()
    if not Database then
        return false, "Settings are not initialized"
    end

    for key, value in pairs(Defaults) do
        Database.SetSetting(key, value)
    end

    if Localization then
        Localization.SetLanguage(Defaults.Language)
    end

    return true
end

function Settings.GetInfo()
    return {
        Name = "Settings",
        Version = Settings.Version,
        Status = Settings.Status,
        Settings = Settings.GetAll()
    }
end

return Settings

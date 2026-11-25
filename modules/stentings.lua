--[[
    LSAI Settings Module
    Version: 0.5.0
    Runtime: Standard Lua

    Manages application settings through Database.
]]

local Settings = {
    Name = "LSAI Settings Module",
    Version = "0.5.0",
    Status = "Not initialized"
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

local function isInitialized()
    return type(Database) == "table"
        and type(Database.GetSetting) == "function"
        and type(Database.SetSetting) == "function"
end

local function validBoolean(value)
    return type(value) == "boolean"
end

function Settings.Initialize(dependencies)
    dependencies = dependencies or {}

    if type(dependencies) ~= "table" then
        Settings.Status = "Error"
        return false, "Invalid dependencies"
    end

    Database = dependencies.Database
    Localization = dependencies.Localization
    LanguageDatabase = dependencies.LanguageDatabase

    if not isInitialized() then
        Settings.Status = "Error"
        return false, "Valid Database module is required"
    end

    for key, value in pairs(Defaults) do
        if Database.GetSetting(key) == nil then
            local success = Database.SetSetting(key, value)

            if not success then
                Settings.Status = "Error"
                return false, "Could not initialize setting: " .. key
            end
        end
    end

    Settings.Status = "Ready"
    return true
end

function Settings.Get(key)
    if not isInitialized() then
        return nil
    end

    if type(key) ~= "string" or Defaults[key] == nil then
        return nil
    end

    local value = Database.GetSetting(key)

    if value == nil then
        return Defaults[key]
    end

    return value
end

function Settings.GetAll()
    if not isInitialized() then
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
    if not isInitialized() then
        return false, "Settings are not initialized"
    end

    if type(code) ~= "string" or code == "" then
        return false, "Invalid language code"
    end

    if LanguageDatabase then
        if type(LanguageDatabase.Get) ~= "function"
            or not LanguageDatabase.Get(code) then
            return false, "Language is not in the language database"
        end
    end

    local translationCode = code

    if Localization then
        if type(Localization.HasLanguage) ~= "function"
            or type(Localization.SetLanguage) ~= "function" then
            return false, "Invalid Localization module"
        end

        if not Localization.HasLanguage(translationCode) then
            local baseCode = code:match("^([^-]+)")

            if baseCode and Localization.HasLanguage(baseCode) then
                translationCode = baseCode
            else
                translationCode = "en"
            end
        end

        local success = Localization.SetLanguage(translationCode)

        if not success then
            return false, "Could not change interface language"
        end
    end

    local success = Database.SetSetting("Language", code)

    if not success then
        return false, "Could not save language setting"
    end

    return true, {
        SelectedLanguage = code,
        InterfaceLanguage = translationCode
    }
end

function Settings.SetTheme(theme)
    if not isInitialized() then
        return false, "Settings are not initialized"
    end

    if type(theme) ~= "string" or not AllowedThemes[theme] then
        return false, "Unsupported theme"
    end

    return Database.SetSetting("Theme", theme)
end

function Settings.SetAnimations(enabled)
    if not isInitialized() then
        return false, "Settings are not initialized"
    end

    if not validBoolean(enabled) then
        return false, "Expected a boolean value"
    end

    return Database.SetSetting("Animations", enabled)
end

function Settings.SetNotifications(enabled)
    if not isInitialized() then
        return false, "Settings are not initialized"
    end

    if not validBoolean(enabled) then
        return false, "Expected a boolean value"
    end

    return Database.SetSetting("Notifications", enabled)
end

function Settings.SetAutoScan(enabled)
    if not isInitialized() then
        return false, "Settings are not initialized"
    end

    if not validBoolean(enabled) then
        return false, "Expected a boolean value"
    end

    return Database.SetSetting("AutoScan", enabled)
end

function Settings.SetScanLevel(level)
    if not isInitialized() then
        return false, "Settings are not initialized"
    end

    if type(level) ~= "string" or not AllowedScanLevels[level] then
        return false, "Unsupported scan level"
    end

    return Database.SetSetting("ScanLevel", level)
end

function Settings.Set(key, value)
    if not isInitialized() then
        return false, "Settings are not initialized"
    end

    if key == "Language" then
        return Settings.SetLanguage(value)
    elseif key == "Theme" then
        return Settings.SetTheme(value)
    elseif key == "Animations" then
        return Settings.SetAnimations(value)
    elseif key == "Notifications" then
        return Settings.SetNotifications(value)
    elseif key == "AutoScan" then
        return Settings.SetAutoScan(value)
    elseif key == "ScanLevel" then
        return Settings.SetScanLevel(value)
    end

    return false, "Unknown setting"
end

function Settings.Reset()
    if not isInitialized() then
        return false, "Settings are not initialized"
    end

    for key, value in pairs(Defaults) do
        local success = Database.SetSetting(key, value)

        if not success then
            return false, "Could not reset setting: " .. key
        end
    end

    if Localization then
        local success = Localization.SetLanguage(Defaults.Language)

        if not success then
            return false, "Could not reset interface language"
        end
    end

    return true
end

function Settings.GetDefaults()
    local result = {}

    for key, value in pairs(Defaults) do
        result[key] = value
    end

    return result
end

function Settings.GetInfo()
    return {
        Name = Settings.Name,
        Version = Settings.Version,
        Status = Settings.Status,
        Settings = Settings.GetAll()
    }
end

return Settings


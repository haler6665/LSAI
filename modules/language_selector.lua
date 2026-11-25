
--[[
    LSAI Language Selector
    Version: 0.5.0
    Runtime: Standard Lua

    Features:
    - Language selection
    - Language search
    - Regional language support
    - Translation availability checks
    - Alphabetical grouping
    - Safe dependency handling
]]

local Selector = {
    Name = "LSAI Language Selector",
    Version = "0.5.0",
    Status = "Not initialized",

    SelectedLanguage = nil,
    SearchQuery = "",
    Languages = {},
    Confirmed = false
}

local LanguageDatabase = nil
local Localization = nil

local function normalizeCode(code)
    if type(code) ~= "string" then
        return nil
    end

    code = string.lower(code)
    code = string.gsub(code, "_", "-")

    return code
end

local function isAvailable(code)
    if not Localization then
        return false
    end

    if type(Localization.HasLanguage) ~= "function" then
        return false
    end

    local success, result = pcall(
        Localization.HasLanguage,
        code
    )

    return success and result == true
end

function Selector.Initialize(database, localization)
    if type(database) ~= "table"
    or type(localization) ~= "table" then
        return false, "Invalid dependencies"
    end

    if type(database.GetAll) ~= "function"
    or type(database.Search) ~= "function"
    or type(database.Get) ~= "function"
    or type(localization.SetLanguage) ~= "function"
    or type(localization.HasLanguage) ~= "function" then
        return false, "Required methods are missing"
    end

    local success, languages = pcall(database.GetAll)

    if not success or type(languages) ~= "table" then
        return false, "Could not load languages"
    end

    LanguageDatabase = database
    Localization = localization

    Selector.Languages = languages
    Selector.SelectedLanguage = nil
    Selector.SearchQuery = ""
    Selector.Confirmed = false
    Selector.Status = "Ready"

    return true
end

function Selector.GetLanguages()
    if not LanguageDatabase then
        return {}
    end

    local success, result

    if Selector.SearchQuery ~= "" then
        success, result = pcall(
            LanguageDatabase.Search,
            Selector.SearchQuery
        )
    else
        success, result = pcall(
            LanguageDatabase.GetAll
        )
    end

    if not success or type(result) ~= "table" then
        return {}
    end

    return result
end

function Selector.Search(query)
    if not LanguageDatabase then
        return {}
    end

    Selector.SearchQuery = tostring(query or "")

    return Selector.GetLanguages()
end

function Selector.ClearSearch()
    Selector.SearchQuery = ""

    return Selector.GetLanguages()
end

function Selector.Select(code)
    if not LanguageDatabase or not Localization then
        return false, "Selector is not initialized"
    end

    local normalized = normalizeCode(code)

    if not normalized then
        return false, "Invalid language code"
    end

    local success, language = pcall(
        LanguageDatabase.Get,
        normalized
    )

    if not success or type(language) ~= "table" then
        return false, "Language not found"
    end

    local available = isAvailable(normalized)

    if not available then
        available = isAvailable(language.BaseLanguage)
    end

    if not available then
        return false, "Translation is not available"
    end

    Selector.SelectedLanguage = language.Code
    Selector.Confirmed = false

    return true
end

function Selector.Confirm()
    if not LanguageDatabase or not Localization then
        return false, "Selector is not initialized"
    end

    if not Selector.SelectedLanguage then
        return false, "No language selected"
    end

    local success, language = pcall(
        LanguageDatabase.Get,
        Selector.SelectedLanguage
    )

    if not success or type(language) ~= "table" then
        return false, "Selected language not found"
    end

    local translationCode = language.Code

    if not isAvailable(translationCode) then
        translationCode = language.BaseLanguage
    end

    if not isAvailable(translationCode) then
        return false, "Translation is not available"
    end

    local applied, result, reason = pcall(
        Localization.SetLanguage,
        translationCode
    )

    if not applied then
        return false, "Localization error"
    end

    if result ~= true then
        return false, reason or "Could not apply language"
    end

    Selector.Confirmed = true

    return true, translationCode
end

function Selector.GetSelected()
    return Selector.SelectedLanguage
end

function Selector.GetSelectedInfo()
    if not LanguageDatabase
    or not Selector.SelectedLanguage then
        return nil
    end

    local success, language = pcall(
        LanguageDatabase.Get,
        Selector.SelectedLanguage
    )

    if not success then
        return nil
    end

    return language
end

function Selector.IsConfirmed()
    return Selector.Confirmed
end

function Selector.GetAlphabetGroups()
    local groups = {}

    for _, language in ipairs(Selector.GetLanguages()) do
        if type(language.EnglishName) == "string" then
            local letter = string.upper(
                language.EnglishName:sub(1, 1)
            )

            if not groups[letter] then
                groups[letter] = {}
            end

            groups[letter][#groups[letter] + 1] = language
        end
    end

    return groups
end

function Selector.GetInfo()
    return {
        Name = Selector.Name,
        Version = Selector.Version,
        Status = Selector.Status,
        SelectedLanguage = Selector.SelectedLanguage,
        SearchQuery = Selector.SearchQuery,
        Confirmed = Selector.Confirmed,
        Initialized = LanguageDatabase ~= nil
            and Localization ~= nil,
        AvailableLanguages = #Selector.Languages
    }
end

return Selector

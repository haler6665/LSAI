
--[[
    LSAI Language Selector
    Version: 0.4.0
    Runtime: Standard Lua
]]

local Selector = {
    Version = "0.4.0",
    SelectedLanguage = nil,
    SearchQuery = "",
    Languages = {},
    Confirmed = false
}

local LanguageDatabase = nil
local Localization = nil

function Selector.Initialize(database, localization)
    if type(database) ~= "table"
    or type(localization) ~= "table" then
        return false, "Invalid dependencies"
    end

    if type(database.GetAll) ~= "function"
    or type(database.Search) ~= "function"
    or type(localization.SetLanguage) ~= "function" then
        return false, "Required methods are missing"
    end

    LanguageDatabase = database
    Localization = localization

    Selector.Languages = database.GetAll()
    Selector.SearchQuery = ""
    Selector.Confirmed = false

    return true
end

function Selector.GetLanguages()
    if not LanguageDatabase then
        return {}
    end

    if Selector.SearchQuery ~= "" then
        return LanguageDatabase.Search(Selector.SearchQuery)
    end

    return LanguageDatabase.GetAll()
end

function Selector.Search(query)
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

    local language = LanguageDatabase.Get(code)

    if not language then
        return false, "Language not found"
    end

    if not Localization.HasLanguage(code)
    and not Localization.HasLanguage(language.BaseLanguage) then
        return false, "Translation is not available"
    end

    Selector.SelectedLanguage = code
    Selector.Confirmed = false

    return true
end

function Selector.Confirm()
    if not Selector.SelectedLanguage then
        return false, "No language selected"
    end

    local language = LanguageDatabase.Get(
        Selector.SelectedLanguage
    )

    local translationCode = Selector.SelectedLanguage

    if not Localization.HasLanguage(translationCode) then
        translationCode = language.BaseLanguage
    end

    local success, reason = Localization.SetLanguage(
        translationCode
    )

    if not success then
        return false, reason
    end

    Selector.Confirmed = true

    return true, translationCode
end

function Selector.GetSelected()
    return Selector.SelectedLanguage
end

function Selector.IsConfirmed()
    return Selector.Confirmed
end

function Selector.GetAlphabetGroups()
    local groups = {}

    for _, language in ipairs(Selector.GetLanguages()) do
        local letter = string.upper(
            language.EnglishName:sub(1, 1)
        )

        if not groups[letter] then
            groups[letter] = {}
        end

        groups[letter][#groups[letter] + 1] = language
    end

    return groups
end

function Selector.GetInfo()
    return {
        Version = Selector.Version,
        SelectedLanguage = Selector.SelectedLanguage,
        SearchQuery = Selector.SearchQuery,
        Confirmed = Selector.Confirmed,
        Initialized = LanguageDatabase ~= nil
    }
end

return Selector


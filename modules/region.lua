
--[[
    LSAI Region Module
    Version: 0.4.0
    Runtime: Standard Lua
]]

local Region = {
    Version = "0.4.0",
    DefaultLanguage = "en",
    DetectedRegion = nil,
    SuggestedLanguage = "en",
    DetectionMethod = "fallback"
}

local regionMap = {
    US = {Language = "en", Name = "United States"},
    GB = {Language = "en", Name = "United Kingdom"},
    AU = {Language = "en", Name = "Australia"},
    CA = {Language = "en", Name = "Canada"},

    RU = {Language = "ru", Name = "Russia"},
    MD = {Language = "ro", Name = "Moldova"},
    RO = {Language = "ro", Name = "Romania"},
    DE = {Language = "de", Name = "Germany"},
    IT = {Language = "it", Name = "Italy"},
    FR = {Language = "fr", Name = "France"},

    ES = {Language = "es", Name = "Spain"},
    UA = {Language = "uk", Name = "Ukraine"},
    PL = {Language = "pl", Name = "Poland"},
    TR = {Language = "tr", Name = "Turkey"},
    JP = {Language = "ja", Name = "Japan"},
    KR = {Language = "ko", Name = "South Korea"},
    CN = {Language = "zh", Name = "China"},
    BR = {Language = "pt", Name = "Brazil"},
    PT = {Language = "pt", Name = "Portugal"}
}

local languageMap = {
    en = "en",
    ru = "ru",
    ro = "ro",
    de = "de",
    it = "it",
    fr = "fr",
    es = "es",
    uk = "uk",
    pl = "pl",
    tr = "tr",
    ja = "ja",
    ko = "ko",
    zh = "zh",
    pt = "pt"
}

local function normalize(value)
    if type(value) ~= "string" then
        return nil
    end

    return string.lower(value):gsub("_", "-")
end

function Region.DetectFromLocale(locale)
    locale = normalize(locale)

    if not locale then
        return nil, "Invalid locale"
    end

    local language, country = locale:match("^([a-z]+)%-([a-z]+)$")

    if language then
        country = string.upper(country)

        local region = regionMap[country]

        if region then
            Region.DetectedRegion = country
            Region.SuggestedLanguage = region.Language
            Region.DetectionMethod = "locale-region"

            return region.Language
        end
    end

    local baseLanguage = locale:match("^([a-z]+)")

    if baseLanguage and languageMap[baseLanguage] then
        Region.SuggestedLanguage = languageMap[baseLanguage]
        Region.DetectionMethod = "locale-language"

        return Region.SuggestedLanguage
    end

    Region.SuggestedLanguage = Region.DefaultLanguage
    Region.DetectionMethod = "fallback"

    return Region.DefaultLanguage
end

function Region.Detect()
    -- Standard Lua does not provide a universal locale API.
    -- The host application may provide a locale string later.

    Region.SuggestedLanguage = Region.DefaultLanguage
    Region.DetectionMethod = "fallback"

    return Region.SuggestedLanguage
end

function Region.SetSuggestion(language, method)
    if type(language) ~= "string" then
        return false, "Invalid language"
    end

    Region.SuggestedLanguage = language
    Region.DetectionMethod = method or "manual"

    return true
end

function Region.GetSuggestion()
    return {
        Region = Region.DetectedRegion,
        Language = Region.SuggestedLanguage,
        Method = Region.DetectionMethod
    }
end

function Region.GetInfo()
    return {
        Version = Region.Version,
        DetectedRegion = Region.DetectedRegion,
        SuggestedLanguage = Region.SuggestedLanguage,
        DetectionMethod = Region.DetectionMethod
    }
end

return Region


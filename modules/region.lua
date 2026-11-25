
--[[
    LSAI Region Module
    Version: 0.5.0
    Runtime: Standard Lua

    Features:
    - Locale parsing
    - Region detection from supplied locale
    - Language suggestions
    - Safe fallback
    - No automatic language switching
]]

local Region = {
    Name = "LSAI Region Module",
    Version = "0.5.0",
    Status = "Ready",

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

    value = string.lower(value)
    value = string.gsub(value, "_", "-")

    return value
end

local function resetDetection()
    Region.DetectedRegion = nil
    Region.SuggestedLanguage = Region.DefaultLanguage
    Region.DetectionMethod = "fallback"
end

local function setResult(language, country, method)
    Region.DetectedRegion = country
    Region.SuggestedLanguage = language
    Region.DetectionMethod = method

    return language
end

function Region.DetectFromLocale(locale)
    locale = normalize(locale)

    resetDetection()

    if not locale or locale == "" then
        return Region.DefaultLanguage, "Invalid locale"
    end

    -- Supports language-country format:
    -- en-US, ro-RO, pt-BR

    local language, country = locale:match(
        "^([a-z]+)%-([a-z]+)$"
    )

    if language and country then
        country = string.upper(country)

        local region = regionMap[country]

        if region then
            return setResult(
                region.Language,
                country,
                "locale-region"
            )
        end

        if languageMap[language] then
            return setResult(
                languageMap[language],
                nil,
                "locale-language"
            )
        end
    end

    -- Supports language-only format:
    -- en, ru, ro

    local baseLanguage = locale:match("^([a-z]+)$")

    if baseLanguage and languageMap[baseLanguage] then
        return setResult(
            languageMap[baseLanguage],
            nil,
            "locale-language"
        )
    end

    return setResult(
        Region.DefaultLanguage,
        nil,
        "fallback"
    )
end

function Region.Detect()
    -- Standard Lua has no universal locale API.
    -- The host application must provide the locale.
    resetDetection()

    return Region.SuggestedLanguage
end

function Region.SetSuggestion(language, method)
    language = normalize(language)

    if not language or not languageMap[language] then
        return false, "Unsupported language"
    end

    Region.SuggestedLanguage = language
    Region.DetectionMethod = method or "manual"

    return true
end

function Region.GetRegionName()
    if not Region.DetectedRegion then
        return nil
    end

    local region = regionMap[Region.DetectedRegion]

    return region and region.Name or nil
end

function Region.GetSuggestion()
    return {
        Region = Region.DetectedRegion,
        RegionName = Region.GetRegionName(),
        Language = Region.SuggestedLanguage,
        Method = Region.DetectionMethod
    }
end

function Region.GetSupportedRegions()
    local result = {}

    for code, region in pairs(regionMap) do
        result[#result + 1] = {
            Code = code,
            Name = region.Name,
            Language = region.Language
        }
    end

    table.sort(result, function(a, b)
        return a.Name < b.Name
    end)

    return result
end

function Region.GetInfo()
    return {
        Name = Region.Name,
        Version = Region.Version,
        Status = Region.Status,
        DefaultLanguage = Region.DefaultLanguage,
        DetectedRegion = Region.DetectedRegion,
        SuggestedLanguage = Region.SuggestedLanguage,
        DetectionMethod = Region.DetectionMethod
    }
end

return Region

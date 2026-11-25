--[[
    LSAI Language Database
    Version: 0.5.0
    Runtime: Standard Lua

    Features:
    - Language and regional language database
    - Safe data copies
    - Search by code and language name
    - Regional language fallback
    - Translation status management
]]

local LanguageDatabase = {
    Name = "LSAI Language Database",
    Version = "0.5.0",
    DefaultLanguage = "en",
    Status = "Ready"
}

local entries = {
    {"af", "Afrikaans", "Afrikaans"},
    {"sq", "Albanian", "Shqip"},
    {"am", "Amharic", "አማርኛ"},
    {"ar", "Arabic", "العربية"},
    {"hy", "Armenian", "Հայերեն"},
    {"az", "Azerbaijani", "Azərbaycanca"},
    {"eu", "Basque", "Euskara"},
    {"be", "Belarusian", "Беларуская"},
    {"bn", "Bengali", "বাংলা"},
    {"bs", "Bosnian", "Bosanski"},
    {"bg", "Bulgarian", "Български"},
    {"my", "Burmese", "မြန်မာ"},
    {"ca", "Catalan", "Català"},
    {"zh", "Chinese", "中文"},
    {"hr", "Croatian", "Hrvatski"},
    {"cs", "Czech", "Čeština"},
    {"da", "Danish", "Dansk"},
    {"nl", "Dutch", "Nederlands"},
    {"en", "English", "English"},
    {"et", "Estonian", "Eesti"},
    {"fi", "Finnish", "Suomi"},
    {"fr", "French", "Français"},
    {"gl", "Galician", "Galego"},
    {"ka", "Georgian", "ქართული"},
    {"de", "German", "Deutsch"},
    {"el", "Greek", "Ελληνικά"},
    {"gu", "Gujarati", "ગુજરાતી"},
    {"he", "Hebrew", "עברית"},
    {"hi", "Hindi", "हिन्दी"},
    {"hu", "Hungarian", "Magyar"},
    {"is", "Icelandic", "Íslenska"},
    {"id", "Indonesian", "Bahasa Indonesia"},
    {"ga", "Irish", "Gaeilge"},
    {"it", "Italian", "Italiano"},
    {"ja", "Japanese", "日本語"},
    {"kn", "Kannada", "ಕನ್ನಡ"},
    {"kk", "Kazakh", "Қазақша"},
    {"km", "Khmer", "ខ្មែរ"},
    {"ko", "Korean", "한국어"},
    {"ky", "Kyrgyz", "Кыргызча"},
    {"lo", "Lao", "ລາວ"},
    {"lv", "Latvian", "Latviešu"},
    {"lt", "Lithuanian", "Lietuvių"},
    {"mk", "Macedonian", "Македонски"},
    {"ms", "Malay", "Bahasa Melayu"},
    {"ml", "Malayalam", "മലയാളം"},
    {"mt", "Maltese", "Malti"},
    {"mr", "Marathi", "मराठी"},
    {"mn", "Mongolian", "Монгол"},
    {"ne", "Nepali", "नेपाली"},
    {"no", "Norwegian", "Norsk"},
    {"fa", "Persian", "فارسی"},
    {"pl", "Polish", "Polski"},
    {"pt", "Portuguese", "Português"},
    {"pa", "Punjabi", "ਪੰਜਾਬੀ"},
    {"ro", "Romanian", "Română"},
    {"ru", "Russian", "Русский"},
    {"sr", "Serbian", "Српски"},
    {"sk", "Slovak", "Slovenčina"},
    {"sl", "Slovenian", "Slovenščina"},
    {"es", "Spanish", "Español"},
    {"sw", "Swahili", "Kiswahili"},
    {"sv", "Swedish", "Svenska"},
    {"tl", "Filipino", "Filipino"},
    {"th", "Thai", "ไทย"},
    {"tr", "Turkish", "Türkçe"},
    {"uk", "Ukrainian", "Українська"},
    {"ur", "Urdu", "اردو"},
    {"uz", "Uzbek", "O‘zbekcha"},
    {"vi", "Vietnamese", "Tiếng Việt"},
    {"cy", "Welsh", "Cymraeg"},
    {"zu", "Zulu", "isiZulu"},

    {"en-US", "English (United States)", "English (US)", "en"},
    {"en-GB", "English (United Kingdom)", "English (UK)", "en"},
    {"en-AU", "English (Australia)", "English (AU)", "en"},
    {"en-CA", "English (Canada)", "English (CA)", "en"},
    {"fr-FR", "French (France)", "Français (France)", "fr"},
    {"fr-CA", "French (Canada)", "Français (Canada)", "fr"},
    {"pt-BR", "Portuguese (Brazil)", "Português (Brasil)", "pt"},
    {"pt-PT", "Portuguese (Portugal)", "Português (Portugal)", "pt"},
    {"es-ES", "Spanish (Spain)", "Español (España)", "es"},
    {"es-MX", "Spanish (Mexico)", "Español (México)", "es"},
    {"zh-CN", "Chinese (Simplified)", "简体中文", "zh"},
    {"zh-TW", "Chinese (Traditional)", "繁體中文", "zh"}
}

local languages = {}
local languageIndex = {}

local allowedStatuses = {
    ["Not translated"] = true,
    ["Partially translated"] = true,
    ["Translated"] = true
}

local function normalizeCode(code)
    if type(code) ~= "string" then
        return nil
    end

    code = string.lower(code)
    code = string.gsub(code, "_", "-")

    return code
end

local function copyLanguage(language)
    if not language then
        return nil
    end

    return {
        Code = language.Code,
        EnglishName = language.EnglishName,
        NativeName = language.NativeName,
        BaseLanguage = language.BaseLanguage,
        TranslationStatus = language.TranslationStatus
    }
end

local function copyLanguages(source)
    local result = {}

    for index, language in ipairs(source) do
        result[index] = copyLanguage(language)
    end

    return result
end

-- Build internal database.

for _, item in ipairs(entries) do
    local language = {
        Code = item[1],
        EnglishName = item[2],
        NativeName = item[3],
        BaseLanguage = item[4] or item[1],
        TranslationStatus = "Not translated"
    }

    languages[#languages + 1] = language
    languageIndex[normalizeCode(language.Code)] = language
end

table.sort(languages, function(a, b)
    local first = string.lower(a.EnglishName)
    local second = string.lower(b.EnglishName)

    if first == second then
        return a.Code < b.Code
    end

    return first < second
end)

-- Compatibility snapshot.
-- Editing this table does not change the internal database.

LanguageDatabase.Languages = copyLanguages(languages)

function LanguageDatabase.GetAll()
    return copyLanguages(languages)
end

function LanguageDatabase.Get(code)
    local normalized = normalizeCode(code)

    if not normalized then
        return nil
    end

    return copyLanguage(languageIndex[normalized])
end

function LanguageDatabase.GetBaseLanguage(code)
    local language = LanguageDatabase.Get(code)

    if not language then
        return nil
    end

    return language.BaseLanguage
end

function LanguageDatabase.IsSupported(code)
    local normalized = normalizeCode(code)

    if not normalized then
        return false
    end

    return languageIndex[normalized] ~= nil
end

function LanguageDatabase.Search(query)
    query = string.lower(tostring(query or ""))

    local results = {}

    if query == "" then
        return results
    end

    for _, language in ipairs(languages) do
        local english = string.lower(language.EnglishName)
        local native = string.lower(language.NativeName)
        local code = string.lower(language.Code)

        if string.find(english, query, 1, true)
        or string.find(native, query, 1, true)
        or string.find(code, query, 1, true) then
            results[#results + 1] = copyLanguage(language)
        end
    end

    return results
end

function LanguageDatabase.SetTranslationStatus(code, status)
    local normalized = normalizeCode(code)

    if not normalized then
        return false, "Invalid language code"
    end

    if not allowedStatuses[status] then
        return false, "Invalid translation status"
    end

    local language = languageIndex[normalized]

    if not language then
        return false, "Language not found"
    end

    language.TranslationStatus = status

    -- Update the compatibility snapshot too.
    for _, publicLanguage in ipairs(LanguageDatabase.Languages) do
        if publicLanguage.Code == language.Code then
            publicLanguage.TranslationStatus = status
            break
        end
    end

    return true
end

function LanguageDatabase.GetCount()
    return #languages
end

function LanguageDatabase.GetInfo()
    return {
        Name = LanguageDatabase.Name,
        Version = LanguageDatabase.Version,
        Status = LanguageDatabase.Status,
        LanguageCount = #languages,
        DefaultLanguage = LanguageDatabase.DefaultLanguage
    }
end

return LanguageDatabase


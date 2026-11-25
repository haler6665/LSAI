--[[
    LSAI Localization Module
    Version: 0.5.0
    Runtime: Standard Lua

    Supported translations:
    English, Russian, Romanian,
    Italian, German, French.
]]

local Localization = {
    Name = "LSAI Localization",
    Version = "0.5.0",

    DefaultLanguage = "en",
    CurrentLanguage = "en"
}

local translations = {
    en = {
        app_name = "LSAI",
        welcome = "Welcome to LSAI",
        choose_language = "Choose your language",
        search_language = "Search language...",
        confirm = "Confirm",
        cancel = "Cancel",
        continue_text = "Continue",
        agreement = "User Agreement",
        accept = "Accept",
        reject = "Reject",
        settings = "Settings",
        security = "Security",
        saved_scripts = "Saved Scripts",
        macros = "Macros",
        language = "Language",
        theme = "Theme",
        dark = "Dark",
        light = "Light",
        scan = "Scan",
        scanning = "Scanning...",
        results = "Scan Results",
        no_results = "No results found",
        back = "Back",
        close = "Close",
        loading = "Loading...",
        ready = "Ready",
        error = "Error",
        first_launch = "First Launch",
        automatic_language = "Suggested language",
        manual_selection = "Select manually",
        translation_status = "Translation status"
    },

    ru = {
        app_name = "LSAI",
        welcome = "Добро пожаловать в LSAI",
        choose_language = "Выберите язык",
        search_language = "Поиск языка...",
        confirm = "Подтвердить",
        cancel = "Отмена",
        continue_text = "Продолжить",
        agreement = "Пользовательское соглашение",
        accept = "Принять",
        reject = "Отклонить",
        settings = "Настройки",
        security = "Безопасность",
        saved_scripts = "Сохранённые скрипты",
        macros = "Макросы",
        language = "Язык",
        theme = "Тема",
        dark = "Тёмная",
        light = "Светлая",
        scan = "Сканировать",
        scanning = "Сканирование...",
        results = "Результаты проверки",
        no_results = "Ничего не найдено",
        back = "Назад",
        close = "Закрыть",
        loading = "Загрузка...",
        ready = "Готово",
        error = "Ошибка",
        first_launch = "Первый запуск",
        automatic_language = "Предлагаемый язык",
        manual_selection = "Выбрать вручную",
        translation_status = "Статус перевода"
    },

    ro = {
        app_name = "LSAI",
        welcome = "Bun venit la LSAI",
        choose_language = "Alegeți limba",
        search_language = "Caută limba...",
        confirm = "Confirmă",
        cancel = "Anulează",
        continue_text = "Continuă",
        agreement = "Acordul utilizatorului",
        accept = "Acceptă",
        reject = "Respinge",
        settings = "Setări",
        security = "Securitate",
        saved_scripts = "Scripturi salvate",
        macros = "Macrocomenzi",
        language = "Limbă",
        theme = "Temă",
        dark = "Întunecată",
        light = "Luminoasă",
        scan = "Scanează",
        scanning = "Se scanează...",
        results = "Rezultatele scanării",
        no_results = "Nu s-au găsit rezultate",
        back = "Înapoi",
        close = "Închide",
        loading = "Se încarcă...",
        ready = "Gata",
        error = "Eroare",
        first_launch = "Prima pornire",
        automatic_language = "Limba sugerată",
        manual_selection = "Selectare manuală",
        translation_status = "Starea traducerii"
    },

    it = {
        app_name = "LSAI",
        welcome = "Benvenuto in LSAI",
        choose_language = "Scegli la lingua",
        search_language = "Cerca lingua...",
        confirm = "Conferma",
        cancel = "Annulla",
        continue_text = "Continua",
        agreement = "Accordo utente",
        accept = "Accetta",
        reject = "Rifiuta",
        settings = "Impostazioni",
        security = "Sicurezza",
        saved_scripts = "Script salvati",
        macros = "Macro",
        language = "Lingua",
        theme = "Tema",
        dark = "Scuro",
        light = "Chiaro",
        scan = "Scansiona",
        scanning = "Scansione...",
        results = "Risultati della scansione",
        no_results = "Nessun risultato trovato",
        back = "Indietro",
        close = "Chiudi",
        loading = "Caricamento...",
        ready = "Pronto",
        error = "Errore",
        first_launch = "Primo avvio",
        automatic_language = "Lingua suggerita",
        manual_selection = "Seleziona manualmente",
        translation_status = "Stato della traduzione"
    },

    de = {
        app_name = "LSAI",
        welcome = "Willkommen bei LSAI",
        choose_language = "Sprache auswählen",
        search_language = "Sprache suchen...",
        confirm = "Bestätigen",
        cancel = "Abbrechen",
        continue_text = "Weiter",
        agreement = "Nutzungsvereinbarung",
        accept = "Akzeptieren",
        reject = "Ablehnen",
        settings = "Einstellungen",
        security = "Sicherheit",
        saved_scripts = "Gespeicherte Skripte",
        macros = "Makros",
        language = "Sprache",
        theme = "Design",
        dark = "Dunkel",
        light = "Hell",
        scan = "Scannen",
        scanning = "Wird gescannt...",
        results = "Scanergebnisse",
        no_results = "Keine Ergebnisse gefunden",
        back = "Zurück",
        close = "Schließen",
        loading = "Laden...",
        ready = "Bereit",
        error = "Fehler",
        first_launch = "Erster Start",
        automatic_language = "Vorgeschlagene Sprache",
        manual_selection = "Manuell auswählen",
        translation_status = "Übersetzungsstatus"
    },

    fr = {
        app_name = "LSAI",
        welcome = "Bienvenue dans LSAI",
        choose_language = "Choisissez votre langue",
        search_language = "Rechercher une langue...",
        confirm = "Confirmer",
        cancel = "Annuler",
        continue_text = "Continuer",
        agreement = "Accord utilisateur",
        accept = "Accepter",
        reject = "Refuser",
        settings = "Paramètres",
        security = "Sécurité",
        saved_scripts = "Scripts enregistrés",
        macros = "Macros",
        language = "Langue",
        theme = "Thème",
        dark = "Sombre",
        light = "Clair",
        scan = "Analyser",
        scanning = "Analyse en cours...",
        results = "Résultats de l'analyse",
        no_results = "Aucun résultat trouvé",
        back = "Retour",
        close = "Fermer",
        loading = "Chargement...",
        ready = "Prêt",
        error = "Erreur",
        first_launch = "Premier démarrage",
        automatic_language = "Langue suggérée",
        manual_selection = "Sélection manuelle",
        translation_status = "État de la traduction"
    }
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

local function normalizeCode(code)
    if type(code) ~= "string" then
        return nil
    end

    code = code:gsub("_", "-")
    code = string.lower(code)

    return code
end

function Localization.SetLanguage(code)
    code = normalizeCode(code)

    if not code or code == "" then
        return false, "Invalid language code"
    end

    if translations[code] then
        Localization.CurrentLanguage = code
        return true, code
    end

    local baseCode = code:match("^([^-]+)")

    if baseCode and translations[baseCode] then
        Localization.CurrentLanguage = baseCode
        return true, baseCode
    end

    return false, "Translation is not available"
end

function Localization.Get(key)
    if type(key) ~= "string" then
        return "[invalid-key]"
    end

    local current = translations[Localization.CurrentLanguage]
    local fallback = translations[Localization.DefaultLanguage]

    if current and current[key] ~= nil then
        return current[key]
    end

    if fallback and fallback[key] ~= nil then
        return fallback[key]
    end

    return "[" .. key .. "]"
end

function Localization.HasLanguage(code)
    code = normalizeCode(code)

    if not code then
        return false
    end

    if translations[code] then
        return true
    end

    local baseCode = code:match("^([^-]+)")

    return baseCode ~= nil
        and translations[baseCode] ~= nil
end

function Localization.GetLanguages()
    local result = {}

    for code in pairs(translations) do
        result[#result + 1] = code
    end

    table.sort(result)

    return result
end

function Localization.GetTranslation(code)
    code = normalizeCode(code)

    if not code then
        return nil
    end

    local baseCode = code:match("^([^-]+)")
    local selected = translations[code]
        or translations[baseCode]

    if not selected then
        return nil
    end

    return copyTable(selected)
end

function Localization.GetStats()
    local total = 0

    for _ in pairs(translations.en) do
        total = total + 1
    end

    local result = {}

    for code, language in pairs(translations) do
        local translated = 0

        for key in pairs(translations.en) do
            if language[key] ~= nil then
                translated = translated + 1
            end
        end

        result[code] = {
            Translated = translated,
            Total = total,
            Percentage = total > 0
                and math.floor(translated / total * 100)
                or 0
        }
    end

    return result
end

function Localization.GetInfo()
    return {
        Name = Localization.Name,
        Version = Localization.Version,
        DefaultLanguage = Localization.DefaultLanguage,
        CurrentLanguage = Localization.CurrentLanguage,
        AvailableLanguages = #Localization.GetLanguages()
    }
end

return Localization



--[[
    LSAI Localization Module
    Version: 0.4.0
    Runtime: Standard Lua
]]

local Localization = {
    Version = "0.4.0",
    DefaultLanguage = "en",
    CurrentLanguage = "en",
    Translations = {}
}

Localization.Translations = {
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

function Localization.SetLanguage(code)
    if type(code) ~= "string" then
        return false, "Invalid language code"
    end

    if not Localization.Translations[code] then
        return false, "Translation is not available"
    end

    Localization.CurrentLanguage = code

    return true
end

function Localization.Get(key)
    local current = Localization.Translations[
        Localization.CurrentLanguage
    ]

    local fallback = Localization.Translations[
        Localization.DefaultLanguage
    ]

    if current and current[key] ~= nil then
        return current[key]
    end

    if fallback and fallback[key] ~= nil then
        return fallback[key]
    end

    return "[" .. tostring(key) .. "]"
end

function Localization.HasLanguage(code)
    return Localization.Translations[code] ~= nil
end

function Localization.GetLanguages()
    local result = {}

    for code in pairs(Localization.Translations) do
        result[#result + 1] = code
    end

    table.sort(result)

    return result
end

function Localization.GetInfo()
    return {
        Version = Localization.Version,
        CurrentLanguage = Localization.CurrentLanguage,
        AvailableLanguages = #Localization.GetLanguages()
    }
end

return Localization


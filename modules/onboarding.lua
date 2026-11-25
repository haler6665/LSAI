
--[[
    LSAI Onboarding Module
    Version: 0.5.0
    Runtime: Standard Lua

    Features:
    - First launch flow
    - Language selection
    - Regional language suggestion
    - Welcome screen
    - Agreement confirmation
    - Settings integration
]]

local Onboarding = {
    Name = "LSAI Onboarding",
    Version = "0.5.0",
    Status = "NotStarted",
    Step = "None",

    IsFirstLaunch = true,
    SelectedLanguage = "en",
    SuggestedLanguage = "en",

    AgreementAccepted = false,
    Completed = false
}

local Database
local Selector
local Localization
local Region

local function setStep(step)
    Onboarding.Step = step
    Onboarding.Status = "Running"
end

local function safeCall(callback, ...)
    if type(callback) ~= "function" then
        return false, "Required method is missing"
    end

    local success, result, reason = pcall(callback, ...)

    if not success then
        return false, "Module operation failed"
    end

    return result, reason
end

function Onboarding.Initialize(dependencies)
    dependencies = dependencies or {}

    if type(dependencies) ~= "table" then
        return false, "Invalid dependencies"
    end

    local database = dependencies.Database
    local selector = dependencies.LanguageSelector
    local localization = dependencies.Localization
    local region = dependencies.Region

    if type(database) ~= "table"
    or type(database.SetSetting) ~= "function"
    or type(database.GetSetting) ~= "function" then
        return false, "Valid Database module is required"
    end

    if type(selector) ~= "table"
    or type(selector.Select) ~= "function"
    or type(selector.Confirm) ~= "function" then
        return false, "Valid LanguageSelector module is required"
    end

    if type(localization) ~= "table"
    or type(localization.SetLanguage) ~= "function" then
        return false, "Valid Localization module is required"
    end

    if region ~= nil and type(region.GetSuggestion) ~= "function" then
        return false, "Invalid Region module"
    end

    Database = database
    Selector = selector
    Localization = localization
    Region = region

    Onboarding.Status = "Initialized"
    Onboarding.Step = "None"

    return true
end

function Onboarding.Start(firstLaunch)
    if not Database or not Selector or not Localization then
        return false, "Onboarding is not initialized"
    end

    Onboarding.IsFirstLaunch = firstLaunch ~= false

    if not Onboarding.IsFirstLaunch then
        Onboarding.Completed = true
        Onboarding.Status = "Completed"
        Onboarding.Step = "Finished"

        return true, "Already completed"
    end

    Onboarding.AgreementAccepted = false
    Onboarding.Completed = false
    Onboarding.SelectedLanguage = "en"

    local savedLanguage = safeCall(
        Database.GetSetting,
        "Language"
    )

    if type(savedLanguage) == "string" then
        Onboarding.SelectedLanguage = savedLanguage
    end

    if Region then
        local success, suggestion = safeCall(
            Region.GetSuggestion
        )

        if success and type(suggestion) == "table"
        and type(suggestion.Language) == "string" then
            Onboarding.SuggestedLanguage = suggestion.Language
        end
    end

    if Onboarding.SelectedLanguage == "en"
    and Onboarding.SuggestedLanguage ~= "en" then
        Onboarding.SelectedLanguage = Onboarding.SuggestedLanguage
    end

    setStep("LanguageSelection")

    return true, {
        Step = Onboarding.Step,
        SelectedLanguage = Onboarding.SelectedLanguage,
        SuggestedLanguage = Onboarding.SuggestedLanguage
    }
end

function Onboarding.SelectLanguage(code)
    if Onboarding.Step ~= "LanguageSelection" then
        return false, "Language selection is not active"
    end

    if type(code) ~= "string" then
        return false, "Invalid language code"
    end

    local success, reason = safeCall(
        Selector.Select,
        code
    )

    if not success then
        return false, reason or "Language selection failed"
    end

    Onboarding.SelectedLanguage = code

    return true, "Language selected"
end

function Onboarding.ConfirmLanguage()
    if Onboarding.Step ~= "LanguageSelection" then
        return false, "Language selection is not active"
    end

    if not Onboarding.SelectedLanguage then
        return false, "No language selected"
    end

    local selected = safeCall(
        Selector.GetSelected
    )

    if selected ~= Onboarding.SelectedLanguage then
        return false, "Selected language does not match"
    end

    local success, result = safeCall(
        Selector.Confirm
    )

    if not success then
        return false, result or "Language confirmation failed"
    end

    if result ~= true then
        return false, "Could not confirm language"
    end

    setStep("Welcome")

    return true, "Language confirmed"
end

function Onboarding.ContinueFromWelcome()
    if Onboarding.Step ~= "Welcome" then
        return false, "Welcome screen is not active"
    end

    setStep("Agreement")

    return true, "Agreement required"
end

function Onboarding.AcceptAgreement(accepted)
    if Onboarding.Step ~= "Agreement" then
        return false, "Agreement screen is not active"
    end

    if accepted ~= true then
        Onboarding.AgreementAccepted = false
        Onboarding.Status = "AgreementDeclined"

        return false, "Agreement was not accepted"
    end

    Onboarding.AgreementAccepted = true

    return Onboarding.Complete()
end

function Onboarding.Complete()
    if Onboarding.Step ~= "Agreement" then
        return false, "Agreement step is not active"
    end

    if not Onboarding.AgreementAccepted then
        return false, "Agreement must be accepted first"
    end

    local languageSaved, languageError = safeCall(
        Database.SetSetting,
        "Language",
        Onboarding.SelectedLanguage
    )

    if not languageSaved then
        return false, languageError or "Could not save language"
    end

    local launchSaved, launchError = safeCall(
        Database.SetSetting,
        "FirstLaunchCompleted",
        true
    )

    if not launchSaved then
        return false, launchError or "Could not save onboarding state"
    end

    Onboarding.Completed = true
    Onboarding.Status = "Completed"
    Onboarding.Step = "Finished"

    return true, "Onboarding completed"
end

function Onboarding.GetState()
    return {
        Version = Onboarding.Version,
        Status = Onboarding.Status,
        Step = Onboarding.Step,
        IsFirstLaunch = Onboarding.IsFirstLaunch,
        SelectedLanguage = Onboarding.SelectedLanguage,
        SuggestedLanguage = Onboarding.SuggestedLanguage,
        AgreementAccepted = Onboarding.AgreementAccepted,
        Completed = Onboarding.Completed
    }
end

function Onboarding.GetInfo()
    return {
        Name = Onboarding.Name,
        Version = Onboarding.Version,
        Status = Onboarding.Status,
        Step = Onboarding.Step,
        Completed = Onboarding.Completed
    }
end

return Onboarding

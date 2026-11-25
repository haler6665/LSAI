
-- LSAI Onboarding Module
-- Version: 0.4.0

local Onboarding = {
    Version = "0.4.0",
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

function Onboarding.Initialize(dependencies)
    dependencies = dependencies or {}

    Database = dependencies.Database
    Selector = dependencies.LanguageSelector
    Localization = dependencies.Localization
    Region = dependencies.Region

    if not Database then
        return false, "Database module is required"
    end

    if not Selector then
        return false, "LanguageSelector module is required"
    end

    if not Localization then
        return false, "Localization module is required"
    end

    Onboarding.Status = "Initialized"
    return true
end

function Onboarding.Start(firstLaunch)
    if Onboarding.Status == "NotStarted" then
        return false, "Onboarding is not initialized"
    end

    Onboarding.IsFirstLaunch = firstLaunch ~= false

    if not Onboarding.IsFirstLaunch then
        Onboarding.Status = "Completed"
        Onboarding.Completed = true
        return true, "Already completed"
    end

    Onboarding.AgreementAccepted = false
    Onboarding.Completed = false

    if Region then
        local suggestion = Region.GetSuggestion()

        if suggestion and suggestion.Language then
            Onboarding.SuggestedLanguage = suggestion.Language
        end
    end

    setStep("LanguageSelection")

    return true, {
        Step = Onboarding.Step,
        SuggestedLanguage = Onboarding.SuggestedLanguage
    }
end

function Onboarding.SelectLanguage(code)
    if Onboarding.Step ~= "LanguageSelection" then
        return false, "Language selection is not active"
    end

    local success, result = Selector.Select(code)

    if not success then
        return false, result
    end

    Onboarding.SelectedLanguage = code

    return true, "Language selected"
end

function Onboarding.ConfirmLanguage()
    if Onboarding.Step ~= "LanguageSelection" then
        return false, "Language selection is not active"
    end

    local success, result = Selector.Confirm()

    if not success then
        return false, result
    end

    Localization.SetLanguage(Onboarding.SelectedLanguage)

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
    if not Onboarding.AgreementAccepted then
        return false, "Agreement must be accepted first"
    end

    Onboarding.Completed = true
    Onboarding.Status = "Completed"
    Onboarding.Step = "Finished"

    Database.SetSetting("Language", Onboarding.SelectedLanguage)
    Database.SetSetting("FirstLaunchCompleted", true)

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
        Name = "Onboarding",
        Version = Onboarding.Version,
        Status = Onboarding.Status,
        Step = Onboarding.Step,
        Completed = Onboarding.Completed
    }
end

return Onboarding


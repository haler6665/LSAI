
--[[
    LSAI Agreement Module
    Version: 0.5.0
    Runtime: Standard Lua

    Features:
    - Agreement sections
    - Version tracking
    - Explicit acceptance
    - Acceptance status
    - Safe data access
]]

local Agreement = {
    Name = "LSAI Agreement",
    Version = "0.5.0",

    CurrentVersion = "1.1",

    Status = "NotAccepted",
    Accepted = false,
    AcceptedVersion = nil
}

local sections = {
    {
        Title = "Purpose",
        Text = "LSAI is a static Lua source analyzer. It examines source code without executing it."
    },
    {
        Title = "No execution",
        Text = "LSAI does not execute imported scripts, macros or scanned source code."
    },
    {
        Title = "Analysis limitations",
        Text = "Security analysis is not perfect. LSAI may miss suspicious code or report harmless code as suspicious."
    },
    {
        Title = "User responsibility",
        Text = "Review imported source code carefully. A clean scan does not guarantee that a script is safe."
    },
    {
        Title = "Privacy",
        Text = "LSAI should not collect personal information without a clear explanation and user consent."
    },
    {
        Title = "Updates",
        Text = "Features and analysis rules may change in future versions."
    },
    {
        Title = "User choice",
        Text = "Users can decline the agreement. Declining means that onboarding cannot be completed."
    }
}

local function copySection(section)
    if type(section) ~= "table" then
        return nil
    end

    return {
        Title = section.Title,
        Text = section.Text
    }
end

function Agreement.GetSections()
    local result = {}

    for index, section in ipairs(sections) do
        result[index] = copySection(section)
    end

    return result
end

function Agreement.GetSection(index)
    if type(index) ~= "number"
    or index < 1
    or index % 1 ~= 0 then
        return nil
    end

    return copySection(sections[index])
end

function Agreement.GetSectionCount()
    return #sections
end

function Agreement.Accept(accepted)
    if accepted ~= true then
        Agreement.Accepted = false
        Agreement.AcceptedVersion = nil
        Agreement.Status = "NotAccepted"

        return false, "Agreement was not accepted"
    end

    Agreement.Accepted = true
    Agreement.AcceptedVersion = Agreement.CurrentVersion
    Agreement.Status = "Accepted"

    return true, "Agreement accepted"
end

function Agreement.Reset()
    Agreement.Accepted = false
    Agreement.AcceptedVersion = nil
    Agreement.Status = "NotAccepted"

    return true
end

function Agreement.IsAccepted()
    return Agreement.Accepted == true
        and Agreement.AcceptedVersion == Agreement.CurrentVersion
end

function Agreement.GetStatus()
    return {
        Version = Agreement.Version,
        AgreementVersion = Agreement.CurrentVersion,
        Status = Agreement.Status,
        Accepted = Agreement.Accepted,
        AcceptedVersion = Agreement.AcceptedVersion,
        RequiresAcceptance = not Agreement.IsAccepted()
    }
end

function Agreement.GetInfo()
    return {
        Name = Agreement.Name,
        Version = Agreement.Version,
        AgreementVersion = Agreement.CurrentVersion,
        Status = Agreement.Status,
        SectionCount = #sections,
        Accepted = Agreement.Accepted
    }
end

return Agreement

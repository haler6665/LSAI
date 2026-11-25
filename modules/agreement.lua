
-- LSAI Agreement Module
-- Version: 0.4.0

local Agreement = {
    Version = "0.4.0",
    Status = "NotAccepted",
    Accepted = false,
    CurrentVersion = "1.0"
}

Agreement.Sections = {
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
    }
}

function Agreement.GetSections()
    local result = {}

    for index, section in ipairs(Agreement.Sections) do
        result[index] = {
            Title = section.Title,
            Text = section.Text
        }
    end

    return result
end

function Agreement.GetSection(index)
    local section = Agreement.Sections[index]

    if not section then
        return nil
    end

    return {
        Title = section.Title,
        Text = section.Text
    }
end

function Agreement.GetSectionCount()
    return #Agreement.Sections
end

function Agreement.Accept(accepted)
    if accepted ~= true then
        Agreement.Accepted = false
        Agreement.Status = "NotAccepted"

        return false, "Agreement was not accepted"
    end

    Agreement.Accepted = true
    Agreement.Status = "Accepted"

    return true, "Agreement accepted"
end

function Agreement.Reset()
    Agreement.Accepted = false
    Agreement.Status = "NotAccepted"
end

function Agreement.GetStatus()
    return {
        Version = Agreement.Version,
        AgreementVersion = Agreement.CurrentVersion,
        Status = Agreement.Status,
        Accepted = Agreement.Accepted
    }
end

function Agreement.GetInfo()
    return {
        Name = "Agreement",
        Version = Agreement.Version,
        Status = Agreement.Status,
        SectionCount = #Agreement.Sections
    }
end

return Agreement


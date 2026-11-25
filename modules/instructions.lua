
--[[
    LSAI Instructions Module
    Version: 0.4.0
    Runtime: Standard Lua
]]

local Instructions = {
    Version = "0.4.0",
    Language = "en"
}

Instructions.Pages = {
    overview = {
        Title = "LSAI Overview",
        Text = "LSAI is a static Lua source analyzer."
    },

    security = {
        Title = "Security Scanner",
        Text = "Scans Lua source text for suspicious indicators. Does not execute scanned code."
    },

    import = {
        Title = "Import",
        Text = "Import Lua source text for static analysis."
    },

    settings = {
        Title = "Settings",
        Text = "Configure language, theme and interface preferences."
    },

    macros = {
        Title = "Macro Editor",
        Text = "Create and organize visual macro blocks. Macro execution is not supported."
    },

    results = {
        Title = "Scan Results",
        Text = "Review detected indicators, risk levels and source line references."
    },

    limitations = {
        Title = "Limitations",
        Text = "Static analysis cannot guarantee that a script is safe. Some suspicious behavior may not be detected."
    }
}

Instructions.Commands = {
    {
        Name = "GetInfo",
        Description = "Returns LSAI information."
    },
    {
        Name = "GetModule",
        Description = "Returns a loaded module."
    },
    {
        Name = "GetStatus",
        Description = "Returns the current system status."
    },
    {
        Name = "Scan",
        Description = "Analyzes Lua source text without executing it."
    },
    {
        Name = "GetHistory",
        Description = "Returns previous scan records."
    }
}

local function normalize(value)
    return string.lower(tostring(value or ""))
end

function Instructions.GetPage(name)
    local page = Instructions.Pages[normalize(name)]

    if not page then
        return nil, "Page not found"
    end

    return {
        Title = page.Title,
        Text = page.Text
    }
end

function Instructions.GetPages()
    local result = {}

    for name, page in pairs(Instructions.Pages) do
        result[#result + 1] = {
            Name = name,
            Title = page.Title
        }
    end

    table.sort(result, function(a, b)
        return a.Name < b.Name
    end)

    return result
end

function Instructions.Search(query)
    query = normalize(query)

    if query == "" then
        return {}
    end

    local results = {}

    for name, page in pairs(Instructions.Pages) do
        local title = normalize(page.Title)
        local description = normalize(page.Text)

        if string.find(name, query, 1, true)
        or string.find(title, query, 1, true)
        or string.find(description, query, 1, true) then

            results[#results + 1] = {
                Name = name,
                Title = page.Title,
                Text = page.Text
            }
        end
    end

    return results
end

function Instructions.GetCommands()
    local result = {}

    for index, command in ipairs(Instructions.Commands) do
        result[index] = {
            Name = command.Name,
            Description = command.Description
        }
    end

    return result
end

function Instructions.SetLanguage(language)
    if type(language) ~= "string" then
        return false, "Invalid language"
    end

    Instructions.Language = language

    return true
end

function Instructions.GetInfo()
    return {
        Version = Instructions.Version,
        Language = Instructions.Language,
        PageCount = #Instructions.GetPages(),
        CommandCount = #Instructions.Commands
    }
end

return Instructions

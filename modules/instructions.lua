
--[[
    LSAI Instructions Module
    Version: 0.5.0
    Runtime: Standard Lua

    Provides documentation and help pages.
    Does not execute Lua source code.
]]

local Instructions = {
    Name = "LSAI Instructions Module",
    Version = "0.5.0",
    Language = "en"
}

local pages = {
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

local commands = {
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

local function normalize(value)
    if type(value) ~= "string" then
        return ""
    end

    return string.lower(value)
end

function Instructions.GetPage(name)
    if type(name) ~= "string" then
        return nil, "Invalid page name"
    end

    local page = pages[normalize(name)]

    if not page then
        return nil, "Page not found"
    end

    return copyTable(page)
end

function Instructions.GetPages()
    local result = {}

    for name, page in pairs(pages) do
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

function Instructions.GetAllPages()
    return copyTable(pages)
end

function Instructions.Search(query)
    query = normalize(query)

    if query == "" then
        return {}
    end

    local results = {}

    for name, page in pairs(pages) do
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

    table.sort(results, function(a, b)
        return a.Name < b.Name
    end)

    return results
end

function Instructions.GetCommands()
    return copyTable(commands)
end

function Instructions.SetLanguage(language)
    if type(language) ~= "string" or language == "" then
        return false, "Invalid language"
    end

    Instructions.Language = language

    return true
end

function Instructions.GetLanguage()
    return Instructions.Language
end

function Instructions.GetInfo()
    local pageCount = 0

    for _ in pairs(pages) do
        pageCount = pageCount + 1
    end

    return {
        Name = Instructions.Name,
        Version = Instructions.Version,
        Language = Instructions.Language,
        PageCount = pageCount,
        CommandCount = #commands
    }
end

return Instructions

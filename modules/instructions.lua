
-- LSAI Instructions
-- Version: 0.1.0

local Instructions = {
    Version = "0.1.0",
    Language = "en",

    Sections = {
        {
            Title = "Welcome",
            Text = "Welcome to LSAI. This utility is designed to inspect Lua source code."
        },
        {
            Title = "Security Scanner",
            Text = "The scanner analyzes source text without executing the inspected script."
        },
        {
            Title = "Device Information",
            Text = "Device information depends on the APIs available in your Lua environment."
        },
        {
            Title = "Settings",
            Text = "Use Settings to customize the interface and application preferences."
        },
        {
            Title = "Macros",
            Text = "Macros are visual instructions and are not executed as arbitrary code."
        },
        {
            Title = "Safety",
            Text = "A clean scan does not guarantee that a script is safe. Review unknown code carefully."
        }
    }
}

function Instructions:GetAll()
    return self.Sections
end

function Instructions:GetSection(index)
    return self.Sections[index]
end

function Instructions:Search(query)
    if type(query) ~= "string" then
        return {}
    end

    local results = {}
    local searchText = string.lower(query)

    for _, section in ipairs(self.Sections) do
        local title = string.lower(section.Title)
        local content = string.lower(section.Text)

        if string.find(title, searchText, 1, true)
        or string.find(content, searchText, 1, true) then
            table.insert(results, section)
        end
    end

    return results
end

return Instructions


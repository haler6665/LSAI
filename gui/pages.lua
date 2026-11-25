
--[[
    LSAI GUI Pages
    Version: 0.5.0

    Platform-independent page definitions.
]]

local Pages = {}

Pages.Name = "LSAI GUI Pages"
Pages.Version = "0.5.0"
Pages.Status = "Ready"
Pages.Current = "Main"

local Registry = {}

local function CopyTable(source)
    local result = {}

    for key, value in pairs(source) do
        if type(value) == "table" then
            result[key] = CopyTable(value)
        else
            result[key] = value
        end
    end

    return result
end

local function CreatePage(name, title, elements)
    return {
        Name = name,
        Title = title,
        Visible = false,
        Elements = elements or {}
    }
end

Registry.Main = CreatePage("Main", "LSAI", {
    {
        Type = "Label",
        ID = "welcome",
        Text = "Welcome to LSAI"
    },
    {
        Type = "Card",
        ID = "status",
        Title = "Protection status",
        Text = "Ready to scan source code",
        Status = "Ready"
    },
    {
        Type = "Button",
        ID = "start_scan",
        Text = "Import and scan",
        Action = "OpenImport"
    },
    {
        Type = "Label",
        ID = "recent_title",
        Text = "Recent scans"
    },
    {
        Type = "Label",
        ID = "recent_empty",
        Text = "No scans yet"
    }
})

Registry.Settings = CreatePage("Settings", "Settings", {
    {
        Type = "Toggle",
        ID = "animations",
        Text = "Animations",
        Setting = "Animations"
    },
    {
        Type = "Toggle",
        ID = "notifications",
        Text = "Notifications",
        Setting = "Notifications"
    },
    {
        Type = "Button",
        ID = "language",
        Text = "Language",
        Action = "OpenLanguageSelector"
    },
    {
        Type = "Button",
        ID = "theme",
        Text = "Theme",
        Action = "ToggleTheme"
    },
    {
        Type = "Label",
        ID = "settings_version",
        Text = "LSAI 0.5.0"
    }
})

Registry.Security = CreatePage("Security", "Security", {
    {
        Type = "Card",
        ID = "security_info",
        Title = "Static source analysis",
        Text = "Scans source text without executing it."
    },
    {
        Type = "Button",
        ID = "basic_scan",
        Text = "Basic scan",
        Action = "ScanBasic"
    },
    {
        Type = "Button",
        ID = "advanced_scan",
        Text = "Advanced scan",
        Action = "ScanAdvanced"
    },
    {
        Type = "Button",
        ID = "deep_scan",
        Text = "Deep scan",
        Action = "ScanDeep"
    },
    {
        Type = "Label",
        ID = "scan_note",
        Text = "A clean result does not guarantee safety."
    }
})

Registry.SavedScripts = CreatePage(
    "SavedScripts",
    "Saved Scripts",
    {
        {
            Type = "TextField",
            ID = "script_search",
            Text = "",
            Placeholder = "Search saved items..."
        },
        {
            Type = "Label",
            ID = "scripts_empty",
            Text = "No saved items"
        },
        {
            Type = "Label",
            ID = "scripts_note",
            Text = "Imported source is never executed by LSAI."
        }
    }
)

Registry.Macros = CreatePage("Macros", "Macros", {
    {
        Type = "Label",
        ID = "macro_title",
        Text = "Macro editor"
    },
    {
        Type = "Card",
        ID = "macro_info",
        Title = "Safe macro builder",
        Text = "Create inert action sequences for supported LSAI interface tasks."
    },
    {
        Type = "Button",
        ID = "new_macro",
        Text = "New macro",
        Action = "CreateMacro"
    },
    {
        Type = "Label",
        ID = "macro_empty",
        Text = "No macros created"
    }
})

function Pages.Get(name)
    if type(name) ~= "string" then
        return nil
    end

    local selected = Registry[name]

    if not selected then
        return nil
    end

    return CopyTable(selected)
end

function Pages.GetAll()
    return CopyTable(Registry)
end

function Pages.Show(name)
    if type(name) ~= "string" then
        return false, "Page name must be a string."
    end

    local selected = Registry[name]

    if not selected then
        return false, "Page not found."
    end

    for _, data in pairs(Registry) do
        data.Visible = false
    end

    selected.Visible = true
    Pages.Current = name

    return true
end

function Pages.GetCurrent()
    return Pages.Get(Pages.Current)
end

function Pages.GetNames()
    local result = {}

    for name in pairs(Registry) do
        table.insert(result, name)
    end

    table.sort(result)

    return result
end

function Pages.GetElement(pageName, elementID)
    if type(pageName) ~= "string"
        or type(elementID) ~= "string" then
        return nil
    end

    local selected = Registry[pageName]

    if not selected then
        return nil
    end

    for _, element in ipairs(selected.Elements) do
        if element.ID == elementID then
            return CopyTable(element)
        end
    end

    return nil
end

function Pages.GetPageCount()
    local count = 0

    for _ in pairs(Registry) do
        count = count + 1
    end

    return count
end

function Pages.Reset()
    return Pages.Show("Main")
end

function Pages.GetInfo()
    return {
        Name = Pages.Name,
        Version = Pages.Version,
        Status = Pages.Status,
        PageCount = Pages.GetPageCount(),
        Current = Pages.Current
    }
end

Pages.Show("Main")

return Pages

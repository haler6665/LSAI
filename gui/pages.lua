
-- LSAI GUI Pages
-- Version: 0.4.0

local Pages = {
    Version = "0.4.0",
    Current = "Main",
    Registry = {}
}

local function page(name, title, elements)
    return {
        Name = name,
        Title = title,
        Visible = false,
        Elements = elements or {}
    }
end

Pages.Registry = {
    Main = page("Main", "LSAI", {
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
    }),

    Settings = page("Settings", "Settings", {
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
            Text = "LSAI 0.4.0"
        }
    }),

    Security = page("Security", "Security", {
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
    }),

    SavedScripts = page("SavedScripts", "Saved Scripts", {
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
    }),

    Macros = page("Macros", "Macros", {
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
}

function Pages.Get(name)
    return Pages.Registry[name]
end

function Pages.GetAll()
    local result = {}

    for name, data in pairs(Pages.Registry) do
        result[name] = data
    end

    return result
end

function Pages.Show(name)
    local selected = Pages.Registry[name]

    if not selected then
        return false, "Page not found"
    end

    for _, data in pairs(Pages.Registry) do
        data.Visible = false
    end

    selected.Visible = true
    Pages.Current = name

    return true
end

function Pages.GetCurrent()
    return Pages.Registry[Pages.Current]
end

function Pages.GetNames()
    local result = {}

    for name in pairs(Pages.Registry) do
        result[#result + 1] = name
    end

    table.sort(result)

    return result
end

function Pages.Reset()
    Pages.Show("Main")
end

function Pages.GetInfo()
    local count = 0

    for _ in pairs(Pages.Registry) do
        count = count + 1
    end

    return {
        Name = "Pages",
        Version = Pages.Version,
        PageCount = count,
        Current = Pages.Current
    }
end

Pages.Show("Main")

return Pages


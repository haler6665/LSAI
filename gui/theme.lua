
--[[
    LSAI GUI Theme
    Version: 0.5.0
]]

local Theme = {}

Theme.Name = "LSAI Theme"
Theme.Version = "0.5.0"
Theme.Current = "Dark"
Theme.Status = "Ready"

local themes = {
    Dark = {
        Background = "#17191F",
        Panel = "#20232B",
        Secondary = "#292D37",
        Border = "#363B47",
        Text = "#F2F3F5",
        Muted = "#9299A8",
        Accent = "#7189FF",
        Success = "#55C995",
        Warning = "#E9B85C",
        Danger = "#E36C75"
    },

    Light = {
        Background = "#F2F3F7",
        Panel = "#FFFFFF",
        Secondary = "#E9EBF1",
        Border = "#D8DBE4",
        Text = "#20232B",
        Muted = "#777F90",
        Accent = "#536FEA",
        Success = "#299E70",
        Warning = "#C58B25",
        Danger = "#D34E5C"
    }
}

local layout = {
    Width = 330,
    Height = 430,
    HeaderHeight = 48,
    NavigationWidth = 52,
    CornerRadius = 12,
    Padding = 10,
    AnimationDuration = 0.22,
    MinimumWidth = 280,
    MinimumHeight = 360
}

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

function Theme.Get()
    local selected = themes[Theme.Current]

    if not selected then
        return nil
    end

    return CopyTable(selected)
end

function Theme.Set(name)
    if type(name) ~= "string" then
        return false, "Theme name must be a string."
    end

    if not themes[name] then
        return false, "Unknown theme."
    end

    Theme.Current = name

    return true
end

function Theme.GetAvailable()
    local result = {}

    for name in pairs(themes) do
        table.insert(result, name)
    end

    table.sort(result)

    return result
end

function Theme.GetLayout()
    return CopyTable(layout)
end

function Theme.SetLayoutValue(key, value)
    if type(key) ~= "string" then
        return false, "Layout key must be a string."
    end

    if layout[key] == nil then
        return false, "Unknown layout setting."
    end

    if type(value) ~= "number" or value <= 0 then
        return false, "Value must be a positive number."
    end

    layout[key] = value

    return true
end

function Theme.ResetLayout()
    layout = {
        Width = 330,
        Height = 430,
        HeaderHeight = 48,
        NavigationWidth = 52,
        CornerRadius = 12,
        Padding = 10,
        AnimationDuration = 0.22,
        MinimumWidth = 280,
        MinimumHeight = 360
    }

    return true
end

function Theme.GetInfo()
    return {
        Name = Theme.Name,
        Version = Theme.Version,
        Current = Theme.Current,
        Status = Theme.Status,
        AvailableThemes = #Theme.GetAvailable()
    }
end

return Theme


-- LSAI GUI Theme
-- Version: 0.4.0

local Theme = {
    Version = "0.4.0",

    Current = "Dark",

    Themes = {
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
    },

    Layout = {
        Width = 330,
        Height = 430,
        HeaderHeight = 48,
        NavigationWidth = 52,
        CornerRadius = 12,
        Padding = 10,
        AnimationDuration = 0.22
    }
}

function Theme.Get()
    return Theme.Themes[Theme.Current]
end

function Theme.Set(name)
    if not Theme.Themes[name] then
        return false, "Unknown theme"
    end

    Theme.Current = name
    return true
end

function Theme.GetLayout()
    local result = {}

    for key, value in pairs(Theme.Layout) do
        result[key] = value
    end

    return result
end

function Theme.GetInfo()
    return {
        Name = "Theme",
        Version = Theme.Version,
        Current = Theme.Current
    }
end

return Theme


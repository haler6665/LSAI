
--[[
    LSAI GUI Adapter
    Version: 0.5.0
    Backend: LÖVE (Love2D)

    Handles rendering and mouse interaction.
    Does not execute imported source code.
]]

local Adapter = {
    Name = "LSAI GUI Adapter",
    Version = "0.5.0",
    Status = "NotInitialized",

    Width = 330,
    Height = 430,

    Visible = false,
    CurrentPage = "Main",
    State = nil,

    Animation = {
        Enabled = true,
        Progress = 0,
        Target = 0,
        Speed = 5
    },

    Buttons = {}
}

local function IsLoveAvailable()
    return type(love) == "table"
        and type(love.graphics) == "table"
end

local function Color(hex, alpha)
    if not IsLoveAvailable() then
        return false
    end

    if type(hex) ~= "string" then
        hex = "#FFFFFF"
    end

    hex = hex:gsub("#", "")

    if #hex ~= 6 then
        hex = "FFFFFF"
    end

    local r = tonumber(hex:sub(1, 2), 16) or 255
    local g = tonumber(hex:sub(3, 4), 16) or 255
    local b = tonumber(hex:sub(5, 6), 16) or 255

    love.graphics.setColor(
        r / 255,
        g / 255,
        b / 255,
        alpha or 1
    )

    return true
end

local function Text(value, x, y, tint)
    Color(tint or "#F2F3F5")

    love.graphics.print(
        tostring(value or ""),
        x,
        y
    )
end

local function AddButton(id, label, x, y, width, height, tint)
    Color(tint or "#292D37")

    love.graphics.rectangle(
        "fill",
        x,
        y,
        width,
        height,
        7
    )

    Text(label, x + 12, y + 11)

    Adapter.Buttons[#Adapter.Buttons + 1] = {
        ID = id,
        X = x,
        Y = y,
        Width = width,
        Height = height
    }
end

local function GetTheme()
    local state = Adapter.State or {}
    local theme = state.Theme

    if type(theme) == "table" then
        return theme
    end

    return {
        Background = "#17191F",
        Panel = "#20232B",
        Secondary = "#292D37",
        Border = "#363B47",
        Text = "#F2F3F5",
        Muted = "#9299A8",
        Accent = "#7189FF"
    }
end

local function DispatchAction(gui, action)
    if type(gui) ~= "table" then
        return false
    end

    if type(gui.HandleAction) == "function" then
        return gui.HandleAction(action)
    end

    return false
end

function Adapter.Initialize()
    if not IsLoveAvailable() then
        Adapter.Status = "Error"
        return false, "LÖVE graphics API is unavailable."
    end

    Adapter.Status = "Ready"

    return true
end

function Adapter.Open(animated)
    Adapter.Visible = true
    Adapter.Animation.Enabled = animated ~= false
    Adapter.Animation.Target = 1

    if not Adapter.Animation.Enabled then
        Adapter.Animation.Progress = 1
    end

    return true
end

function Adapter.Close(animated)
    Adapter.Animation.Enabled = animated ~= false
    Adapter.Animation.Target = 0

    if not Adapter.Animation.Enabled then
        Adapter.Animation.Progress = 0
        Adapter.Visible = false
    end

    return true
end

function Adapter.Render(state)
    if state ~= nil and type(state) ~= "table" then
        return false, "State must be a table."
    end

    Adapter.State = state or {}

    Adapter.CurrentPage =
        Adapter.State.CurrentPage or "Main"

    local width = tonumber(Adapter.State.Width)
    local height = tonumber(Adapter.State.Height)

    if width and width > 0 then
        Adapter.Width = width
    end

    if height and height > 0 then
        Adapter.Height = height
    end

    return true
end

function Adapter.Update(dt)
    if type(dt) ~= "number" or dt < 0 then
        return false
    end

    local animation = Adapter.Animation

    if not animation.Enabled then
        animation.Progress = animation.Target

        if animation.Target == 0 then
            Adapter.Visible = false
        end

        return true
    end

    if animation.Progress == animation.Target then
        return true
    end

    local difference =
        animation.Target - animation.Progress

    local step = animation.Speed * dt

    if math.abs(difference) <= step then
        animation.Progress = animation.Target
    elseif difference > 0 then
        animation.Progress = animation.Progress + step
    else
        animation.Progress = animation.Progress - step
    end

    if animation.Progress <= 0
        and animation.Target == 0 then
        Adapter.Visible = false
    end

    return true
end

function Adapter.Draw()
    if not IsLoveAvailable() then
        return false
    end

    if not Adapter.Visible
        and Adapter.Animation.Progress <= 0 then
        return true
    end

    local theme = GetTheme()

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local progress = Adapter.Animation.Progress

    local panelX =
        screenWidth - Adapter.Width * progress

    local panelY =
        (screenHeight - Adapter.Height) / 2

    local bg = theme.Background or "#17191F"
    local panel = theme.Panel or "#20232B"
    local secondary = theme.Secondary or "#292D37"
    local muted = theme.Muted or "#9299A8"
    local accent = theme.Accent or "#7189FF"

    Adapter.Buttons = {}

    love.graphics.push()
    love.graphics.translate(panelX, panelY)

    Color(bg)

    love.graphics.rectangle(
        "fill",
        0,
        0,
        Adapter.Width,
        Adapter.Height,
        12
    )

    Color(panel)

    love.graphics.rectangle(
        "fill",
        0,
        0,
        Adapter.Width,
        48,
        12
    )

    Text("LSAI", 14, 15)
    Text("×", Adapter.Width - 27, 12, muted)

    Adapter.Buttons[#Adapter.Buttons + 1] = {
        ID = "close",
        X = Adapter.Width - 42,
        Y = 0,
        Width = 42,
        Height = 48
    }

    local page = Adapter.CurrentPage

    if page == "Main" then
        Text("Welcome to LSAI", 14, 68)
        Text("Static Lua source analyzer", 14, 94, muted)

        Color(secondary)

        love.graphics.rectangle(
            "fill",
            12,
            128,
            Adapter.Width - 24,
            68,
            8
        )

        Text("Protection status", 24, 140)
        Text("Ready to scan source code", 24, 165, muted)

        AddButton(
            "scan",
            "Import and scan",
            12,
            210,
            Adapter.Width - 24,
            42,
            accent
        )

        Text("Recent scans", 14, 275)
        Text("No scans yet", 14, 302, muted)

        local nav = {
            {"page_settings", "Settings"},
            {"page_security", "Security"},
            {"page_saved", "Saved Scripts"},
            {"page_macros", "Macros"}
        }

        for index, item in ipairs(nav) do
            AddButton(
                item[1],
                item[2],
                12,
                330 + (index - 1) * 24,
                Adapter.Width - 24,
                22,
                panel
            )
        end

    elseif page == "Settings" then
        Text("Settings", 14, 68)

        AddButton("back", "< Back", 12, 105, 306, 38)
        AddButton("animations", "Toggle animations", 12, 155, 306, 38)
        AddButton("notifications", "Toggle notifications", 12, 202, 306, 38)
        AddButton("language", "Language", 12, 249, 306, 38)
        AddButton("theme", "Change theme", 12, 296, 306, 38)

    elseif page == "Security" then
        Text("Security scanner", 14, 68)

        AddButton("back", "< Back", 12, 105, 306, 38)
        AddButton("basic", "Basic scan", 12, 155, 306, 38)
        AddButton("advanced", "Advanced scan", 12, 202, 306, 38)
        AddButton("deep", "Deep scan", 12, 249, 306, 38)

        Text("Scans source text only.", 14, 310, muted)

    elseif page == "SavedScripts" then
        Text("Saved Scripts", 14, 68)

        AddButton("back", "< Back", 12, 105, 306, 38)
        AddButton("search", "Search saved items", 12, 155, 306, 38)

        Text("No saved items", 14, 210, muted)

    elseif page == "Macros" then
        Text("Macro editor", 14, 68)

        AddButton("back", "< Back", 12, 105, 306, 38)
        AddButton("new_macro", "New macro", 12, 155, 306, 38)

        Text("No macros created", 14, 210, muted)
    end

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)

    return true
end

function Adapter.MousePressed(x, y, gui)
    if not IsLoveAvailable() then
        return false
    end

    if not Adapter.Visible then
        return false
    end

    if type(x) ~= "number" or type(y) ~= "number" then
        return false
    end

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local panelX =
        screenWidth - Adapter.Width * Adapter.Animation.Progress

    local panelY =
        (screenHeight - Adapter.Height) / 2

    local localX = x - panelX
    local localY = y - panelY

    for _, item in ipairs(Adapter.Buttons) do
        local inside =
            localX >= item.X
            and localX <= item.X + item.Width
            and localY >= item.Y
            and localY <= item.Y + item.Height

        if inside then
            if item.ID == "close" then
                if gui and type(gui.Close) == "function" then
                    gui.Close()
                end

            elseif item.ID == "back" then
                if gui and type(gui.GoBack) == "function" then
                    gui.GoBack()
                end

            elseif item.ID == "page_settings" then
                gui.ShowPage("Settings")

            elseif item.ID == "page_security" then
                gui.ShowPage("Security")

            elseif item.ID == "page_saved" then
                gui.ShowPage("SavedScripts")

            elseif item.ID == "page_macros" then
                gui.ShowPage("Macros")

            elseif item.ID == "theme" then
                if gui and type(gui.ToggleTheme) == "function" then
                    gui.ToggleTheme()
                else
                    DispatchAction(gui, "ToggleTheme")
                end

            else
                local actions = {
                    scan = "OpenImport",
                    animations = "ToggleAnimations",
                    notifications = "ToggleNotifications",
                    language = "OpenLanguageSelector",
                    basic = "ScanBasic",
                    advanced = "ScanAdvanced",
                    deep = "ScanDeep",
                    search = "SearchSavedItems",
                    new_macro = "CreateMacro"
                }

                local action = actions[item.ID]

                if action then
                    DispatchAction(gui, action)
                end
            end

            return true, item.ID
        end
    end

    return false
end

function Adapter.GetStatus()
    return Adapter.Status
end

function Adapter.GetInfo()
    return {
        Name = Adapter.Name,
        Version = Adapter.Version,
        Status = Adapter.Status,
        Backend = "LÖVE",
        Width = Adapter.Width,
        Height = Adapter.Height,
        Visible = Adapter.Visible
    }
end

return Adapter


-- LSAI GUI Adapter
-- Version: 0.4.1
-- Backend: LÖVE (Love2D)

local Adapter = {
    Version = "0.4.1",
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

local function color(hex)
    hex = hex:gsub("#", "")

    local r = tonumber(hex:sub(1, 2), 16) or 0
    local g = tonumber(hex:sub(3, 4), 16) or 0
    local b = tonumber(hex:sub(5, 6), 16) or 0

    love.graphics.setColor(r / 255, g / 255, b / 255)
end

local function text(value, x, y, tint)
    color(tint or "#F2F3F5")
    love.graphics.print(tostring(value or ""), x, y)
end

local function button(id, label, x, y, width, height, tint)
    color(tint or "#292D37")
    love.graphics.rectangle("fill", x, y, width, height, 7)

    text(label, x + 12, y + 11)

    Adapter.Buttons[#Adapter.Buttons + 1] = {
        ID = id,
        X = x,
        Y = y,
        Width = width,
        Height = height
    }
end

function Adapter.Initialize()
    if not love or not love.graphics then
        Adapter.Status = "Error"
        return false, "LÖVE graphics API is unavailable"
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
    Adapter.State = state or {}
    Adapter.CurrentPage = Adapter.State.CurrentPage or "Main"
    Adapter.Width = Adapter.State.Width or Adapter.Width
    Adapter.Height = Adapter.State.Height or Adapter.Height

    return true
end

function Adapter.Update(dt)
    local animation = Adapter.Animation

    if animation.Progress == animation.Target then
        return
    end

    local difference = animation.Target - animation.Progress
    local step = animation.Speed * dt

    if math.abs(difference) <= step then
        animation.Progress = animation.Target
    elseif difference > 0 then
        animation.Progress = animation.Progress + step
    else
        animation.Progress = animation.Progress - step
    end

    if animation.Progress <= 0 and animation.Target == 0 then
        Adapter.Visible = false
    end
end

function Adapter.Draw()
    if not Adapter.Visible and Adapter.Animation.Progress <= 0 then
        return
    end

    local state = Adapter.State or {}
    local theme = state.Theme or {}

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local progress = Adapter.Animation.Progress

    local panelX = screenWidth - Adapter.Width * progress
    local panelY = (screenHeight - Adapter.Height) / 2

    local bg = theme.Background or "#17191F"
    local panel = theme.Panel or "#20232B"
    local secondary = theme.Secondary or "#292D37"
    local muted = theme.Muted or "#9299A8"
    local accent = theme.Accent or "#7189FF"

    Adapter.Buttons = {}

    love.graphics.push()
    love.graphics.translate(panelX, panelY)

    color(bg)
    love.graphics.rectangle(
        "fill", 0, 0,
        Adapter.Width, Adapter.Height, 12
    )

    color(panel)
    love.graphics.rectangle(
        "fill", 0, 0,
        Adapter.Width, 48, 12
    )

    text("LSAI", 14, 15)
    text("×", Adapter.Width - 27, 12, muted)

    Adapter.Buttons[#Adapter.Buttons + 1] = {
        ID = "close",
        X = Adapter.Width - 42,
        Y = 0,
        Width = 42,
        Height = 48
    }

    local page = Adapter.CurrentPage

    if page == "Main" then
        text("Welcome to LSAI", 14, 68)
        text("Static Lua source analyzer", 14, 94, muted)

        color(secondary)
        love.graphics.rectangle("fill", 12, 128, 306, 68, 8)

        text("Protection status", 24, 140)
        text("Ready to scan source code", 24, 165, muted)

        button("scan", "Import and scan", 12, 210, 306, 42, accent)

        text("Recent scans", 14, 275)
        text("No scans yet", 14, 302, muted)

        local nav = {
            {"settings", "Settings"},
            {"security", "Security"},
            {"saved", "Saved Scripts"},
            {"macros", "Macros"}
        }

        for index, item in ipairs(nav) do
            button(
                "page_" .. item[1],
                item[2],
                12,
                330 + (index - 1) * 24,
                306,
                22,
                panel
            )
        end

    elseif page == "Settings" then
        text("Settings", 14, 68)
        button("back", "< Back", 12, 105, 306, 38)
        button("animations", "Toggle animations", 12, 155, 306, 38)
        button("notifications", "Toggle notifications", 12, 202, 306, 38)
        button("language", "Language", 12, 249, 306, 38)
        button("theme", "Change theme", 12, 296, 306, 38)

    elseif page == "Security" then
        text("Security scanner", 14, 68)
        button("back", "< Back", 12, 105, 306, 38)
        button("basic", "Basic scan", 12, 155, 306, 38)
        button("advanced", "Advanced scan", 12, 202, 306, 38)
        button("deep", "Deep scan", 12, 249, 306, 38)
        text("Scans source text only.", 14, 310, muted)

    elseif page == "SavedScripts" then
        text("Saved Scripts", 14, 68)
        button("back", "< Back", 12, 105, 306, 38)
        button("search", "Search saved items", 12, 155, 306, 38)
        text("No saved items", 14, 210, muted)

    elseif page == "Macros" then
        text("Macro editor", 14, 68)
        button("back", "< Back", 12, 105, 306, 38)
        button("new_macro", "New macro", 12, 155, 306, 38)
        text("No macros created", 14, 210, muted)
    end

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function Adapter.MousePressed(x, y, gui)
    if not Adapter.Visible then
        return false
    end

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local panelX = screenWidth - Adapter.Width * Adapter.Animation.Progress
    local panelY = (screenHeight - Adapter.Height) / 2

    local localX = x - panelX
    local localY = y - panelY

    for _, item in ipairs(Adapter.Buttons) do
        local inside =
            localX >= item.X and
            localX <= item.X + item.Width and
            localY >= item.Y and
            localY <= item.Y + item.Height

        if inside then
            if item.ID == "close" then
                gui.Close()
            elseif item.ID == "back" then
                gui.GoBack()
            elseif item.ID == "page_settings" then
                gui.ShowPage("Settings")
            elseif item.ID == "page_security" then
                gui.ShowPage("Security")
            elseif item.ID == "page_saved" then
                gui.ShowPage("SavedScripts")
            elseif item.ID == "page_macros" then
                gui.ShowPage("Macros")
            elseif item.ID == "theme" then
                local current = gui.GetState()
                gui.SetTheme(current.Theme == "Light" and "Dark" or "Light")
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
        Name = "Love2D Adapter",
        Version = Adapter.Version,
        Status = Adapter.Status
    }
end

return Adapter

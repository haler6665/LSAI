
-- LSAI GUI Adapter
-- Version: 0.4.0
-- Backend: LÖVE (Love2D)

local Adapter = {
    Version = "0.4.0",
    Status = "NotInitialized",

    Width = 330,
    Height = 430,

    Visible = false,
    CurrentPage = "Main",

    Animation = {
        Enabled = true,
        Progress = 0,
        Target = 0,
        Speed = 5
    },

    State = nil
}

local function getColor(hex)
    hex = hex:gsub("#", "")

    local r = tonumber(hex:sub(1, 2), 16) or 0
    local g = tonumber(hex:sub(3, 4), 16) or 0
    local b = tonumber(hex:sub(5, 6), 16) or 0

    return r / 255, g / 255, b / 255
end

local function setColor(hex)
    love.graphics.setColor(getColor(hex))
end

local function drawText(text, x, y, color, font)
    setColor(color or "#F2F3F5")
    love.graphics.setFont(font or love.graphics.getFont())
    love.graphics.print(tostring(text or ""), x, y)
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

    if Adapter.Animation.Enabled then
        Adapter.Animation.Target = 1
    else
        Adapter.Animation.Progress = 1
        Adapter.Animation.Target = 1
    end

    return true
end

function Adapter.Close(animated)
    Adapter.Animation.Enabled = animated ~= false

    if Adapter.Animation.Enabled then
        Adapter.Animation.Target = 0
    else
        Adapter.Animation.Progress = 0
        Adapter.Animation.Target = 0
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
    if not Adapter.Visible and Adapter.Animation.Target == 0 then
        return
    end

    local animation = Adapter.Animation

    if animation.Enabled then
        local difference = animation.Target - animation.Progress
        local step = animation.Speed * dt

        if math.abs(difference) <= step then
            animation.Progress = animation.Target
        elseif difference > 0 then
            animation.Progress = animation.Progress + step
        else
            animation.Progress = animation.Progress - step
        end
    else
        animation.Progress = animation.Target
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
    local x = screenWidth - Adapter.Width * progress
    local y = (screenHeight - Adapter.Height) / 2

    local background = theme.Background or "#17191F"
    local panel = theme.Panel or "#20232B"
    local secondary = theme.Secondary or "#292D37"
    local border = theme.Border or "#363B47"
    local text = theme.Text or "#F2F3F5"
    local muted = theme.Muted or "#9299A8"
    local accent = theme.Accent or "#7189FF"

    love.graphics.push()
    love.graphics.translate(x, y)

    setColor(background)
    love.graphics.rectangle(
        "fill", 0, 0,
        Adapter.Width, Adapter.Height, 12
    )

    setColor(border)
    love.graphics.rectangle(
        "line", 0, 0,
        Adapter.Width, Adapter.Height, 12
    )

    setColor(panel)
    love.graphics.rectangle(
        "fill", 0, 0,
        Adapter.Width, 48, 12
    )

    drawText("LSAI", 14, 15, text)
    drawText("×", Adapter.Width - 28, 10, muted)

    local page = Adapter.CurrentPage

    if page == "Main" then
        drawText("Welcome to LSAI", 14, 70, text)
        drawText("Static Lua source analyzer", 14, 96, muted)

        setColor(secondary)
        love.graphics.rectangle("fill", 12, 132, 306, 76, 8)

        drawText("Protection status", 24, 145, text)
        drawText("Ready to scan source code", 24, 170, muted)

        setColor(accent)
        love.graphics.rectangle("fill", 12, 224, 306, 42, 8)
        drawText("Import and scan", 92, 236, "#FFFFFF")

        drawText("Recent scans", 14, 292, text)
        drawText("No scans yet", 14, 320, muted)

    elseif page == "Settings" then
        drawText("Settings", 14, 70, text)
        drawText("Animations", 14, 112, muted)
        drawText("Notifications", 14, 158, muted)
        drawText("Language", 14, 204, muted)
        drawText("Theme", 14, 250, muted)

    elseif page == "Security" then
        drawText("Security scanner", 14, 70, text)
        drawText("Basic scan", 14, 120, muted)
        drawText("Advanced scan", 14, 168, muted)
        drawText("Deep scan", 14, 216, muted)
        drawText("Source code is never executed.", 14, 290, muted)

    elseif page == "SavedScripts" then
        drawText("Saved Scripts", 14, 70, text)
        drawText("Search saved items...", 14, 116, muted)
        drawText("No saved items", 14, 170, muted)

    elseif page == "Macros" then
        drawText("Macro editor", 14, 70, text)
        drawText("Safe macro builder", 14, 116, muted)
        drawText("No macros created", 14, 170, muted)
    end

    -- Bottom navigation
    setColor(panel)
    love.graphics.rectangle(
        "fill", 0, Adapter.Height - 48,
        Adapter.Width, 48
    )

    drawText("<", 16, Adapter.Height - 33, muted)
    drawText(page, 52, Adapter.Height - 33, accent)

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
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

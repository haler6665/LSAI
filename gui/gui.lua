
-- LSAI GUI Controller
-- Version: 0.4.0
-- Universal GUI controller
-- No Roblox or executor dependencies.

local GUI = {
    Name = "LSAI GUI",
    Version = "0.4.0",
    Status = "NotInitialized",

    Visible = false,
    CurrentPage = "Main",
    AnimationEnabled = true,

    Width = 330,
    Height = 430,

    Position = "Right",
    Components = {}
}

local Theme
local ComponentLibrary
local Pages
local Adapter

local function callAdapter(method, ...)
    if not Adapter then
        return true
    end

    local callback = Adapter[method]

    if type(callback) ~= "function" then
        return true
    end

    local success, result = pcall(callback, ...)

    if not success then
        GUI.Status = "AdapterError"
        return false, result
    end

    return true, result
end

local function render()
    if not Adapter then
        return true, "No GUI adapter connected"
    end

    return callAdapter("Render", {
        Name = GUI.Name,
        Version = GUI.Version,
        Visible = GUI.Visible,
        CurrentPage = GUI.CurrentPage,
        Width = GUI.Width,
        Height = GUI.Height,
        Position = GUI.Position,
        AnimationEnabled = GUI.AnimationEnabled,

        Theme = Theme and Theme.Get() or {},
        Pages = Pages and Pages.GetAll() or {},
        Components = ComponentLibrary
            and ComponentLibrary.GetAll() or {}
    })
end

function GUI.Initialize(dependencies)
    dependencies = dependencies or {}

    Theme = dependencies.Theme
    ComponentLibrary = dependencies.Components
    Pages = dependencies.Pages
    Adapter = dependencies.Adapter

    if not Theme then
        GUI.Status = "Error"
        return false, "Theme module is required"
    end

    if not ComponentLibrary then
        GUI.Status = "Error"
        return false, "Components module is required"
    end

    if not Pages then
        GUI.Status = "Error"
        return false, "Pages module is required"
    end

    if Adapter and type(Adapter.Render) ~= "function" then
        GUI.Status = "Error"
        return false, "Adapter.Render is required"
    end

    Pages.Reset()
    GUI.CurrentPage = "Main"
    GUI.Visible = false
    GUI.Status = "Ready"

    return render()
end

function GUI.Open()
    if GUI.Status == "NotInitialized" then
        return false, "GUI is not initialized"
    end

    GUI.Visible = true
    Pages.Show("Main")
    GUI.CurrentPage = "Main"

    local success, result = callAdapter(
        "Open",
        GUI.AnimationEnabled
    )

    if not success then
        return false, result
    end

    return render()
end

function GUI.Close()
    GUI.Visible = false

    local success, result = callAdapter(
        "Close",
        GUI.AnimationEnabled
    )

    if not success then
        return false, result
    end

    return render()
end

function GUI.Toggle()
    if GUI.Visible then
        return GUI.Close()
    end

    return GUI.Open()
end

function GUI.ShowPage(name)
    if not GUI.Visible then
        return false, "GUI is closed"
    end

    local success, result = Pages.Show(name)

    if not success then
        return false, result
    end

    GUI.CurrentPage = name

    return render()
end

function GUI.GoBack()
    return GUI.ShowPage("Main")
end

function GUI.SetTheme(name)
    local success, result = Theme.Set(name)

    if not success then
        return false, result
    end

    return render()
end

function GUI.SetAnimation(enabled)
    if type(enabled) ~= "boolean" then
        return false, "Expected boolean"
    end

    GUI.AnimationEnabled = enabled
    return true
end

function GUI.SetSize(width, height)
    width = tonumber(width)
    height = tonumber(height)

    if not width or not height then
        return false, "Invalid dimensions"
    end

    if width < 250 or width > 600 then
        return false, "Width is out of range"
    end

    if height < 300 or height > 800 then
        return false, "Height is out of range"
    end

    GUI.Width = width
    GUI.Height = height

    return render()
end

function GUI.Refresh()
    return render()
end

function GUI.GetState()
    return {
        Name = GUI.Name,
        Version = GUI.Version,
        Status = GUI.Status,
        Visible = GUI.Visible,
        CurrentPage = GUI.CurrentPage,
        Width = GUI.Width,
        Height = GUI.Height,
        AnimationEnabled = GUI.AnimationEnabled
    }
end

function GUI.GetInfo()
    return {
        Name = GUI.Name,
        Version = GUI.Version,
        Status = GUI.Status,
        CurrentPage = GUI.CurrentPage,
        Visible = GUI.Visible
    }
end

return GUI

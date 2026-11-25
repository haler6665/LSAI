--[[
    LSAI GUI Controller
    Version: 0.5.0

    Platform-independent GUI controller.
    No Roblox or executor dependencies.
]]

local GUI = {
    Name = "LSAI GUI",
    Version = "0.5.0",
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

    local success, result, extra = pcall(callback, ...)

    if not success then
        GUI.Status = "AdapterError"
        return false, result
    end

    return result ~= false, extra or result
end

local function render()
    if not Adapter then
        return true, "No GUI adapter connected"
    end

    local state = {
        Name = GUI.Name,
        Version = GUI.Version,
        Visible = GUI.Visible,
        CurrentPage = GUI.CurrentPage,
        Width = GUI.Width,
        Height = GUI.Height,
        Position = GUI.Position,
        AnimationEnabled = GUI.AnimationEnabled,

        Theme = Theme and Theme.Get() or {},
        ThemeName = Theme and Theme.Current or "Dark",

        Pages = Pages and Pages.GetAll() or {},
        Components = ComponentLibrary
            and ComponentLibrary.GetAll() or {}
    }

    return callAdapter("Render", state)
end

function GUI.Initialize(dependencies)
    if type(dependencies) ~= "table" then
        dependencies = {}
    end

    Theme = dependencies.Theme
    ComponentLibrary = dependencies.Components
    Pages = dependencies.Pages
    Adapter = dependencies.Adapter

    if type(Theme) ~= "table"
        or type(Theme.Get) ~= "function"
        or type(Theme.Set) ~= "function" then
        GUI.Status = "Error"
        return false, "Valid Theme module is required."
    end

    if type(ComponentLibrary) ~= "table"
        or type(ComponentLibrary.GetAll) ~= "function" then
        GUI.Status = "Error"
        return false, "Valid Components module is required."
    end

    if type(Pages) ~= "table"
        or type(Pages.Show) ~= "function"
        or type(Pages.Reset) ~= "function"
        or type(Pages.GetAll) ~= "function" then
        GUI.Status = "Error"
        return false, "Valid Pages module is required."
    end

    if Adapter ~= nil then
        if type(Adapter.Render) ~= "function" then
            GUI.Status = "Error"
            return false, "Adapter.Render is required."
        end

        if type(Adapter.Initialize) == "function" then
            local ok, result, reason =
                pcall(Adapter.Initialize)

            if not ok or result == false then
                GUI.Status = "AdapterError"
                return false, reason or result
            end
        end
    end

    local resetSuccess, resetError = Pages.Reset()

    if resetSuccess == false then
        GUI.Status = "Error"
        return false, resetError
    end

    GUI.CurrentPage = "Main"
    GUI.Visible = false
    GUI.Status = "Ready"

    return render()
end

function GUI.SetAdapter(adapter)
    if type(adapter) ~= "table" then
        return false, "Adapter must be a table."
    end

    if type(adapter.Render) ~= "function" then
        return false, "Adapter.Render is required."
    end

    Adapter = adapter

    if type(Adapter.Initialize) == "function" then
        local success, result, reason =
            pcall(Adapter.Initialize)

        if not success or result == false then
            GUI.Status = "AdapterError"
            return false, reason or result
        end
    end

    GUI.Status = "Ready"

    return render()
end

function GUI.Open()
    if GUI.Status == "NotInitialized"
        or GUI.Status == "Error" then
        return false, "GUI is not initialized."
    end

    GUI.Visible = true

    if Pages then
        Pages.Show("Main")
    end

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
    if GUI.Status == "NotInitialized" then
        return false, "GUI is not initialized."
    end

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
        return false, "GUI is closed."
    end

    if not Pages then
        return false, "Pages module is unavailable."
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
    if not Theme then
        return false, "Theme module is unavailable."
    end

    local success, result = Theme.Set(name)

    if not success then
        return false, result
    end

    return render()
end

function GUI.ToggleTheme()
    if not Theme then
        return false, "Theme module is unavailable."
    end

    local current = Theme.Current
    local nextTheme = current == "Dark" and "Light" or "Dark"

    return GUI.SetTheme(nextTheme)
end

function GUI.SetAnimation(enabled)
    if type(enabled) ~= "boolean" then
        return false, "Expected boolean."
    end

    GUI.AnimationEnabled = enabled

    return render()
end

function GUI.SetSize(width, height)
    width = tonumber(width)
    height = tonumber(height)

    if not width or not height then
        return false, "Invalid dimensions."
    end

    if width < 250 or width > 600 then
        return false, "Width is out of range."
    end

    if height < 300 or height > 800 then
        return false, "Height is out of range."
    end

    GUI.Width = width
    GUI.Height = height

    return render()
end

function GUI.HandleAction(action)
    if type(action) ~= "string" then
        return false, "Action must be a string."
    end

    local actions = {
        ToggleTheme = function()
            return GUI.ToggleTheme()
        end,

        ToggleAnimations = function()
            return GUI.SetAnimation(
                not GUI.AnimationEnabled
            )
        end,

        OpenImport = function()
            return false, "Import screen is not implemented yet."
        end,

        OpenLanguageSelector = function()
            return false, "Language selector screen is not connected yet."
        end,

        ScanBasic = function()
            return false, "Scanner integration is not implemented yet."
        end,

        ScanAdvanced = function()
            return false, "Advanced scan is not implemented yet."
        end,

        ScanDeep = function()
            return false, "Deep scan is not implemented yet."
        end,

        ToggleNotifications = function()
            return false, "Notifications are not connected yet."
        end,

        SearchSavedItems = function()
            return false, "Saved items are not connected yet."
        end,

        CreateMacro = function()
            return false, "Macro editor is not connected yet."
        end
    }

    local callback = actions[action]

    if not callback then
        return false, "Unknown action."
    end

    local success, result, reason = pcall(callback)

    if not success then
        return false, result
    end

    return result, reason
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
        Position = GUI.Position,
        AnimationEnabled = GUI.AnimationEnabled,
        Theme = Theme and Theme.Current or "Dark"
    }
end

function GUI.GetInfo()
    return {
        Name = GUI.Name,
        Version = GUI.Version,
        Status = GUI.Status,
        CurrentPage = GUI.CurrentPage,
        Visible = GUI.Visible,
        AdapterConnected = Adapter ~= nil
    }
end

return GUI


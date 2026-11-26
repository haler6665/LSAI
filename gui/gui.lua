
--[[
    LSAI GUI Controller
    Version: 0.6.0

    Platform-independent GUI controller.
    No Roblox or executor dependencies.

    Important:
    - Does not execute imported scripts.
    - Real-Time Scanner is a setting placeholder.
    - Privacy Shield is a UI setting, not an actual sandbox.
]]

local GUI = {
    Name = "LSAI GUI",
    Version = "0.6.0",
    Status = "NotInitialized",

    Visible = false,
    CurrentPage = "Main",
    AnimationEnabled = true,

    Width = 330,
    Height = 470,

    Position = "Right",
    Components = {},

    RealTimeScannerEnabled = false,
    PrivacyShieldEnabled = false,
    NotificationsEnabled = true,

    SecurityStatus = {
        Level = "GRAY",
        Score = 0,
        Count = 0,
        Message = "Not scanned"
    }
}

local Theme
local ComponentLibrary
local Pages
local Adapter

local function safeCall(callback, ...)
    if type(callback) ~= "function" then
        return false, "Callback is unavailable."
    end

    local success, result, extra = pcall(callback, ...)

    if not success then
        GUI.Status = "Error"
        return false, result
    end

    return result ~= false, extra or result
end

local function callAdapter(method, ...)
    if not Adapter then
        return true, "No GUI adapter connected."
    end

    local callback = Adapter[method]

    if type(callback) ~= "function" then
        return true, "Adapter method unavailable."
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
        return true, "No GUI adapter connected."
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
            and ComponentLibrary.GetAll() or {},

        RealTimeScannerEnabled =
            GUI.RealTimeScannerEnabled,

        PrivacyShieldEnabled =
            GUI.PrivacyShieldEnabled,

        NotificationsEnabled =
            GUI.NotificationsEnabled,

        SecurityStatus = GUI.SecurityStatus
    }

    return callAdapter("Render", state)
end

local function showPage(name)
    if not Pages then
        return false, "Pages module is unavailable."
    end

    if type(name) ~= "string" then
        return false, "Invalid page name."
    end

    local success, result = safeCall(Pages.Show, name)

    if not success then
        return false, result
    end

    GUI.CurrentPage = name

    return render()
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
            local success, result, reason =
                pcall(Adapter.Initialize)

            if not success or result == false then
                GUI.Status = "AdapterError"
                return false, reason or result
            end
        end
    end

    local resetSuccess, resetError =
        safeCall(Pages.Reset)

    if not resetSuccess then
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
        local success, result =
            safeCall(Pages.Show, "Main")

        if not success then
            return false, result
        end
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

    return showPage(name)
end

function GUI.GoBack()
    return GUI.ShowPage("Main")
end

function GUI.SetTheme(name)
    if not Theme then
        return false, "Theme module is unavailable."
    end

    local success, result = safeCall(Theme.Set, name)

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
    local nextTheme =
        current == "Dark" and "Light" or "Dark"

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

-- These settings only change the GUI state.
-- They do not provide real runtime protection.

function GUI.SetRealTimeScanner(enabled)
    if type(enabled) ~= "boolean" then
        return false, "Expected boolean."
    end

    GUI.RealTimeScannerEnabled = enabled

    return render()
end

function GUI.SetPrivacyShield(enabled)
    if type(enabled) ~= "boolean" then
        return false, "Expected boolean."
    end

    GUI.PrivacyShieldEnabled = enabled

    return render()
end

function GUI.SetNotifications(enabled)
    if type(enabled) ~= "boolean" then
        return false, "Expected boolean."
    end

    GUI.NotificationsEnabled = enabled

    return render()
end

function GUI.SetSecurityStatus(status)
    if type(status) ~= "table" then
        return false, "Status must be a table."
    end

    local allowedLevels = {
        GREEN = true,
        YELLOW = true,
        RED = true,
        GRAY = true
    }

    local level = string.upper(
        tostring(status.Level or "GRAY")
    )

    if not allowedLevels[level] then
        level = "GRAY"
    end

    GUI.SecurityStatus = {
        Level = level,
        Score = tonumber(status.Score) or 0,
        Count = tonumber(status.Count) or 0,
        Message = tostring(
            status.Message or "No details available"
        )
    }

    return callAdapter(
        "SetSecurityStatus",
        GUI.SecurityStatus
    )
end

function GUI.ShowNotification(message, notificationType)
    if not GUI.NotificationsEnabled then
        return false, "Notifications are disabled."
    end

    if type(message) ~= "string" then
        return false, "Message must be a string."
    end

    return callAdapter(
        "ShowNotification",
        message,
        notificationType or "INFO"
    )
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

        ToggleRealTimeScanner = function()
            return GUI.SetRealTimeScanner(
                not GUI.RealTimeScannerEnabled
            )
        end,

        TogglePrivacyShield = function()
            return GUI.SetPrivacyShield(
                not GUI.PrivacyShieldEnabled
            )
        end,

        ToggleNotifications = function()
            return GUI.SetNotifications(
                not GUI.NotificationsEnabled
            )
        end,

        OpenSettings = function()
            return GUI.ShowPage("Settings")
        end,

        OpenSecurity = function()
            return GUI.ShowPage("Security")
        end,

        OpenSavedScripts = function()
            return GUI.ShowPage("SavedScripts")
        end,

        OpenMacros = function()
            return GUI.ShowPage("Macros")
        end,

        OpenPrivacyShield = function()
            return GUI.ShowPage("PrivacyShield")
        end,

        OpenMain = function()
            return GUI.ShowPage("Main")
        end,

        OpenImport = function()
            return false,
                "Import screen is not implemented yet."
        end,

        OpenLanguageSelector = function()
            return false,
                "Language selector is not connected yet."
        end,

        ScanBasic = function()
            return false,
                "Static scanner integration is not connected."
        end,

        ScanAdvanced = function()
            return false,
                "Advanced static scan is not implemented."
        end,

        ScanDeep = function()
            return false,
                "Deep static scan is not implemented."
        end,

        SearchSavedItems = function()
            return false,
                "Saved items are not connected yet."
        end,

        CreateMacro = function()
            return false,
                "Macro editor is not connected yet."
        end
    }

    local callback = actions[action]

    if not callback then
        return false, "Unknown action: " .. action
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

        Theme = Theme and Theme.Current or "Dark",

        RealTimeScannerEnabled =
            GUI.RealTimeScannerEnabled,

        PrivacyShieldEnabled =
            GUI.PrivacyShieldEnabled,

        NotificationsEnabled =
            GUI.NotificationsEnabled,

        SecurityStatus = GUI.SecurityStatus
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

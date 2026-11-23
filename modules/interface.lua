
-- LSAI Interface
-- Version: 0.1.0

local Interface = {
    Version = "0.1.0",
    Title = "LSAI",
    Theme = "Dark",
    IsOpen = false,
    ActiveTab = "Home",

    Tabs = {
        "Home",
        "Scanner",
        "Device",
        "Macros",
        "Settings"
    }
}

function Interface:Open()
    self.IsOpen = true
    print("[LSAI UI] Interface opened.")
    return true
end

function Interface:Close()
    self.IsOpen = false
    print("[LSAI UI] Interface closed.")
    return true
end

function Interface:Toggle()
    if self.IsOpen then
        return self:Close()
    end

    return self:Open()
end

function Interface:SetTab(tabName)
    for _, tab in ipairs(self.Tabs) do
        if tab == tabName then
            self.ActiveTab = tabName
            return true
        end
    end

    return false
end

function Interface:GetState()
    return {
        IsOpen = self.IsOpen,
        ActiveTab = self.ActiveTab,
        Theme = self.Theme
    }
end

function Interface:SetTheme(themeName)
    if themeName ~= "Dark" and themeName ~= "Light" then
        return false
    end

    self.Theme = themeName
    return true
end

return Interface


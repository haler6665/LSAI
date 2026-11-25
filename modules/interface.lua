
--[[
    LSAI v0.8
    Interface Preview

    - No external script execution
    - No file modification
    - No macro execution
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Cleanup
local old = PlayerGui:FindFirstChild("LSAI_GUI")
if old then
    old:Destroy()
end

-- Colors
local BG = Color3.fromRGB(23, 23, 27)
local PANEL = Color3.fromRGB(32, 32, 37)
local BUTTON = Color3.fromRGB(46, 46, 53)
local WHITE = Color3.fromRGB(235, 235, 235)
local GREY = Color3.fromRGB(115, 115, 120)

local opened = false
local busy = false
local animations = true
local selectedMacro = 1
local currentPage = "menu"

local connections = {}

local function Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "LSAI_GUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PlayerGui

local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.new(0, 330, 0, 430)
panel.Position = UDim2.new(1, 0, 0.5, -215)
panel.BackgroundColor3 = BG
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.Parent = gui

Instance.new("UICorner", panel).CornerRadius =
    UDim.new(0, 12)

-- Full-height handle
local handle = Instance.new("TextButton")
handle.Name = "OpenHandle"
handle.Size = UDim2.new(0, 10, 0, 430)
handle.Position = UDim2.new(1, -10, 0.5, -215)
handle.BackgroundColor3 = GREY
handle.BorderSizePixel = 0
handle.Text = ""
handle.AutoButtonColor = false
handle.ZIndex = 20
handle.Parent = gui

Instance.new("UICorner", handle).CornerRadius =
    UDim.new(0, 5)

-- Open / close
local function SetOpened(value)
    if busy or opened == value then
        return
    end

    busy = true
    opened = value

    local panelPosition
    local handlePosition

    if opened then
        panelPosition = UDim2.new(1, -330, 0.5, -215)
        handlePosition = UDim2.new(1, -340, 0.5, -215)
    else
        panelPosition = UDim2.new(1, 0, 0.5, -215)
        handlePosition = UDim2.new(1, -10, 0.5, -215)
    end

    if animations then
        local info = TweenInfo.new(
            0.25,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        )

        local panelTween = TweenService:Create(
            panel, info, {Position = panelPosition}
        )

        local handleTween = TweenService:Create(
            handle, info, {Position = handlePosition}
        )

        panelTween:Play()
        handleTween:Play()

        panelTween.Completed:Wait()
    else
        panel.Position = panelPosition
        handle.Position = handlePosition
    end

    busy = false
end

Connect(handle.Activated, function()
    SetOpened(not opened)
end)

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 65)
header.BackgroundColor3 = PANEL
header.BorderSizePixel = 0
header.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -55, 0, 30)
title.Position = UDim2.new(0, 14, 0, 4)
title.BackgroundTransparency = 1
title.Text = "LSAI"
title.TextColor3 = WHITE
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local creatorShadow = Instance.new("TextLabel")
creatorShadow.Size = UDim2.new(1, -55, 0, 20)
creatorShadow.Position = UDim2.new(0, 16, 0, 35)
creatorShadow.BackgroundTransparency = 1
creatorShadow.Text = "Creator: @haler6665"
creatorShadow.TextColor3 = GREY
creatorShadow.TextTransparency = 0.65
creatorShadow.TextSize = 11
creatorShadow.Font = Enum.Font.Gotham
creatorShadow.TextXAlignment = Enum.TextXAlignment.Left
creatorShadow.Parent = header

local creator = Instance.new("TextLabel")
creator.Size = UDim2.new(1, -55, 0, 20)
creator.Position = UDim2.new(0, 15, 0, 34)
creator.BackgroundTransparency = 1
creator.Text = "Creator: @haler6665"
creator.TextColor3 = Color3.fromRGB(125, 125, 130)
creator.TextTransparency = 0.35
creator.TextSize = 11
creator.Font = Enum.Font.Gotham
creator.TextXAlignment = Enum.TextXAlignment.Left
creator.Parent = header

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 35, 0, 35)
closeButton.Position = UDim2.new(1, -43, 0, 13)
closeButton.BackgroundColor3 = BUTTON
closeButton.Text = "×"
closeButton.TextColor3 = WHITE
closeButton.TextSize = 24
closeButton.Font = Enum.Font.Gotham
closeButton.Parent = header

Instance.new("UICorner", closeButton).CornerRadius =
    UDim.new(0, 8)

-- Section title
local sectionTitle = Instance.new("TextLabel")
sectionTitle.Position = UDim2.new(0, 12, 0, 72)
sectionTitle.Size = UDim2.new(1, -65, 0, 30)
sectionTitle.BackgroundTransparency = 1
sectionTitle.Text = "Main Menu"
sectionTitle.TextColor3 = WHITE
sectionTitle.TextSize = 16
sectionTitle.Font = Enum.Font.GothamBold
sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
sectionTitle.Parent = panel

local backButton = Instance.new("TextButton")
backButton.Size = UDim2.new(0, 38, 0, 30)
backButton.Position = UDim2.new(1, -48, 0, 72)
backButton.BackgroundColor3 = BUTTON
backButton.Text = ">"
backButton.TextColor3 = WHITE
backButton.TextSize = 22
backButton.Font = Enum.Font.GothamBold
backButton.Visible = false
backButton.Parent = panel

Instance.new("UICorner", backButton).CornerRadius =
    UDim.new(0, 7)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 44, 1, -115)
sidebar.Position = UDim2.new(1, -50, 0, 110)
sidebar.BackgroundTransparency = 1
sidebar.Parent = panel

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0, 9)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Parent = sidebar

-- Content
local content = Instance.new("ScrollingFrame")
content.Name = "Content"
content.Position = UDim2.new(0, 10, 0, 110)
content.Size = UDim2.new(1, -70, 1, -120)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.Parent = panel

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 8)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = content

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingBottom = UDim.new(0, 12)
contentPadding.Parent = content

local function ClearContent()
    for _, child in ipairs(content:GetChildren()) do
        if child ~= contentLayout and child ~= contentPadding then
            child:Destroy()
        end
    end
end

local function MakeLabel(text, height)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -4, 0, height or 35)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = WHITE
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content
    return label
end

local function MakeButton(text, callback, color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -4, 0, 42)
    button.BackgroundColor3 = color or BUTTON
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = WHITE
    button.TextSize = 13
    button.Font = Enum.Font.Gotham
    button.TextWrapped = true
    button.Parent = content

    Instance.new("UICorner", button).CornerRadius =
        UDim.new(0, 8)

    Connect(button.Activated, callback)
    return button
end

-- Pages
local ShowMenu
local ShowSettings
local ShowSecurity
local ShowScripts
local ShowMacro
local ShowMacroEditor
local ShowLog

local function OpenSection(name)
    sectionTitle.Text = name
    sidebar.Visible = false
    backButton.Visible = true
    content.Size = UDim2.new(1, -20, 1, -120)
end

local menuItems = {
    {
        icon = "⚙",
        name = "Settings",
        action = function() ShowSettings() end
    },
    {
        icon = "🛡",
        name = "Security",
        action = function() ShowSecurity() end
    },
    {
        icon = "▣",
        name = "Saved Scripts",
        action = function() ShowScripts() end
    },
    {
        icon = "🧩",
        name = "Macro",
        action = function() ShowMacro() end
    }
}

local function BuildSidebar()
    for _, child in ipairs(sidebar:GetChildren()) do
        if child ~= sidebarLayout then
            child:Destroy()
        end
    end

    for index, item in ipairs(menuItems) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 42, 0, 42)
        button.BackgroundColor3 = BUTTON
        button.BorderSizePixel = 0
        button.Text = item.icon
        button.TextColor3 = WHITE
        button.TextSize = 22
        button.LayoutOrder = index
        button.Parent = sidebar

        Instance.new("UICorner", button).CornerRadius =
            UDim.new(0, 9)

        local tooltip = Instance.new("TextLabel")
        tooltip.Size = UDim2.new(0, 150, 0, 34)
        tooltip.Position = UDim2.new(0, -158, 0, 4)
        tooltip.BackgroundColor3 = Color3.fromRGB(55, 55, 62)
        tooltip.TextColor3 = WHITE
        tooltip.TextSize = 12
        tooltip.Font = Enum.Font.Gotham
        tooltip.Text = item.name
        tooltip.Visible = false
        tooltip.ZIndex = 30
        tooltip.Parent = button

        Instance.new("UICorner", tooltip).CornerRadius =
            UDim.new(0, 7)

        Connect(button.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.Touch
                or input.UserInputType == Enum.UserInputType.MouseButton1 then
                tooltip.Visible = true
            end
        end)

        Connect(button.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.Touch
                or input.UserInputType == Enum.UserInputType.MouseButton1 then
                tooltip.Visible = false
            end
        end)

        Connect(button.Activated, function()
            tooltip.Visible = false
            item.action()
        end)
    end
end

ShowMenu = function()
    currentPage = "menu"
    ClearContent()

    sectionTitle.Text = "Main Menu"
    sidebar.Visible = true
    backButton.Visible = false
    content.Size = UDim2.new(1, -70, 1, -120)

    MakeLabel("Select a section on the right.", 55)
end

Connect(backButton.Activated, ShowMenu)

-- Settings
ShowSettings = function()
    currentPage = "settings"
    OpenSection("Settings")
    ClearContent()

    MakeLabel("Interface language", 28)
    MakeButton("English", function() end)
    MakeButton("Русский", function() end)
    MakeButton("Română", function() end)
    MakeButton("Українська", function() end)

    MakeLabel("Appearance", 28)

    MakeButton(
        animations and "Animations: ON" or "Animations: OFF",
        function()
            animations = not animations
            ShowSettings()
        end
    )
end

-- Security placeholder
ShowSecurity = function()
    currentPage = "security"
    OpenSection("Security")
    ClearContent()

    MakeLabel("Security Center", 30)
    MakeLabel("Scanner is not connected yet.", 40)
    MakeButton("Scan interface preview", function()
        MakeLabel("This is only a UI preview.", 35)
    end)
end

ShowLog = function(name, details)
    currentPage = "log"
    OpenSection("Security")
    ClearContent()

    MakeLabel("Record: " .. name, 35)
    MakeLabel(details, 100)

    MakeButton("Back to Security", ShowSecurity)
end

-- Saved scripts placeholder
ShowScripts = function()
    currentPage = "scripts"
    OpenSection("Saved Scripts")
    ClearContent()

    MakeLabel("Saved Scripts", 30)
    MakeLabel("No scripts loaded.", 45)
    MakeLabel("File access is not connected.", 55)
end

-- Macro
local macroBlocks = {
    {name = "Event", color = Color3.fromRGB(45, 105, 190)},
    {name = "Delay", color = Color3.fromRGB(190, 155, 40)},
    {name = "Action", color = Color3.fromRGB(130, 75, 180)},
    {name = "Condition", color = Color3.fromRGB(195, 105, 40)},
    {name = "Repeat", color = Color3.fromRGB(55, 140, 75)}
}

ShowMacroEditor = function()
    currentPage = "macro_editor"
    OpenSection("Macro")
    ClearContent()

    MakeLabel("Macro " .. selectedMacro, 30)
    MakeLabel("Workspace", 25)

    local workspaceFrame = Instance.new("Frame")
    workspaceFrame.Size = UDim2.new(1, -4, 0, 185)
    workspaceFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    workspaceFrame.BorderSizePixel = 0
    workspaceFrame.Parent = content

    Instance.new("UICorner", workspaceFrame).CornerRadius =
        UDim.new(0, 8)

    local workspaceLayout = Instance.new("UIListLayout")
    workspaceLayout.Padding = UDim.new(0, 5)
    workspaceLayout.Parent = workspaceFrame

    local workspacePadding = Instance.new("UIPadding")
    workspacePadding.PaddingTop = UDim.new(0, 8)
    workspacePadding.PaddingLeft = UDim.new(0, 8)
    workspacePadding.PaddingRight = UDim.new(0, 8)
    workspacePadding.Parent = workspaceFrame

    local function AddBlock(info)
        local block = Instance.new("TextButton")
        block.Size = UDim2.new(1, -4, 0, 28)
        block.BackgroundColor3 = info.color
        block.BorderSizePixel = 0
        block.Text = info.name .. "   ×"
        block.TextColor3 = WHITE
        block.TextSize = 12
        block.Parent = workspaceFrame

        Instance.new("UICorner", block).CornerRadius =
            UDim.new(0, 6)

        Connect(block.Activated, function()
            block:Destroy()
        end)
    end

    MakeLabel("Add block", 28)

    for _, info in ipairs(macroBlocks) do
        MakeButton("+  " .. info.name, function()
            AddBlock(info)
        end, info.color)
    end

    MakeLabel("Tap a block to remove it.", 35)
    MakeLabel("Visual editor only. Macros are not executed.", 45)
end

ShowMacro = function()
    currentPage = "macro"
    OpenSection("Macro")
    ClearContent()

    MakeLabel("Select a workspace", 35)

    for i = 1, 3 do
        local number = i
        MakeButton("Macro " .. number, function()
            selectedMacro = number
            ShowMacroEditor()
        end)
    end
end

-- Close dialog
local function ShowCloseDialog()
    if gui:FindFirstChild("CloseDialog") then
        return
    end

    local overlay = Instance.new("Frame")
    overlay.Name = "CloseDialog"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.4
    overlay.ZIndex = 50
    overlay.Parent = gui

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 250, 0, 140)
    box.Position = UDim2.new(0.5, -125, 0.5, -70)
    box.BackgroundColor3 = PANEL
    box.BorderSizePixel = 0
    box.ZIndex = 51
    box.Parent = overlay

    Instance.new("UICorner", box).CornerRadius =
        UDim.new(0, 10)

    local question = Instance.new("TextLabel")
    question.Size = UDim2.new(1, -20, 0, 50)
    question.Position = UDim2.new(0, 10, 0, 8)
    question.BackgroundTransparency = 1
    question.Text = "Close LSAI?"
    question.TextColor3 = WHITE
    question.TextSize = 15
    question.Font = Enum.Font.Gotham
    question.ZIndex = 52
    question.Parent = box

    local stay = Instance.new("TextButton")
    stay.Size = UDim2.new(0.46, 0, 0, 38)
    stay.Position = UDim2.new(0.03, 0, 1, -48)
    stay.BackgroundColor3 = BUTTON
    stay.Text = "Continue"
    stay.TextColor3 = WHITE
    stay.TextSize = 12
    stay.ZIndex = 52
    stay.Parent = box

    Instance.new("UICorner", stay).CornerRadius =
        UDim.new(0, 7)

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0.46, 0, 0, 38)
    close.Position = UDim2.new(0.51, 0, 1, -48)
    close.BackgroundColor3 = Color3.fromRGB(155, 45, 45)
    close.Text = "Close"
    close.TextColor3 = WHITE
    close.TextSize = 12
    close.ZIndex = 52
    close.Parent = box

    Instance.new("UICorner", close).CornerRadius =
        UDim.new(0, 7)

    Connect(stay.Activated, function()
        overlay:Destroy()
    end)

    Connect(close.Activated, function()
        for _, connection in ipairs(connections) do
            pcall(function()
                connection:Disconnect()
            end)
        end
        gui:Destroy()
    end)
end

Connect(closeButton.Activated, ShowCloseDialog)

-- Build
BuildSidebar()
ShowMenu()
SetOpened(false)

print("LSAI v0.8 interface loaded")

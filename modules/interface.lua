
--[[
    LSAI Roblox Edition
    Interface Module v0.5.0

    - Roblox Luau ModuleScript
    - Static source analysis only
    - Does not execute scanned scripts
    - Does not modify files
    - Macro editor is visual only
]]

local Interface = {}

Interface.Name = "LSAI Roblox Interface"
Interface.Version = "0.5.0"
Interface.Status = "Not initialized"

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Dependencies
local Security = nil

-- State
local PlayerGui
local ScreenGui
local Panel
local Handle

local Opened = false
local Busy = false
local Animations = true
local Initialized = false

local CurrentPage = "menu"
local SelectedMacro = 1

local Connections = {}
local MacroData = {}

-- Colors
local Colors = {
    Background = Color3.fromRGB(23, 23, 27),
    Panel = Color3.fromRGB(32, 32, 37),
    Button = Color3.fromRGB(46, 46, 53),
    White = Color3.fromRGB(235, 235, 235),
    Grey = Color3.fromRGB(125, 125, 130),
    Green = Color3.fromRGB(55, 145, 85),
    Yellow = Color3.fromRGB(190, 145, 45),
    Red = Color3.fromRGB(165, 55, 55)
}

local function Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Connections, connection)
    return connection
end

local function DisconnectAll()
    for _, connection in ipairs(Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(Connections)
end

local function CreateCorner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = object
    return corner
end

local function CreateLabel(parent, text, height)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -4, 0, height or 35)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.White
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent

    return label
end

local function CreateButton(parent, text, callback, color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -4, 0, 42)
    button.BackgroundColor3 = color or Colors.Button
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Colors.White
    button.TextSize = 13
    button.Font = Enum.Font.Gotham
    button.TextWrapped = true
    button.AutoButtonColor = true
    button.Parent = parent

    CreateCorner(button, 8)

    if callback then
        Connect(button.Activated, callback)
    end

    return button
end

local function ClearContent()
    if not Interface.Content then
        return
    end

    for _, child in ipairs(Interface.Content:GetChildren()) do
        if child ~= Interface.ContentLayout
            and child ~= Interface.ContentPadding then
            child:Destroy()
        end
    end
end

local function SetPageTitle(title)
    if Interface.SectionTitle then
        Interface.SectionTitle.Text = title
    end
end

local function OpenSection(title)
    SetPageTitle(title)

    Interface.Sidebar.Visible = false
    Interface.BackButton.Visible = true
    Interface.Content.Size = UDim2.new(1, -20, 1, -120)
end

local ShowMenu
local ShowSettings
local ShowSecurity
local ShowScripts
local ShowMacro
local ShowMacroEditor

-- Open / Close
local function SetOpened(value)
    if not Initialized or Busy or Opened == value then
        return
    end

    Busy = true
    Opened = value

    local panelPosition
    local handlePosition

    if value then
        panelPosition = UDim2.new(1, -330, 0.5, -215)
        handlePosition = UDim2.new(1, -340, 0.5, -215)
    else
        panelPosition = UDim2.new(1, 0, 0.5, -215)
        handlePosition = UDim2.new(1, -10, 0.5, -215)
    end

    if Animations then
        local info = TweenInfo.new(
            0.25,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        )

        local panelTween = TweenService:Create(
            Panel,
            info,
            {Position = panelPosition}
        )

        local handleTween = TweenService:Create(
            Handle,
            info,
            {Position = handlePosition}
        )

        panelTween:Play()
        handleTween:Play()

        local connection
        connection = panelTween.Completed:Connect(function()
            if connection then
                connection:Disconnect()
            end

            Busy = false
        end)
    else
        Panel.Position = panelPosition
        Handle.Position = handlePosition
        Busy = false
    end
end

-- GUI construction
local function BuildGui()
    local player = Players.LocalPlayer

    if not player then
        return false, "LocalPlayer is unavailable"
    end

    PlayerGui = player:WaitForChild("PlayerGui")

    local old = PlayerGui:FindFirstChild("LSAI_GUI")
    if old then
        old:Destroy()
    end

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LSAI_GUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui

    Panel = Instance.new("Frame")
    Panel.Name = "MainPanel"
    Panel.Size = UDim2.new(0, 330, 0, 430)
    Panel.Position = UDim2.new(1, 0, 0.5, -215)
    Panel.BackgroundColor3 = Colors.Background
    Panel.BorderSizePixel = 0
    Panel.ClipsDescendants = true
    Panel.Parent = ScreenGui

    CreateCorner(Panel, 12)

    Handle = Instance.new("TextButton")
    Handle.Name = "OpenHandle"
    Handle.Size = UDim2.new(0, 10, 0, 430)
    Handle.Position = UDim2.new(1, -10, 0.5, -215)
    Handle.BackgroundColor3 = Colors.Grey
    Handle.BorderSizePixel = 0
    Handle.Text = ""
    Handle.AutoButtonColor = false
    Handle.ZIndex = 20
    Handle.Parent = ScreenGui

    CreateCorner(Handle, 5)

    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 65)
    header.BackgroundColor3 = Colors.Panel
    header.BorderSizePixel = 0
    header.Parent = Panel

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -55, 0, 30)
    title.Position = UDim2.new(0, 14, 0, 4)
    title.BackgroundTransparency = 1
    title.Text = "LSAI"
    title.TextColor3 = Colors.White
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local creator = Instance.new("TextLabel")
    creator.Size = UDim2.new(1, -55, 0, 20)
    creator.Position = UDim2.new(0, 15, 0, 34)
    creator.BackgroundTransparency = 1
    creator.Text = "Roblox Edition"
    creator.TextColor3 = Colors.Grey
    creator.TextSize = 11
    creator.Font = Enum.Font.Gotham
    creator.TextXAlignment = Enum.TextXAlignment.Left
    creator.Parent = header

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Position = UDim2.new(1, -43, 0, 13)
    closeButton.BackgroundColor3 = Colors.Button
    closeButton.Text = "×"
    closeButton.TextColor3 = Colors.White
    closeButton.TextSize = 24
    closeButton.Font = Enum.Font.Gotham
    closeButton.Parent = header

    CreateCorner(closeButton, 8)

    -- Section title
    Interface.SectionTitle = Instance.new("TextLabel")
    Interface.SectionTitle.Position = UDim2.new(0, 12, 0, 72)
    Interface.SectionTitle.Size = UDim2.new(1, -65, 0, 30)
    Interface.SectionTitle.BackgroundTransparency = 1
    Interface.SectionTitle.Text = "Main Menu"
    Interface.SectionTitle.TextColor3 = Colors.White
    Interface.SectionTitle.TextSize = 16
    Interface.SectionTitle.Font = Enum.Font.GothamBold
    Interface.SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    Interface.SectionTitle.Parent = Panel

    Interface.BackButton = Instance.new("TextButton")
    Interface.BackButton.Size = UDim2.new(0, 38, 0, 30)
    Interface.BackButton.Position = UDim2.new(1, -48, 0, 72)
    Interface.BackButton.BackgroundColor3 = Colors.Button
    Interface.BackButton.Text = "<"
    Interface.BackButton.TextColor3 = Colors.White
    Interface.BackButton.TextSize = 22
    Interface.BackButton.Font = Enum.Font.GothamBold
    Interface.BackButton.Visible = false
    Interface.BackButton.Parent = Panel

    CreateCorner(Interface.BackButton, 7)

    -- Sidebar
    Interface.Sidebar = Instance.new("Frame")
    Interface.Sidebar.Size = UDim2.new(0, 44, 1, -115)
    Interface.Sidebar.Position = UDim2.new(1, -50, 0, 110)
    Interface.Sidebar.BackgroundTransparency = 1
    Interface.Sidebar.Parent = Panel

    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.Padding = UDim.new(0, 9)
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Parent = Interface.Sidebar

    -- Content
    Interface.Content = Instance.new("ScrollingFrame")
    Interface.Content.Name = "Content"
    Interface.Content.Position = UDim2.new(0, 10, 0, 110)
    Interface.Content.Size = UDim2.new(1, -70, 1, -120)
    Interface.Content.BackgroundTransparency = 1
    Interface.Content.BorderSizePixel = 0
    Interface.Content.ScrollBarThickness = 3
    Interface.Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Interface.Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Interface.Content.Parent = Panel

    Interface.ContentLayout = Instance.new("UIListLayout")
    Interface.ContentLayout.Padding = UDim.new(0, 8)
    Interface.ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    Interface.ContentLayout.Parent = Interface.Content

    Interface.ContentPadding = Instance.new("UIPadding")
    Interface.ContentPadding.PaddingBottom = UDim.new(0, 12)
    Interface.ContentPadding.Parent = Interface.Content

    -- Button connections
    Connect(Handle.Activated, function()
        SetOpened(not Opened)
    end)

    Connect(closeButton.Activated, function()
        SetOpened(false)
    end)

    Connect(Interface.BackButton.Activated, function()
        ShowMenu()
    end)

    return true
end

-- Menu
local menuItems = {
    {
        icon = "⚙",
        name = "Settings",
        action = function()
            ShowSettings()
        end
    },
    {
        icon = "🛡",
        name = "Security",
        action = function()
            ShowSecurity()
        end
    },
    {
        icon = "▣",
        name = "Saved Scripts",
        action = function()
            ShowScripts()
        end
    },
    {
        icon = "🧩",
        name = "Macro",
        action = function()
            ShowMacro()
        end
    }
}

local function BuildSidebar()
    for _, child in ipairs(Interface.Sidebar:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end

    for index, item in ipairs(menuItems) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 42, 0, 42)
        button.BackgroundColor3 = Colors.Button
        button.BorderSizePixel = 0
        button.Text = item.icon
        button.TextColor3 = Colors.White
        button.TextSize = 22
        button.LayoutOrder = index
        button.Parent = Interface.Sidebar

        CreateCorner(button, 9)

        Connect(button.Activated, item.action)
    end
end

ShowMenu = function()
    CurrentPage = "menu"
    ClearContent()

    SetPageTitle("Main Menu")
    Interface.Sidebar.Visible = true
    Interface.BackButton.Visible = false
    Interface.Content.Size = UDim2.new(1, -70, 1, -120)

    CreateLabel(
        Interface.Content,
        "Select a section on the right.",
        55
    )
end

-- Settings
ShowSettings = function()
    CurrentPage = "settings"
    OpenSection("Settings")
    ClearContent()

    CreateLabel(Interface.Content, "Appearance", 28)

    local animationButton

    animationButton = CreateButton(
        Interface.Content,
        Animations and "Animations: ON" or "Animations: OFF",
        function()
            Animations = not Animations
            animationButton.Text =
                Animations and "Animations: ON" or "Animations: OFF"
        end
    )

    CreateLabel(Interface.Content, "Language", 28)

    CreateButton(Interface.Content, "English", function()
        Interface.Language = "en"
        ShowSettings()
    end)

    CreateButton(Interface.Content, "Русский", function()
        Interface.Language = "ru"
        ShowSettings()
    end)

    CreateButton(Interface.Content, "Română", function()
        Interface.Language = "ro"
        ShowSettings()
    end)

    CreateLabel(
        Interface.Content,
        "Selected language: " .. (Interface.Language or "en"),
        30
    )
end

-- Security
ShowSecurity = function()
    CurrentPage = "security"
    OpenSection("Security")
    ClearContent()

    CreateLabel(Interface.Content, "Static Code Analyzer", 30)

    CreateLabel(
        Interface.Content,
        "Paste Lua source code below. The analyzer checks text only and never executes it.",
        55
    )

    local sourceBox = Instance.new("TextBox")
    sourceBox.Size = UDim2.new(1, -4, 0, 130)
    sourceBox.BackgroundColor3 = Colors.Panel
    sourceBox.BorderSizePixel = 0
    sourceBox.TextColor3 = Colors.White
    sourceBox.PlaceholderColor3 = Colors.Grey
    sourceBox.PlaceholderText = "Paste Lua code here..."
    sourceBox.Text = ""
    sourceBox.TextSize = 12
    sourceBox.Font = Enum.Font.Code
    sourceBox.TextWrapped = false
    sourceBox.TextXAlignment = Enum.TextXAlignment.Left
    sourceBox.TextYAlignment = Enum.TextYAlignment.Top
    sourceBox.ClearTextOnFocus = false
    sourceBox.MultiLine = true
    sourceBox.Parent = Interface.Content

    CreateCorner(sourceBox, 8)

    local resultLabel = CreateLabel(
        Interface.Content,
        "Status: Waiting for source code.",
        65
    )

    local scanButton = CreateButton(
        Interface.Content,
        "Analyze source",
        function()
            local source = sourceBox.Text

            if source == "" then
                resultLabel.Text = "Please paste source code first."
                resultLabel.TextColor3 = Colors.Yellow
                return
            end

            if #source > 1000000 then
                resultLabel.Text = "Source is too large. Maximum: 1 MB."
                resultLabel.TextColor3 = Colors.Red
                return
            end

            if not Security or type(Security.Scan) ~= "function" then
                resultLabel.Text =
                    "Security module is not connected."
                resultLabel.TextColor3 = Colors.Yellow
                return
            end

            resultLabel.Text = "Analyzing..."
            resultLabel.TextColor3 = Colors.White

            local success, report = pcall(function()
                return Security.Scan(source)
            end)

            if not success or type(report) ~= "table" then
                resultLabel.Text = "Analysis failed."
                resultLabel.TextColor3 = Colors.Red
                return
            end

            local level = tostring(report.Level or "UNKNOWN")
            local score = tonumber(report.Score) or 0
            local count = tonumber(report.Count) or 0

            resultLabel.Text =
                "Level: " .. level
                .. "\nScore: " .. tostring(score)
                .. "\nFindings: " .. tostring(count)

            if level == "DANGEROUS" then
                resultLabel.TextColor3 = Colors.Red
            elseif level == "WARNING" or level == "LOW" then
                resultLabel.TextColor3 = Colors.Yellow
            else
                resultLabel.TextColor3 = Colors.Green
            end
        end,
        Colors.Green
    )

    CreateLabel(
        Interface.Content,
        "Static analysis is not a guarantee that code is safe.",
        45
    )
end

-- Saved scripts placeholder
ShowScripts = function()
    CurrentPage = "scripts"
    OpenSection("Saved Scripts")
    ClearContent()

    CreateLabel(Interface.Content, "Saved Scripts", 30)

    CreateLabel(
        Interface.Content,
        "No saved entries.",
        45
    )

    CreateLabel(
        Interface.Content,
        "Persistent storage is not connected.",
        45
    )
end

-- Visual macro editor
local macroBlocks = {
    {
        name = "Event",
        color = Color3.fromRGB(45, 105, 190)
    },
    {
        name = "Delay",
        color = Color3.fromRGB(190, 155, 40)
    },
    {
        name = "Action",
        color = Color3.fromRGB(130, 75, 180)
    },
    {
        name = "Condition",
        color = Color3.fromRGB(195, 105, 40)
    },
    {
        name = "Repeat",
        color = Color3.fromRGB(55, 140, 75)
    }
}

ShowMacroEditor = function()
    CurrentPage = "macro_editor"
    OpenSection("Macro " .. SelectedMacro)
    ClearContent()

    CreateLabel(
        Interface.Content,
        "Visual Workspace",
        30
    )

    local workspaceFrame = Instance.new("Frame")
    workspaceFrame.Size = UDim2.new(1, -4, 0, 185)
    workspaceFrame.BackgroundColor3 = Colors.Panel
    workspaceFrame.BorderSizePixel = 0
    workspaceFrame.Parent = Interface.Content

    CreateCorner(workspaceFrame, 8)

    local workspaceLayout = Instance.new("UIListLayout")
    workspaceLayout.Padding = UDim.new(0, 5)
    workspaceLayout.Parent = workspaceFrame

    local workspacePadding = Instance.new("UIPadding")
    workspacePadding.PaddingTop = UDim.new(0, 8)
    workspacePadding.PaddingLeft = UDim.new(0, 8)
    workspacePadding.PaddingRight = UDim.new(0, 8)
    workspacePadding.Parent = workspaceFrame

    MacroData[SelectedMacro] = MacroData[SelectedMacro] or {}

    local function RefreshBlocks()
        for _, child in ipairs(workspaceFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for index, blockInfo in ipairs(MacroData[SelectedMacro]) do
            local block = Instance.new("TextButton")
            block.Size = UDim2.new(1, -4, 0, 28)
            block.BackgroundColor3 = blockInfo.color
            block.BorderSizePixel = 0
            block.Text = blockInfo.name .. "   ×"
            block.TextColor3 = Colors.White
            block.TextSize = 12
            block.Parent = workspaceFrame

            CreateCorner(block, 6)

            Connect(block.Activated, function()
                table.remove(MacroData[SelectedMacro], index)
                ShowMacroEditor()
            end)
        end
    end

    RefreshBlocks()

    CreateLabel(Interface.Content, "Add block", 28)

    for _, info in ipairs(macroBlocks) do
        CreateButton(
            Interface.Content,
            "+  " .. info.name,
            function()
                table.insert(MacroData[SelectedMacro], {
                    name = info.name,
                    color = info.color
                })

                ShowMacroEditor()
            end,
            info.color
        )
    end

    CreateLabel(
        Interface.Content,
        "Tap a block to remove it.",
        35
    )

    CreateLabel(
        Interface.Content,
        "Visual editor only. Macros are not executed.",
        45
    )
end

ShowMacro = function()
    CurrentPage = "macro"
    OpenSection("Macro")
    ClearContent()

    CreateLabel(
        Interface.Content,
        "Select a workspace",
        35
    )

    for index = 1, 3 do
        local number = index

        CreateButton(
            Interface.Content,
            "Macro " .. number,
            function()
                SelectedMacro = number
                ShowMacroEditor()
            end
        )
    end
end

-- Public API
function Interface.Initialize(dependencies)
    if Initialized then
        return true, "Already initialized"
    end

    dependencies = dependencies or {}

    Security = dependencies.Security

    local success, message = BuildGui()

    if not success then
        Interface.St

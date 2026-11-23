
-- LSAI 0.3.0
-- Safe Lua Static Analyzer
-- Roblox Studio LocalScript

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("LSAI_GUI")
if old then
    old:Destroy()
end

local LSAI = {
    Name = "LSAI",
    Version = "0.3.0",
    Status = "Ready",
    Findings = {}
}

local colors = {
    Background = Color3.fromRGB(17, 19, 25),
    Panel = Color3.fromRGB(23, 26, 34),
    Button = Color3.fromRGB(34, 38, 49),
    Accent = Color3.fromRGB(90, 130, 255),
    Text = Color3.fromRGB(235, 238, 245),
    Muted = Color3.fromRGB(145, 151, 165),
    Border = Color3.fromRGB(48, 53, 66),
    Warning = Color3.fromRGB(255, 190, 85)
}

local gui = Instance.new("ScreenGui")
gui.Name = "LSAI_GUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(570, 370)
main.Position = UDim2.new(0.5, -285, 0.5, -185)
main.BackgroundColor3 = colors.Background
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = main

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 145, 1, 0)
sidebar.BackgroundColor3 = colors.Panel
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 10)
sideCorner.Parent = sidebar

local line = Instance.new("Frame")
line.Name = "Divider"
line.Size = UDim2.new(0, 1, 1, 0)
line.Position = UDim2.new(0, 145, 0, 0)
line.BackgroundColor3 = colors.Border
line.BorderSizePixel = 0
line.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 38)
title.Position = UDim2.fromOffset(12, 12)
title.BackgroundTransparency = 1
title.Text = "LSAI"
title.TextColor3 = colors.Text
title.TextSize = 23
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = sidebar

local version = Instance.new("TextLabel")
version.Size = UDim2.new(1, -20, 0, 20)
version.Position = UDim2.fromOffset(13, 45)
version.BackgroundTransparency = 1
version.Text = "VERSION 0.3.0"
version.TextColor3 = colors.Muted
version.TextSize = 10
version.Font = Enum.Font.Gotham
version.TextXAlignment = Enum.TextXAlignment.Left
version.Parent = sidebar

local content = Instance.new("Frame")
content.Name = "Content"
content.Position = UDim2.fromOffset(146, 0)
content.Size = UDim2.new(1, -146, 1, 0)
content.BackgroundTransparency = 1
content.Parent = main

local pages = {}

local function createPage(name)
    local page = Instance.new("Frame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = content
    pages[name] = page
    return page
end

local function label(parent, text, position, size, textSize)
    local item = Instance.new("TextLabel")
    item.BackgroundTransparency = 1
    item.Position = position
    item.Size = size
    item.Text = text
    item.TextColor3 = colors.Text
    item.TextSize = textSize or 14
    item.Font = Enum.Font.Gotham
    item.TextXAlignment = Enum.TextXAlignment.Left
    item.TextYAlignment = Enum.TextYAlignment.Center
    item.Parent = parent
    return item
end

local function button(parent, text, position, size)
    local item = Instance.new("TextButton")
    item.Position = position
    item.Size = size
    item.BackgroundColor3 = colors.Button
    item.BorderSizePixel = 0
    item.Text = text
    item.TextColor3 = colors.Text
    item.TextSize = 13
    item.Font = Enum.Font.GothamMedium
    item.AutoButtonColor = true
    item.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = item

    return item
end

local home = createPage("Home")

label(home, "Dashboard",
    UDim2.fromOffset(20, 18),
    UDim2.new(1, -40, 0, 30), 21)

label(home, "Welcome to LSAI",
    UDim2.fromOffset(20, 65),
    UDim2.new(1, -40, 0, 25), 15)

local statusLabel = label(home, "Status: Ready",
    UDim2.fromOffset(20, 105),
    UDim2.new(1, -40, 0, 25), 13)

label(home, "Static Lua analysis enabled",
    UDim2.fromOffset(20, 140),
    UDim2.new(1, -40, 0, 25), 12)

local security = createPage("Security")

label(security, "Security Scanner",
    UDim2.fromOffset(20, 15),
    UDim2.new(1, -40, 0, 30), 20)

local input = Instance.new("TextBox")
input.Position = UDim2.fromOffset(20, 55)
input.Size = UDim2.new(1, -40, 0, 145)
input.BackgroundColor3 = colors.Panel
input.BorderSizePixel = 0
input.TextColor3 = colors.Text
input.PlaceholderColor3 = colors.Muted
input.PlaceholderText = "Paste Lua source code here..."
input.Text = ""
input.TextSize = 12
input.Font = Enum.Font.Code
input.TextXAlignment = Enum.TextXAlignment.Left
input.TextYAlignment = Enum.TextYAlignment.Top
input.TextWrapped = false
input.MultiLine = true
input.ClearTextOnFocus = false
input.Parent = security

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = input

local scanButton = button(
    security,
    "Scan code",
    UDim2.fromOffset(20, 212),
    UDim2.fromOffset(110, 34)
)

local result = label(
    security,
    "Waiting for source code...",
    UDim2.fromOffset(20, 258),
    UDim2.new(1, -40, 0, 75),
    12
)
result.TextYAlignment = Enum.TextYAlignment.Top
result.TextWrapped = true

local rules = {
    "loadstring",
    "httpget",
    "request",
    "writefile",
    "delfile",
    "getgenv",
    "hookfunction",
    "getrawmetatable"
}

local function scan(source)
    local findings = {}

    if #source > 100000 then
        return nil, "Source is too large (100 KB limit)."
    end

    local lineNumber = 0

    for currentLine in (source .. "\n"):gmatch("(.-)\n") do
        lineNumber += 1

        local lowered = currentLine:lower()

        for _, rule in ipairs(rules) do
            if lowered:find(rule, 1, true) then
                table.insert(findings,
                    rule .. " - line " .. lineNumber)
            end
        end
    end

    return findings
end

scanButton.MouseButton1Click:Connect(function()
    result.Text = "Scanning..."

    local success, findings = pcall(scan, input.Text)

    if not success or not findings then
        result.Text = "Scan error: " .. tostring(findings)
        return
    end

    LSAI.Findings = findings

    if #findings == 0 then
        result.Text = "No configured patterns found.\nThis does not prove the code is safe."
    else
        result.Text = "Review required:\n" ..
            table.concat(findings, "\n")
    end
end)

local device = createPage("Device")

label(device, "Environment",
    UDim2.fromOffset(20, 18),
    UDim2.new(1, -40, 0, 30), 20)

label(device, "Platform: Roblox",
    UDim2.fromOffset(20, 65),
    UDim2.new(1, -40, 0, 25), 13)

label(device, "Lua version: Luau",
    UDim2.fromOffset(20, 100),
    UDim2.new(1, -40, 0, 25), 13)

label(device, "Device details are not automatically detected.",
    UDim2.fromOffset(20, 145),
    UDim2.new(1, -40, 0, 45), 12)

local settings = createPage("Settings")

label(settings, "Settings",
    UDim2.fromOffset(20, 18),
    UDim2.new(1, -40, 0, 30), 20)

label(settings, "LSAI version: " .. LSAI.Version,
    UDim2.fromOffset(20, 65),
    UDim2.new(1, -40, 0, 25), 13)

label(settings, "Static analysis only",
    UDim2.fromOffset(20, 100),
    UDim2.new(1, -40, 0, 25), 13)

local diagnostics = createPage("Diagnostics")

label(diagnostics, "Diagnostics",
    UDim2.fromOffset(20, 18),
    UDim2.new(1, -40, 0, 30), 20)

label(diagnostics, "GUI: Ready\nScanner: Ready\nRemote execution: Disabled",
    UDim2.fromOffset(20, 65),
    UDim2.new(1, -40, 0, 100), 13)

local navNames = {
    "Home",
    "Security",
    "Device",
    "Settings",
    "Diagnostics"
}

local function showPage(name)
    for pageName, page in pairs(pages) do
        page.Visible = pageName == name
    end
end

for index, name in ipairs(navNames) do
    local nav = button(
        sidebar,
        name,
        UDim2.fromOffset(10, 85 + (index - 1) * 43),
        UDim2.new(1, -20, 0, 34)
    )

    nav.MouseButton1Click:Connect(function()
        showPage(name)
    end)
end

local close = button(
    sidebar,
    "Close",
    UDim2.new(0, 10, 1, -45),
    UDim2.new(1, -20, 0, 34)
)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Basic window dragging

local dragging = false
local dragStart
local startPosition

main.InputBegan:Connect(function(event)
    if event.UserInputType == Enum.UserInputType.MouseButton1
        or event.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = event.Position
        startPosition = main.Position
    end
end)

main.InputEnded:Connect(function(event)
    if event.UserInputType == Enum.UserInputType.MouseButton1
        or event.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(event)
    if dragging and (
        event.UserInputType == Enum.UserInputType.MouseMovement
        or event.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = event.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

showPage("Home")

log = nil
print("[LSAI] Version " .. LSAI.Version .. " started.")

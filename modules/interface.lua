
-- LSAI Interface Module
-- Version: 0.3.0
-- Default language: English

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Interface = {}

local CONFIG = {
    Width = 330,
    Height = 380,
    AnimationTime = 0.25,
    HoldTime = 0.4
}

local COLORS = {
    Background = Color3.fromRGB(19, 21, 28),
    Panel = Color3.fromRGB(25, 28, 37),
    Button = Color3.fromRGB(37, 41, 53),
    Accent = Color3.fromRGB(88, 125, 245),
    Text = Color3.fromRGB(238, 240, 248),
    Muted = Color3.fromRGB(145, 151, 168),
    Border = Color3.fromRGB(55, 60, 74)
}

local navigation = {
    {
        Name = "Settings",
        Icon = "⚙"
    },
    {
        Name = "Security",
        Icon = "🛡"
    },
    {
        Name = "Saved Scripts",
        Icon = "▤"
    },
    {
        Name = "Macros",
        Icon = "🧩"
    }
}

local function create(className, properties, parent)
    local object = Instance.new(className)

    for property, value in pairs(properties) do
        object[property] = value
    end

    object.Parent = parent
    return object
end

local function corner(parent, radius)
    create("UICorner", {
        CornerRadius = UDim.new(0, radius)
    }, parent)
end

local function makeLabel(parent, text, position, size, textSize)
    return create("TextLabel", {
        BackgroundTransparency = 1,
        Position = position,
        Size = size,
        Text = text,
        TextColor3 = COLORS.Text,
        TextSize = textSize or 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    }, parent)
end

local function makeButton(parent, text, position, size)
    local button = create("TextButton", {
        Position = position,
        Size = size,
        BackgroundColor3 = COLORS.Button,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = COLORS.Text,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = true
    }, parent)

    corner(button, 7)

    return button
end

function Interface:Create()
    local player = Players.LocalPlayer

    if not player then
        return false, "LocalPlayer unavailable"
    end

    local playerGui = player:WaitForChild("PlayerGui")

    local oldGui = playerGui:FindFirstChild("LSAI_GUI")

    if oldGui then
        oldGui:Destroy()
    end

    local gui = create("ScreenGui", {
        Name = "LSAI_GUI",
        ResetOnSpawn = false,
        DisplayOrder = 20,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, playerGui)

    -- Main window

    local panel = create("Frame", {
        Name = "MainPanel",
        Size = UDim2.fromOffset(
            CONFIG.Width,
            CONFIG.Height
        ),
        Position = UDim2.new(1, 0, 0.5, -190),
        BackgroundColor3 = COLORS.Background,
        BorderSizePixel = 0
    }, gui)

    corner(panel, 10)

    -- Vertical navigation separator.
    -- Its height always matches the GUI.

    create("Frame", {
        Name = "VerticalLine",
        Position = UDim2.new(1, -50, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = COLORS.Border,
        BorderSizePixel = 0
    }, panel)

    -- Header

    local header = create("Frame", {
        Size = UDim2.new(1, -50, 0, 65),
        BackgroundColor3 = COLORS.Panel,
        BorderSizePixel = 0
    }, panel)

    corner(header, 10)

    makeLabel(
        header,
        "LSAI",
        UDim2.fromOffset(15, 7),
        UDim2.fromOffset(180, 27),
        21
    ).Font = Enum.Font.GothamBold

    makeLabel(
        header,
        "Creator: @haler6665",
        UDim2.fromOffset(16, 34),
        UDim2.fromOffset(180, 17),
        10
    ).TextColor3 = COLORS.Muted

    local closeButton = makeButton(
        header,
        "×",
        UDim2.new(1, -40, 0, 14),
        UDim2.fromOffset(29, 29)
    )

    -- Content area

    local content = create("Frame", {
        Name = "Content",
        Position = UDim2.fromOffset(0, 66),
        Size = UDim2.new(1, -51, 1, -66),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    }, panel)

    local pages = {}

    local function createPage(name)
        local page = create("Frame", {
            Name = name,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Visible = false
        }, content)

        pages[name] = page
        return page
    end

    -- Home page

    local home = createPage("Home")

    makeLabel(
        home,
        "Welcome to LSAI",
        UDim2.fromOffset(16, 15),
        UDim2.new(1, -30, 0, 30),
        19
    ).Font = Enum.Font.GothamBold

    makeLabel(
        home,
        "Your safety assistant",
        UDim2.fromOffset(17, 49),
        UDim2.new(1, -30, 0, 22),
        12
    ).TextColor3 = COLORS.Muted

    local status = makeLabel(
        home,
        "System status: Ready",
        UDim2.fromOffset(17, 91),
        UDim2.new(1, -30, 0, 25),
        13
    )

    status.TextColor3 = Color3.fromRGB(110, 210, 145)

    makeLabel(
        home,
        "Choose a section using the buttons on the right.",
        UDim2.fromOffset(17, 130),
        UDim2.new(1, -30, 0, 50),
        12
    ).TextColor3 = COLORS.Muted

    -- Settings page

    local settings = createPage("Settings")

    -- Security page

    local security = createPage("Security")

    -- Saved Scripts page

    local scripts = createPage("SavedScripts")

    -- Macros page

    local macros = createPage("Macros")

    local function createSection(name, description, parent)
        local back = makeButton(
            parent,
            ">",
            UDim2.fromOffset(13, 12),
            UDim2.fromOffset(35, 30)
        )

        back.BackgroundColor3 = COLORS.Accent

        makeLabel(
            parent,
            name,
            UDim2.fromOffset(58, 12),
            UDim2.new(1, -70, 0, 30),
            18
        ).Font = Enum.Font.GothamBold

        makeLabel(
            parent,
            description,
            UDim2.fromOffset(15, 62),
            UDim2.new(1, -30, 0, 55),
            12
        ).TextColor3 = COLORS.Muted

        return back
    end

    -- Section content

    local settingsBack = createSection(
        "Settings",
        "Configure the LSAI interface.",
        settings
    )

    local securityBack = createSection(
        "Security",
        "Inspect Lua source code as text. No code is executed.",
        security
    )

    local scriptsBack = createSection(
        "Saved Scripts",
        "Your saved script list will appear here.",
        scripts
    )

    local macrosBack = createSection(
        "Macros",
        "Create and organize visual macro blocks.",
        macros
    )

    -- Security input

    local sourceBox = create("TextBox", {
        Position = UDim2.fromOffset(15, 130),
        Size = UDim2.new(1, -30, 0, 100),
        BackgroundColor3 = COLORS.Panel,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = "Paste Lua source here...",
        PlaceholderColor3 = COLORS.Muted,
        TextColor3 = COLORS.Text,
        TextSize = 12,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = false,
        MultiLine = true,
        ClearTextOnFocus = false
    }, security)

    corner(sourceBox, 6)

    local scanResult = makeLabel(
        security,
        "Waiting for scan...",
        UDim2.fromOffset(15, 275),
        UDim2.new(1, -30, 0, 55),
        11
    )

    scanResult.TextWrapped = true
    scanResult.TextYAlignment = Enum.TextYAlignment.Top

    local scanButton = makeButton(
        security,
        "Scan",
        UDim2.fromOffset(15, 240),
        UDim2.fromOffset(90, 30)
    )

    local patterns = {
        "loadstring",
        "httpget",
        "request",
        "writefile",
        "delfile",
        "getgenv",
        "hookfunction"
    }

    scanButton.Activated:Connect(function()
        local source = sourceBox.Text

        if #source > 100000 then
            scanResult.Text = "Source exceeds the 100 KB limit."
            return
        end

        local findings = {}
        local lineNumber = 0

        for line in (source .. "\n"):gmatch("(.-)\n") do
            lineNumber += 1

            local lowered = line:lower()

            for _, pattern in ipairs(patterns) do
                if lowered:find(pattern, 1, true) then
                    table.insert(
                        findings,
                        pattern .. " - line " .. lineNumber
                    )
                end
            end
        end

        if #findings == 0 then
            scanResult.Text =
                "No configured patterns found. This does not prove safety."
        else
            scanResult.Text =
                "Review required:\n" .. table.concat(findings, "\n")
        end
    end)

    -- Navigation buttons on the RIGHT

    local navigationButtons = {}

    local selectedPage = "Home"

    local function showPage(name)
        selectedPage = name

        for pageName, page in pairs(pages) do
            page.Visible = pageName == name
        end
    end

    local function goHome()
        showPage("Home")

        for _, button in ipairs(navigationButtons) do
            button.Visible = true
        end
    end

    settingsBack.Activated:Connect(goHome)
    securityBack.Activated:Connect(goHome)
    scriptsBack.Activated:Connect(goHome)
    macrosBack.Activated:Connect(goHome)

    local pageMap = {
        Settings = "Settings",
        Security = "Security",
        ["Saved Scripts"] = "SavedScripts",
        Macros = "Macros"
    }

    for index, item in ipairs(navigation) do
        local navButton = makeButton(
            panel,
            item.Icon,
            UDim2.new(1, -43, 0, 88 + (index - 1) * 49),
            UDim2.fromOffset(36, 36)
        )

        navButton.TextSize = 17

        local tooltip = create("TextLabel", {
            Position = UDim2.new(1, -190, 0, 88 + (index - 1) * 49),
            Size = UDim2.fromOffset(140, 36),
            BackgroundColor3 = COLORS.Button,
            Text = item.Name,
            TextColor3 = COLORS.Text,
            TextSize = 12,
            Font = Enum.Font.GothamMedium,
            Visible = false,
            BorderSizePixel = 0,
            ZIndex = 5
        }, panel)

        corner(tooltip, 6)

        local holding = false

        navButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then

                holding = true

                task.delay(CONFIG.HoldTime, function()
                    if holding and navButton.Visible then
                        tooltip.Visible = true
                    end
                end)
            end
        end)

        navButton.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then

                holding = false
                tooltip.Visible = false
            end
        end)

        navButton.Activated:Connect(function()
            showPage(pageMap[item.Name])

            for _, otherButton in ipairs(navigationButtons) do
                otherButton.Visible = false
            end

            tooltip.Visible = false
        end)

        table.insert(navigationButtons, navButton)
    end

    -- Side handle.
    -- Its visible line has exactly the GUI height.

    local handle = create("TextButton", {
        Name = "SideHandle",
        Position = UDim2.new(1, -4, 0.5, -190),
        Size = UDim2.fromOffset(14, CONFIG.Height),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 10
    }, gui)

    local handleLine = create("Frame", {
        Position = UDim2.new(1, -3, 0, 0),
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = COLORS.Accent,
        BorderSizePixel = 0
    }, handle)

    corner(handleLine, 3)

    -- Opening and closing animation

    local isOpen = false
    local moving = false

    local function setOpen(value)
        if moving or not gui.Parent then
            return
        end

        isOpen = value
        moving = true

        local target

        if isOpen then
            target = UDim2.new(1, -CONFIG.Width, 0.5, -190)
        else
            target = UDim2.new(1, 0, 0.5, -190)
        end

        local tween = TweenService:Create(
            panel,
            TweenInfo.new(
                CONFIG.AnimationTime,
                Enum.EasingStyle.Quart,
                Enum.EasingDirection.Out
            ),
            {
                Position = target
            }
        )

        tween:Play()
        tween.Completed:Wait()

        moving = false
    end

    handle.Activated:Connect(function()
        setOpen(not isOpen)
    end)

    closeButton.Activated:Connect(function()
        setOpen(false)
    end)

    -- Always start on Home

    showPage("Home")

    self.Gui = gui
    self.Panel = panel
    self.Open = function()
        setOpen(true)
    end
    self.Close = function()
        setOpen(false)
    end
    self.Destroy = function()
        gui:Destroy()
    end

    return true, "LSAI interface created"
end

return Interface

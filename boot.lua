
--[[
    LSAI Roblox Edition
    Bootloader v0.5.0

    - Loads ModuleScripts
    - Checks module availability
    - Initializes the interface
    - Does not execute scanned source code
]]

local Boot = {
    Name = "LSAI Bootloader",
    Version = "0.5.0",
    Status = "Not started",
    Modules = {}
}

local function Log(message)
    print("[LSAI BOOT] " .. tostring(message))
end

local function GetModulesFolder()
    local root = script.Parent

    if not root then
        return nil
    end

    return root:FindFirstChild("modules")
end

local requiredModules = {
    "security",
    "instructions",
    "device",
    "interface",
    "settings",
    "macros"
}

function Boot:CheckModules()
    Log("Checking modules...")

    local folder = GetModulesFolder()

    if not folder then
        self.Status = "Failed"
        warn("[LSAI BOOT] modules folder not found")
        return false
    end

    local loaded = {}

    for _, name in ipairs(requiredModules) do
        local moduleScript = folder:FindFirstChild(name)

        if not moduleScript then
            self.Status = "Failed"
            warn("[LSAI BOOT] Missing module: " .. name)
            return false
        end

        if not moduleScript:IsA("ModuleScript") then
            self.Status = "Failed"
            warn("[LSAI BOOT] Not a ModuleScript: " .. name)
            return false
        end

        local success, result = pcall(require, moduleScript)

        if not success then
            self.Status = "Failed"
            warn(
                "[LSAI BOOT] Failed to load "
                .. name .. ": " .. tostring(result)
            )
            return false
        end

        if type(result) ~= "table" then
            self.Status = "Failed"
            warn("[LSAI BOOT] Invalid module: " .. name)
            return false
        end

        loaded[name] = result
        Log("Loaded: " .. name)
    end

    self.Modules = loaded

    return true
end

function Boot:Start()
    if self.Status == "Ready" then
        return true
    end

    Log("========================")
    Log("LSAI ROBLOX EDITION")
    Log("Version: " .. self.Version)
    Log("========================")

    self.Status = "Initializing"

    if not self:CheckModules() then
        self.Status = "Failed"
        warn("[LSAI BOOT] Startup cancelled")
        return false
    end

    local Interface = self.Modules.interface
    local Security = self.Modules.security

    if type(Interface.Initialize) ~= "function" then
        self.Status = "Failed"
        warn("[LSAI BOOT] Interface.Initialize is missing")
        return false
    end

    local success, result, message = pcall(function()
        return Interface.Initialize({
            Security = Security
        })
    end)

    if not success or result ~= true then
        self.Status = "Failed"

        warn(
            "[LSAI BOOT] Interface initialization failed: "
            .. tostring(success and message or result)
        )

        return false
    end

    self.Status = "Ready"

    Log("All modules loaded.")
    Log("Interface initialized.")
    Log("Startup complete.")

    return true
end

function Boot:GetInfo()
    return {
        Name = self.Name,
        Version = self.Version,
        Status = self.Status,
        LoadedModules = #requiredModules
    }
end

return Boot

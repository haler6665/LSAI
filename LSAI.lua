--[[
    LSAI - Main Entry Point
    Version: 0.5.0
    Runtime: Roblox Luau
]]

local LSAI = {
    Name = "LSAI",
    Version = "0.5.0",
    Language = "en",
    Status = "Starting",
    Boot = nil
}

function LSAI:Start()
    print("========================")
    print("       LSAI")
    print("========================")

    local bootScript = script.Parent:FindFirstChild("boot")

    if not bootScript or not bootScript:IsA("ModuleScript") then
        self.Status = "Failed"
        warn("[LSAI] boot ModuleScript not found.")
        return false
    end

    local success, Boot = pcall(require, bootScript)

    if not success or type(Boot) ~= "table" then
        self.Status = "Failed"
        warn("[LSAI] Could not load boot module.")
        warn(tostring(Boot))
        return false
    end

    self.Boot = Boot

    local started, result = pcall(function()
        return Boot:Start()
    end)

    if not started or result ~= true then
        self.Status = "Failed"
        warn("[LSAI] Startup failed.")
        if not started then
            warn(tostring(result))
        end
        return false
    end

    self.Status = "Ready"

    print("[LSAI] Startup completed.")
    print("[LSAI] Status: " .. self.Status)

    return true
end

function LSAI:GetInfo()
    return {
        Name = self.Name,
        Version = self.Version,
        Language = self.Language,
        Status = self.Status
    }
end

return LSAI

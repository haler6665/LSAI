
-- LSAI Bootloader
-- Version: 0.1.0

local Boot = {
    Version = "0.1.0",
    Status = "Initializing"
}

local requiredModules = {
    "security",
    "instructions",
    "device",
    "interface",
    "settings",
    "macros"
}

function Boot:CheckModules()
    print("[BOOT] Checking modules...")

    for _, name in ipairs(requiredModules) do
        local success, result = pcall(
            require,
            "modules." .. name
        )

        if not success or type(result) ~= "table" then
            self.Status = "Failed"
            warn("[BOOT] Missing or invalid module: " .. name)
            return false
        end

        print("[BOOT] OK: " .. name)
    end

    return true
end

function Boot:Start()
    print("========================")
    print("       LSAI BOOT")
    print("========================")

    if not self:CheckModules() then
        warn("[BOOT] Startup cancelled.")
        return false
    end

    self.Status = "Ready"
    print("[BOOT] All checks passed.")
    return true
end

return Boot



-- LSAI - Main Entry Point
-- Version: 0.1.0
-- Default language: English

local LSAI = {
    Name = "LSAI",
    Version = "0.1.0",
    Language = "en",
    Modules = {},
    Status = "Starting"
}

local moduleNames = {
    "security",
    "instructions",
    "device",
    "interface",
    "settings",
    "macros"
}

local function loadModule(name)
    local success, result = pcall(require, "modules." .. name)

    if not success then
        warn("[LSAI] Module failed: " .. name)
        warn(tostring(result))
        return false
    end

    if type(result) ~= "table" then
        warn("[LSAI] Invalid module: " .. name)
        return false
    end

    LSAI.Modules[name] = result
    print("[LSAI] Loaded: " .. name)

    return true
end

function LSAI:Start()
    print("========== LSAI ==========")
    print("Version: " .. self.Version)
    print("Checking modules...")

    local loaded = 0

    for _, name in ipairs(moduleNames) do
        if loadModule(name) then
            loaded = loaded + 1
        end
    end

    if loaded == #moduleNames then
        self.Status = "Ready"
        print("[LSAI] All modules loaded.")
    else
        self.Status = "Incomplete"
        warn("[LSAI] Some modules could not be loaded.")
    end

    print("[LSAI] Status: " .. self.Status)
    print("==========================")
end

LSAI:Start()

return LSAI


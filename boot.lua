
--[[
    LSAI Bootloader
    Version: 0.4.0
    Runtime: Standard Lua
]]

local Boot = {
    Name = "LSAI Bootloader",
    Version = "0.4.0",
    Status = "Starting",
    Errors = {}
}

local function log(message)
    print("[LSAI:BOOT] " .. tostring(message))
end

local function addError(message)
    Boot.Errors[#Boot.Errors + 1] = tostring(message)
    log("ERROR: " .. tostring(message))
end

local function validateCore(core)
    if type(core) ~= "table" then
        return false, "Core must be a table"
    end

    local required = {
        "Initialize",
        "RegisterModule",
        "GetModule",
        "GetStatus"
    }

    for _, method in ipairs(required) do
        if type(core[method]) ~= "function" then
            return false, "Missing core method: " .. method
        end
    end

    return true
end

function Boot.Start(core, moduleLoader)
    Boot.Status = "Starting"
    Boot.Errors = {}

    log("Boot sequence started")

    local valid, reason = validateCore(core)

    if not valid then
        addError(reason)
        Boot.Status = "Failed"
        return false
    end

    if type(moduleLoader) ~= "function" then
        addError("Module loader is missing")
        Boot.Status = "Failed"
        return false
    end

    local success, result = pcall(
        core.Initialize,
        core,
        moduleLoader
    )

    if not success then
        addError(result)
        Boot.Status = "Failed"
        return false
    end

    if result ~= true then
        addError("Core initialization failed")
        Boot.Status = "Failed"
        return false
    end

    Boot.Status = "Ready"

    log("Boot sequence completed")

    return true
end

function Boot.GetStatus()
    return Boot.Status
end

function Boot.GetErrors()
    return Boot.Errors
end

log("Bootloader loaded")

return Boot


--[[
    LSAI Bootloader
    Version: 0.6.0
    Runtime: Standard Lua

    Responsibilities:
    - Validate Core
    - Initialize Core
    - Track boot status
    - Collect startup errors

    Does not execute imported user scripts.
]]

local Boot = {
    Name = "LSAI Bootloader",
    Version = "0.6.0",
    Status = "NotStarted",
    Errors = {},
    Started = false
}

local function log(message)
    print("[LSAI:BOOT] " .. tostring(message))
end

local function addError(message)
    local errorMessage = tostring(message)

    Boot.Errors[#Boot.Errors + 1] = errorMessage

    log("ERROR: " .. errorMessage)
end

local function validateCore(core)
    if type(core) ~= "table" then
        return false, "Core must be a table."
    end

    local required = {
        "Initialize",
        "RegisterModule",
        "GetModule",
        "GetStatus"
    }

    for _, method in ipairs(required) do
        if type(core[method]) ~= "function" then
            return false,
                "Missing Core method: " .. method
        end
    end

    return true
end

local function validateLoader(moduleLoader)
    if type(moduleLoader) ~= "function" then
        return false, "Module loader must be a function."
    end

    return true
end

function Boot.Start(core, moduleLoader)
    if Boot.Started then
        return false, "Bootloader has already started."
    end

    Boot.Status = "Starting"
    Boot.Errors = {}

    log("Boot sequence started")

    local valid, reason = validateCore(core)

    if not valid then
        addError(reason)
        Boot.Status = "Failed"
        return false, reason
    end

    valid, reason = validateLoader(moduleLoader)

    if not valid then
        addError(reason)
        Boot.Status = "Failed"
        return false, reason
    end

    local success, result = pcall(
        core.Initialize,
        core,
        moduleLoader
    )

    if not success then
        addError(result)
        Boot.Status = "Failed"
        return false, result
    end

    if result ~= true then
        local message = "Core initialization failed."

        addError(message)
        Boot.Status = "Failed"

        return false, message
    end

    Boot.Started = true
    Boot.Status = "Ready"

    log("Boot sequence completed")

    return true
end

function Boot.GetStatus()
    return Boot.Status
end

function Boot.GetErrors()
    local copy = {}

    for index, message in ipairs(Boot.Errors) do
        copy[index] = message
    end

    return copy
end

function Boot.GetInfo()
    return {
        Name = Boot.Name,
        Version = Boot.Version,
        Status = Boot.Status,
        Started = Boot.Started,
        ErrorCount = #Boot.Errors
    }
end

function Boot.Reset()
    if Boot.Status == "Starting" then
        return false, "Cannot reset while booting."
    end

    Boot.Status = "NotStarted"
    Boot.Started = false
    Boot.Errors = {}

    log("Bootloader reset")

    return true
end

log("Bootloader loaded")

return Boot

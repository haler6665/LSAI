
--[[
    LSAI Device Module
    Version: 0.5.0
    Runtime: Standard Lua / LuaJIT

    Environment information only.
    Does not modify system settings or files.
]]

local Device = {
    Name = "LSAI Device Module",
    Version = "0.5.0",

    Information = {
        Runtime = "Unknown",
        LuaVersion = _VERSION or "Unknown",
        Platform = "Unknown",
        Storage = "Not tested",
        RuntimeFeatures = {}
    }
}

local function safeCheck(callback)
    if type(callback) ~= "function" then
        return nil
    end

    local success, result = pcall(callback)

    if success then
        return result
    end

    return nil
end

local function copyTable(source)
    local result = {}

    for key, value in pairs(source) do
        if type(value) == "table" then
            result[key] = copyTable(value)
        else
            result[key] = value
        end
    end

    return result
end

function Device.DetectRuntime()
    if type(jit) == "table" then
        Device.Information.Runtime = "LuaJIT"
    elseif type(_VERSION) == "string" then
        Device.Information.Runtime = "Standard Lua"
    else
        Device.Information.Runtime = "Unknown"
    end

    Device.Information.LuaVersion = _VERSION or "Unknown"

    return Device.Information.Runtime
end

function Device.DetectFeatures()
    local features = {
        FileAPI = type(io) == "table"
            and type(io.open) == "function",

        OperatingSystemAPI = type(os) == "table",

        TimeAPI = type(os) == "table"
            and type(os.time) == "function",

        TableLibrary = type(table) == "table",

        StringLibrary = type(string) == "table",

        MathLibrary = type(math) == "table",

        CoroutineLibrary = type(coroutine) == "table",

        DebugLibrary = type(debug) == "table",

        GarbageCollector = type(collectgarbage) == "function"
    }

    Device.Information.RuntimeFeatures = features

    return copyTable(features)
end

function Device.GetMemoryInfo()
    local memory = safeCheck(function()
        if type(collectgarbage) == "function" then
            return collectgarbage("count")
        end
    end)

    if type(memory) ~= "number" then
        return nil
    end

    return {
        UsedKB = memory,
        UsedMB = memory / 1024
    }
end

function Device.GetInfo()
    Device.DetectRuntime()
    Device.DetectFeatures()

    return {
        Name = Device.Name,
        Version = Device.Version,
        Runtime = Device.Information.Runtime,
        LuaVersion = Device.Information.LuaVersion,
        Platform = Device.Information.Platform,
        Storage = Device.Information.Storage,
        Features = copyTable(Device.Information.RuntimeFeatures),
        Memory = Device.GetMemoryInfo()
    }
end

function Device.GetInformation()
    return copyTable(Device.Information)
end

function Device.GetVersion()
    return Device.Version
end

return Device

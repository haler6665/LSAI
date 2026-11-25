
--[[
    LSAI Device Module
    Version: 0.4.0
    Runtime: Standard Lua
]]

local Device = {
    Version = "0.4.0",

    Information = {
        Runtime = "Unknown",
        LuaVersion = _VERSION or "Unknown",
        Platform = "Unknown",
        Storage = "Unknown",
        RuntimeFeatures = {}
    }
}

local function safeCheck(callback)
    local success, result = pcall(callback)

    if success then
        return result
    end

    return nil
end

function Device.DetectRuntime()
    if type(jit) == "table" then
        Device.Information.Runtime = "LuaJIT"
    elseif _VERSION then
        Device.Information.Runtime = "Standard Lua"
    else
        Device.Information.Runtime = "Unknown"
    end

    return Device.Information.Runtime
end

function Device.DetectFeatures()
    local features = {
        FileRead = type(io) == "table"
            and type(io.open) == "function",

        FileWrite = type(io) == "table"
            and type(io.open) == "function",

        OperatingSystemInfo = type(os) == "table"
            and type(os.time) == "function",

        TableLibrary = type(table) == "table",

        StringLibrary = type(string) == "table",

        MathLibrary = type(math) == "table"
    }

    Device.Information.RuntimeFeatures = features

    return features
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
        Version = Device.Version,
        Runtime = Device.Information.Runtime,
        LuaVersion = Device.Information.LuaVersion,
        Platform = Device.Information.Platform,
        Storage = Device.Information.Storage,
        Features = Device.Information.RuntimeFeatures,
        Memory = Device.GetMemoryInfo()
    }
end

return Device


-- LSAI Device Information
-- Version: 0.1.0

local Device = {
    Version = "0.1.0",
    Information = {
        Platform = "Unknown",
        DeviceName = "Unknown",
        CPU = "Unknown",
        GPU = "Unknown",
        RAM = "Unknown",
        LuaVersion = _VERSION or "Unknown"
    }
}

function Device:GetInfo()
    return self.Information
end

function Device:Get(key)
    return self.Information[key] or "Unknown"
end

function Device:SetInfo(key, value)
    if self.Information[key] == nil then
        return false
    end

    if type(value) ~= "string" then
        return false
    end

    self.Information[key] = value
    return true
end

function Device:GetReport()
    local info = self.Information

    return {
        "LSAI DEVICE REPORT",
        "------------------",
        "Platform: " .. info.Platform,
        "Device: " .. info.DeviceName,
        "CPU: " .. info.CPU,
        "GPU: " .. info.GPU,
        "RAM: " .. info.RAM,
        "Lua: " .. info.LuaVersion
    }
end

return Device


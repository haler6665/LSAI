
--[[
    LSAI
    Main Core
    Version: 0.4.0
    Runtime: Standard Lua
    Mode: Static Analysis
]]

local LSAI = {
    Name = "LSAI",
    Version = "0.4.0",
    Language = "en",
    Status = "Initializing",

    Modules = {},
    Errors = {},

    Config = {
        Debug = false,
        AutoStart = true
    }
}

local MODULES = {
    "database",
    "device",
    "instructions",
    "settings",
    "security",
    "interface",
    "macros"
}

local function log(message)
    print("[LSAI] " .. tostring(message))
end

local function addError(moduleName, message)
    LSAI.Errors[#LSAI.Errors + 1] = {
        Module = moduleName,
        Message = tostring(message)
    }

    log("ERROR: " .. moduleName .. " - " .. tostring(message))
end

function LSAI:RegisterModule(name, module)
    if type(name) ~= "string" then
        return false, "Invalid module name"
    end

    if type(module) ~= "table" then
        return false, "Module must return a table"
    end

    self.Modules[name] = module

    return true
end

function LSAI:GetModule(name)
    return self.Modules[name]
end

function LSAI:GetModules()
    local result = {}

    for name in pairs(self.Modules) do
        result[#result + 1] = name
    end

    table.sort(result)

    return result
end

function LSAI:GetErrors()
    return self.Errors
end

function LSAI:GetStatus()
    return self.Status
end

function LSAI:LoadModule(name, loader)
    if type(loader) ~= "function" then
        addError(name, "Invalid module loader")
        return false
    end

    local success, result = pcall(loader, name)

    if not success then
        addError(name, result)
        return false
    end

    if type(result) ~= "table" then
        addError(name, "Module must return a table")
        return false
    end

    self.Modules[name] = result

    log("Module loaded: " .. name)

    return true
end

function LSAI:Initialize(loader)
    self.Status = "Initializing"

    log("Starting " .. self.Name .. " v" .. self.Version)

    for _, name in ipairs(MODULES) do
        if not self:LoadModule(name, loader) then
            self.Status = "Error"
            log("Initialization stopped")
            return false
        end
    end

    self.Status = "Ready"

    log("Initialization complete")

    return true
end

function LSAI:GetInfo()
    return {
        Name = self.Name,
        Version = self.Version,
        Language = self.Language,
        Status = self.Status,
        ModuleCount = #self:GetModules(),
        ErrorCount = #self.Errors
    }
end

log("Core loaded")

return LSAI

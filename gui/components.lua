
--[[
    LSAI GUI Components
    Version: 0.5.0

    Platform-independent UI component definitions.
    Does not render UI directly.
]]

local Components = {}

Components.Name = "LSAI GUI Components"
Components.Version = "0.5.0"
Components.Status = "Ready"

local Registry = {}

local AllowedTypes = {
    Button = true,
    Toggle = true,
    TextField = true,
    Label = true,
    Card = true,
    Progress = true,
    Badge = true
}

local function CopyTable(source)
    local result = {}

    for key, value in pairs(source) do
        if type(value) == "table" then
            result[key] = CopyTable(value)
        else
            result[key] = value
        end
    end

    return result
end

local function IsValidID(id)
    return type(id) == "string" and id ~= ""
end

local function CreateComponent(componentType, properties)
    properties = properties or {}

    if type(properties) ~= "table" then
        return nil, "Properties must be a table."
    end

    if not AllowedTypes[componentType] then
        return nil, "Unknown component type."
    end

    local id = properties.ID

    if id ~= nil then
        if not IsValidID(id) then
            return nil, "Component ID must be a non-empty string."
        end

        if Registry[id] then
            return nil, "Component ID already exists."
        end
    end

    local component = {
        Type = componentType,
        Visible = properties.Visible ~= false,
        Enabled = properties.Enabled ~= false,
        Text = type(properties.Text) == "string"
            and properties.Text or "",
        Value = properties.Value,
        Width = properties.Width,
        Height = properties.Height,
        ID = id,
        Style = type(properties.Style) == "string"
            and properties.Style or "Default"
    }

    if componentType == "Toggle" then
        component.Value = properties.Value == true
    end

    if componentType == "TextField" then
        component.Placeholder =
            type(properties.Placeholder) == "string"
            and properties.Placeholder or ""

        local maxLength = tonumber(properties.MaxLength) or 500
        component.MaxLength = math.max(1, math.floor(maxLength))
    end

    if componentType == "Progress" then
        component.Value = math.max(
            0,
            math.min(100, tonumber(component.Value) or 0)
        )
    end

    if component.Width ~= nil then
        if type(component.Width) ~= "number" or component.Width <= 0 then
            return nil, "Width must be a positive number."
        end
    end

    if component.Height ~= nil then
        if type(component.Height) ~= "number" or component.Height <= 0 then
            return nil, "Height must be a positive number."
        end
    end

    if id then
        Registry[id] = component
    end

    return component
end

function Components.Button(properties)
    return CreateComponent("Button", properties)
end

function Components.Toggle(properties)
    return CreateComponent("Toggle", properties)
end

function Components.TextField(properties)
    return CreateComponent("TextField", properties)
end

function Components.Label(properties)
    return CreateComponent("Label", properties)
end

function Components.Card(properties)
    return CreateComponent("Card", properties)
end

function Components.Progress(properties)
    return CreateComponent("Progress", properties)
end

function Components.Badge(properties)
    return CreateComponent("Badge", properties)
end

function Components.SetValue(id, value)
    if not IsValidID(id) then
        return false, "Invalid component ID."
    end

    local component = Registry[id]

    if not component then
        return false, "Component not found."
    end

    if component.Type == "Toggle" then
        if type(value) ~= "boolean" then
            return false, "Toggle value must be boolean."
        end
    elseif component.Type == "Progress" then
        value = tonumber(value)

        if not value then
            return false, "Progress value must be a number."
        end

        value = math.max(0, math.min(100, value))
    elseif component.Type == "TextField" then
        if type(value) ~= "string" then
            return false, "TextField value must be a string."
        end

        if #value > component.MaxLength then
            return false, "Text exceeds maximum length."
        end
    end

    component.Value = value

    return true
end

function Components.SetVisible(id, visible)
    if not IsValidID(id) then
        return false, "Invalid component ID."
    end

    local component = Registry[id]

    if not component then
        return false, "Component not found."
    end

    if type(visible) ~= "boolean" then
        return false, "Visibility must be boolean."
    end

    component.Visible = visible

    return true
end

function Components.SetEnabled(id, enabled)
    if not IsValidID(id) then
        return false, "Invalid component ID."
    end

    local component = Registry[id]

    if not component then
        return false, "Component not found."
    end

    if type(enabled) ~= "boolean" then
        return false, "Enabled must be boolean."
    end

    component.Enabled = enabled

    return true
end

function Components.Get(id)
    if not IsValidID(id) then
        return nil
    end

    local component = Registry[id]

    if not component then
        return nil
    end

    return CopyTable(component)
end

function Components.Remove(id)
    if not IsValidID(id) or not Registry[id] then
        return false
    end

    Registry[id] = nil

    return true
end

function Components.Clear()
    Registry = {}

    return true
end

function Components.GetAll()
    local result = {}

    for id, component in pairs(Registry) do
        result[id] = CopyTable(component)
    end

    return result
end

function Components.GetCount()
    local count = 0

    for _ in pairs(Registry) do
        count = count + 1
    end

    return count
end

function Components.GetInfo()
    return {
        Name = Components.Name,
        Version = Components.Version,
        Status = Components.Status,
        ComponentCount = Components.GetCount(),
        SupportedTypes = {
            "Button",
            "Toggle",
            "TextField",
            "Label",
            "Card",
            "Progress",
            "Badge"
        }
    }
end

return Components

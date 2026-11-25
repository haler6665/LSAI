
-- LSAI GUI Components
-- Version: 0.4.0
-- Platform-independent UI component definitions.

local Components = {
    Version = "0.4.0",
    Registry = {}
}

local function createComponent(componentType, properties)
    properties = properties or {}

    local component = {
        Type = componentType,
        Visible = properties.Visible ~= false,
        Enabled = properties.Enabled ~= false,
        Text = properties.Text or "",
        Value = properties.Value,
        Width = properties.Width,
        Height = properties.Height,
        ID = properties.ID,
        Style = properties.Style or "Default"
    }

    if component.ID then
        Components.Registry[component.ID] = component
    end

    return component
end

function Components.Button(properties)
    return createComponent("Button", properties)
end

function Components.Toggle(properties)
    local component = createComponent("Toggle", properties)
    component.Value = properties and properties.Value == true
    return component
end

function Components.TextField(properties)
    local component = createComponent("TextField", properties)
    component.Placeholder = properties and properties.Placeholder or ""
    component.MaxLength = properties and properties.MaxLength or 500
    return component
end

function Components.Label(properties)
    return createComponent("Label", properties)
end

function Components.Card(properties)
    return createComponent("Card", properties)
end

function Components.Progress(properties)
    local component = createComponent("Progress", properties)
    component.Value = math.max(0, math.min(100, tonumber(component.Value) or 0))
    return component
end

function Components.Badge(properties)
    return createComponent("Badge", properties)
end

function Components.SetValue(id, value)
    local component = Components.Registry[id]

    if not component then
        return false, "Component not found"
    end

    component.Value = value
    return true
end

function Components.Get(id)
    return Components.Registry[id]
end

function Components.Remove(id)
    if not Components.Registry[id] then
        return false
    end

    Components.Registry[id] = nil
    return true
end

function Components.Clear()
    Components.Registry = {}
end

function Components.GetAll()
    local result = {}

    for id, component in pairs(Components.Registry) do
        result[id] = component
    end

    return result
end

function Components.GetInfo()
    local count = 0

    for _ in pairs(Components.Registry) do
        count = count + 1
    end

    return {
        Name = "Components",
        Version = Components.Version,
        ComponentCount = count
    }
end

return Components


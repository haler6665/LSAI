--[[
    LSAI Visual Macros
    Version: 0.5.0
    Runtime: Standard Lua

    Features:
    - Visual block management
    - Block connections
    - Structure validation
    - Safe data copies
    - Data-only export
    - No code execution
]]

local Macros = {
    Name = "LSAI Visual Macros",
    Version = "0.5.0",

    Blocks = {},
    Connections = {},
    NextID = 1,

    Status = "Ready"
}

local allowedTypes = {
    Start = true,
    Text = true,
    Condition = true,
    Wait = true,
    End = true
}

local function isAllowedType(blockType)
    return type(blockType) == "string"
        and allowedTypes[blockType] == true
end

local function findBlock(id)
    for _, block in ipairs(Macros.Blocks) do
        if block.ID == id then
            return block
        end
    end

    return nil
end

local function copyBlock(block)
    return {
        ID = block.ID,
        Type = block.Type,
        Value = block.Value,
        ConnectedTo = block.ConnectedTo
    }
end

local function copyBlocks(blocks)
    local result = {}

    for index, block in ipairs(blocks) do
        result[index] = copyBlock(block)
    end

    return result
end

function Macros:AddBlock(blockType, value)
    if not isAllowedType(blockType) then
        return nil, "Invalid block type"
    end

    if value ~= nil and type(value) ~= "string" then
        return nil, "Block value must be a string"
    end

    if blockType == "Start" then
        for _, block in ipairs(self.Blocks) do
            if block.Type == "Start" then
                return nil, "Only one Start block is allowed"
            end
        end
    end

    if blockType == "End" then
        for _, block in ipairs(self.Blocks) do
            if block.Type == "End" then
                return nil, "Only one End block is allowed"
            end
        end
    end

    local block = {
        ID = self.NextID,
        Type = blockType,
        Value = value or "",
        ConnectedTo = nil
    }

    self.NextID = self.NextID + 1

    self.Blocks[#self.Blocks + 1] = block

    return block.ID
end

function Macros:RemoveBlock(id)
    local target = findBlock(id)

    if not target then
        return false, "Block not found"
    end

    for index, block in ipairs(self.Blocks) do
        if block.ID == id then
            table.remove(self.Blocks, index)
            break
        end
    end

    for _, block in ipairs(self.Blocks) do
        if block.ConnectedTo == id then
            block.ConnectedTo = nil
        end
    end

    for index = #self.Connections, 1, -1 do
        local connection = self.Connections[index]

        if connection.From == id or connection.To == id then
            table.remove(self.Connections, index)
        end
    end

    return true
end

function Macros:Connect(firstID, secondID)
    if firstID == secondID then
        return false, "Cannot connect a block to itself"
    end

    local first = findBlock(firstID)
    local second = findBlock(secondID)

    if not first or not second then
        return false, "Block not found"
    end

    if first.Type == "End" then
        return false, "End block cannot connect forward"
    end

    if second.Type == "Start" then
        return false, "Start block cannot receive a connection"
    end

    first.ConnectedTo = secondID

    local exists = false

    for _, connection in ipairs(self.Connections) do
        if connection.From == firstID
        and connection.To == secondID then
            exists = true
            break
        end
    end

    if not exists then
        self.Connections[#self.Connections + 1] = {
            From = firstID,
            To = secondID
        }
    end

    return true
end

function Macros:Disconnect(id)
    local block = findBlock(id)

    if not block then
        return false, "Block not found"
    end

    block.ConnectedTo = nil

    for index = #self.Connections, 1, -1 do
        if self.Connections[index].From == id then
            table.remove(self.Connections, index)
        end
    end

    return true
end

function Macros:GetBlocks()
    return copyBlocks(self.Blocks)
end

function Macros:GetConnections()
    local result = {}

    for index, connection in ipairs(self.Connections) do
        result[index] = {
            From = connection.From,
            To = connection.To
        }
    end

    return result
end

function Macros:GetBlock(id)
    local block = findBlock(id)

    if not block then
        return nil
    end

    return copyBlock(block)
end

function Macros:Validate()
    local errors = {}
    local startCount = 0
    local endCount = 0

    for _, block in ipairs(self.Blocks) do
        if block.Type == "Start" then
            startCount = startCount + 1
        elseif block.Type == "End" then
            endCount = endCount + 1
        end

        if block.ConnectedTo then
            if not findBlock(block.ConnectedTo) then
                errors[#errors + 1] =
                    "Block " .. block.ID .. " has an invalid connection"
            end
        end
    end

    if #self.Blocks > 0 and startCount ~= 1 then
        errors[#errors + 1] =
            "Macro must contain exactly one Start block"
    end

    if #self.Blocks > 0 and endCount ~= 1 then
        errors[#errors + 1] =
            "Macro must contain exactly one End block"
    end

    return #errors == 0, errors
end

function Macros:Export()
    return {
        Version = self.Version,
        Blocks = self:GetBlocks(),
        Connections = self:GetConnections()
    }
end

function Macros:Clear()
    self.Blocks = {}
    self.Connections = {}
    self.NextID = 1

    return true
end

function Macros:GetInfo()
    return {
        Name = self.Name,
        Version = self.Version,
        Status = self.Status,
        BlockCount = #self.Blocks,
        ConnectionCount = #self.Connections,
        NextID = self.NextID
    }
end

return Macros



-- LSAI Visual Macros
-- Version: 0.1.0

local Macros = {
    Version = "0.1.0",
    Blocks = {},
    Connections = {},
    NextID = 1
}

local allowedTypes = {
    "Start",
    "Text",
    "Condition",
    "Wait",
    "End"
}

local function isAllowedType(blockType)
    for _, value in ipairs(allowedTypes) do
        if value == blockType then
            return true
        end
    end

    return false
end

function Macros:AddBlock(blockType, value)
    if not isAllowedType(blockType) then
        return nil
    end

    local block = {
        ID = self.NextID,
        Type = blockType,
        Value = value or "",
        ConnectedTo = nil
    }

    self.NextID = self.NextID + 1
    table.insert(self.Blocks, block)

    return block.ID
end

function Macros:RemoveBlock(id)
    for index, block in ipairs(self.Blocks) do
        if block.ID == id then
            table.remove(self.Blocks, index)

            for _, item in ipairs(self.Blocks) do
                if item.ConnectedTo == id then
                    item.ConnectedTo = nil
                end
            end

            return true
        end
    end

    return false
end

function Macros:Connect(firstID, secondID)
    local first
    local second

    for _, block in ipairs(self.Blocks) do
        if block.ID == firstID then
            first = block
        elseif block.ID == secondID then
            second = block
        end
    end

    if not first or not second or firstID == secondID then
        return false
    end

    first.ConnectedTo = secondID
    return true
end

function Macros:Disconnect(id)
    for _, block in ipairs(self.Blocks) do
        if block.ID == id then
            block.ConnectedTo = nil
            return true
        end
    end

    return false
end

function Macros:GetBlocks()
    return self.Blocks
end

function Macros:Clear()
    self.Blocks = {}
    self.Connections = {}
    self.NextID = 1
end

return Macros


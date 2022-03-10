local LiveAttributes = {}

local SupportedTypes = {
    ["number"] = true;
    ["string"] = true;
    ["boolean"] = true;
    ["UDim"] = true;
    ["UDim2"] = true;
    ["Vector2"] = true;
    ["Vector3"] = true;
    ["BrickColor"] = true;
    ["Color3"] = true;
    ["NumberSequence"] = true;
    ["NumberRange"] = true;
    ["ColorSequence"] = true;
    ["Rect"] = true;
}

function LiveAttributes.New(DefaultTable, DefaultObject)
    for AttributeName, AttributeValue in pairs(DefaultTable) do
        if SupportedTypes[typeof(AttributeValue)] and type(AttributeName) == "string" then
            if DefaultObject:GetAttribute(AttributeName) == nil then
                DefaultObject:SetAttribute(tostring(AttributeName), AttributeValue)
            end
        end
    end

    local ConnectionTable   = {}
    local Metatable = {
        __index = DefaultTable;
        __newindex = function(ThisTable, Key, ObjectAttributeValue)
            local InitialSetting     = type(ObjectAttributeValue) == "table";
            if InitialSetting then
                local Object        = ObjectAttributeValue[1]; --Object
                local AttributeName = ObjectAttributeValue[2]; --Attribute name
                local ThisValue     = ObjectAttributeValue[3]; --Intended value
                if ThisValue then
                    --print("Setting value", Key)
                    if SupportedTypes[typeof(ThisValue)] and type(AttributeName) == "string" then
                        Object:SetAttribute(AttributeName, ThisValue)
                    end
                end
                if ConnectionTable[Object] == nil then
                    ConnectionTable[Object] = {};
                    ConnectionTable[Object]["__OnDestroying"] = Object.Destroying:Connect(function()
                        for _, Conn in pairs(ConnectionTable[Object]) do
                            Conn:Disconnect()
                        end
                        table.clear(ConnectionTable[Object])
                        ConnectionTable[Object] = nil;
                    end)
                end
                --Setupconnections
                ConnectionTable[Object][AttributeName] = Object:GetAttributeChangedSignal(AttributeName):Connect(function()
                    DefaultTable[Key] = Object:GetAttribute(AttributeName) or DefaultTable[Key];
                end)
                --set initial connection
                DefaultTable[Key] = Object:GetAttribute(AttributeName) or DefaultTable[Key];
            else
                for ThisObject, Connections in pairs(ConnectionTable) do
                    local FindKey = Connections[Key]
                    if FindKey then
                        --print("Setting value 2")
                        if SupportedTypes[typeof(ObjectAttributeValue)] and type(Key) == "string" then
                            ThisObject:SetAttribute(Key, ObjectAttributeValue)
                        end
                    else
                        ThisTable[Key] = {DefaultObject, Key, ObjectAttributeValue}
                    end
                end
            end
        end;
        __call = function(...)
            local SafeTable = {}
            for n, x in pairs(DefaultTable) do
                SafeTable[n] = x
            end
            return SafeTable
        end;
    }

    local ThisMetatable = setmetatable({}, Metatable)
    for n, x in pairs(DefaultTable) do
        ThisMetatable[n] = {DefaultObject, n, DefaultObject:GetAttribute(n) or x}
    end
    return ThisMetatable
end

return LiveAttributes

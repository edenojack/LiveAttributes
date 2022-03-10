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
                    print("Setting value")
                    Object:SetAttribute(AttributeName, ThisValue)
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
                    DefaultTable[Key] = Object:GetAttribute(AttributeName);
                end)
                --set initial connection
                DefaultTable[Key] = Object:GetAttribute(AttributeName);
            else
                for ThisObject, Connections in pairs(ConnectionTable) do
                    local FindKey = Connections[Key]
                    if FindKey then
                        print("Setting value 2")
                        ThisObject:SetAttribute(Key, ObjectAttributeValue)
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

    return setmetatable({}, Metatable)
end

return LiveAttributes

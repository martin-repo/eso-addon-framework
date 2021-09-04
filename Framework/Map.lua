---@class Map
EsoAddonFramework_Framework_Map = { }

---@param map table # Table with non-numeric or non-contiguous keys
---@param key any
---@param value any
function EsoAddonFramework_Framework_Map.Add(map, key, value)
    if (map[key] ~= nil) then
        error("The key already exists.")
    end

    map[key] = value
end

---@param map table # Table with non-numeric or non-contiguous keys
---@param predicate fun(key:any, value:any):boolean
---@return boolean
function EsoAddonFramework_Framework_Map.All(map, predicate)
    for key, value in pairs(map) do
        if (predicate(key, value) ~= true) then
            return false
        end
    end

    return true
end

---@param map table # Table with non-numeric or non-contiguous keys
---@param predicate? fun(key:any, value:any):boolean
---@return boolean
function EsoAddonFramework_Framework_Map.Any(map, predicate)
    if (predicate == nil) then
        return next(map) ~= nil
    end

    for key, value in pairs(map) do
        if (predicate(key, value) == true) then
            return true
        end
    end

    return false
end

---@param map table # Table with non-numeric or non-contiguous keys
---@param keyComparer? fun(a:any, b:any):boolean
---@return fun():any, any
function EsoAddonFramework_Framework_Map.ByKey(map, keyComparer)
    -- map == {
    --     Beta = "Value1",
    --     Alpha = "Value2"
    -- }

    local indexedKeys = { }
    for key, _ in pairs(map) do
        table.insert(indexedKeys, key)
    end
    -- indexedKeys == {
    --     [1] = "Beta",
    --     [2] = "Alpha"
    -- }

    table.sort(indexedKeys, keyComparer)
    -- indexedKeys == {
    --     [1] = "Alpha"
    --     [2] = "Beta"
    -- }

    local current = 0
    local enumerator = function()
        current = current + 1
        if (indexedKeys[current] == nil) then
            return nil
        end

        local key = indexedKeys[current]
        local value = map[key]
        -- First iteration;
        -- key == "Alpha"
        -- value == "Value2"
        -- Second iteration;
        -- key == "Beta"
        -- value = "Value1"

        return key, value
    end

    return enumerator
end

---@param map table # Table with non-numeric or non-contiguous keys
---@param valueComparer? fun(a:any, b:any):boolean
---@return fun():any, any
function EsoAddonFramework_Framework_Map.ByValue(map, valueComparer)
    -- map == {
    --     Beta = "Value2",
    --     Alpha = "Value1"
    -- }

    local valueKeys = { }
    local indexedValues = { }
    for key, value in pairs(map) do
        valueKeys[value] = key
        table.insert(indexedValues, value)
    end
    -- valueKeys == {
    --     Value2 = "Beta",
    --     Value1 = "Alpha"
    -- }
    -- indexedValues == {
    --     [1] = "Value2",
    --     [2] = "Value1"
    -- }

    table.sort(indexedValues, valueComparer)
    -- indexedValues == {
    --     [1] = "Value1"
    --     [2] = "Value2"
    -- }

    local current = 0
    local enumerator = function()
        current = current + 1
        if (indexedValues[current] == nil) then
            return nil
        end

        local value = indexedValues[current]
        local key = valueKeys[value]
        -- First iteration;
        -- value == "Value1"
        -- key == "Alpha"
        -- Second iteration;
        -- value = "Value2"
        -- key == "Beta"

        return key, value
    end

    return enumerator
end

---@param map table # Table with non-numeric or non-contiguous keys
function EsoAddonFramework_Framework_Map.Clear(map)
    for key, _ in pairs(map) do
        map[key] = nil
    end
end

---@param map table # Table with non-numeric or non-contiguous keys
---@param deep? boolean
---@return table
function EsoAddonFramework_Framework_Map.Clone(map, deep)
    local clone = { }
    for key, value in pairs(map) do
        if (deep == true and type(value) == "table") then
            clone[key] = EsoAddonFramework_Framework_Map.Clone(value, true)
        else
            clone[key] = value
        end
    end

    return clone
end

---@param map table # Table with non-numeric or non-contiguous keys
---@param otherMap table
---@param overwrite? boolean
function EsoAddonFramework_Framework_Map.ConcatMap(map, otherMap, overwrite)
    for otherKey, otherValue in pairs(otherMap) do
        if (map[otherKey] == nil or overwrite == true) then
            map[otherKey] = otherValue
        end
    end
end

---@param map table # Table with non-numeric or non-contiguous keys
---@return number
function EsoAddonFramework_Framework_Map.Count(map)
    local count = 0
    for _, _ in pairs(map) do
        count = count + 1
    end

    return count
end

---@param map table # Table with non-numeric or non-contiguous keys
---@return fun():any, any
function EsoAddonFramework_Framework_Map.Enumerate(map)
    return pairs(map)
end

---@param map table # Table with non-numeric or non-contiguous keys
---@param value any
---@param valueComparer? fun(mapValue:any, searchValue:any):boolean
---@return any?
function EsoAddonFramework_Framework_Map.GetKey(map, value, valueComparer)
    for key, currentValue in pairs(map) do
        if ((valueComparer ~= nil and valueComparer(currentValue, value)) or
            (valueComparer == nil and currentValue == value)) then
            return key
        end
    end

    return nil
end

---@param map table # Table with non-numeric or non-contiguous keys
---@param predicate fun(key:any, value:any):boolean
---@param keyComparer? fun(a:any, b:any):boolean
---@return table
function EsoAddonFramework_Framework_Map.GetKeys(map, predicate, keyComparer)
    local keys = { }
    for key, value in pairs(map) do
        if (predicate(key, value) == true) then
            table.insert(keys, key)
        end
    end

    table.sort(keys, keyComparer)
    return keys
end

---@param map table # Table with non-numeric or non-contiguous keys
---@param keyComparer? fun(a:any, b:any):boolean
---@return table # Array
function EsoAddonFramework_Framework_Map.Keys(map, keyComparer)
    local keys = { }
    for key, _ in pairs(map) do
        table.insert(keys, key)
    end

    table.sort(keys, keyComparer)
    return keys
end

---@param map table # Table with non-numeric or non-contiguous keys
---@param key any
function EsoAddonFramework_Framework_Map.Remove(map, key)
    if (map[key] == nil) then
        error("The key does not exist.")
    end

    map[key] = nil
end

---@param map table # Table with non-numeric or non-contiguous keys
---@param selector fun(value:any):any
---@return table
function EsoAddonFramework_Framework_Map.Select(map, selector)
    local transformed = { }
    for key, value in pairs(map) do
        transformed[key] = selector(value)
    end

    return transformed
end

---@param map table # Table with non-numeric or non-contiguous keys
---@param valueComparer? fun(a:any, b:any):boolean
---@return table # Array
function EsoAddonFramework_Framework_Map.Values(map, valueComparer)
    local values = { }
    for _, value in pairs(map) do
        table.insert(values, value)
    end

    table.sort(values, valueComparer)
    return values
end

---@param map table # Table with non-numeric or non-contiguous keys
---@param predicate fun(key:any, value:any):boolean
function EsoAddonFramework_Framework_Map.Where(map, predicate)
    local filtered = { }
    for key, value in pairs(map) do
        if (predicate(key, value)) then
            filtered[key] = value
        end
    end

    return filtered
end
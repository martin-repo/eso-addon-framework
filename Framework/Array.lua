---@class Array
EsoAddonFramework_Framework_Array = { }

---@param array table # Table with numeric, contiguous keys
---@param value any
function EsoAddonFramework_Framework_Array.Add(array, value)
    table.insert(array, value)
end

---@param array table # Table with numeric, contiguous keys
---@param values table # Table with numeric, contiguous keys
function EsoAddonFramework_Framework_Array.AddRange(array, values)
    for _, value in ipairs(values) do
        table.insert(array, value)
    end
end

---@param array table # Table with numeric, contiguous keys
---@param predicate fun(value:any):boolean
---@return boolean
function EsoAddonFramework_Framework_Array.All(array, predicate)
    for _, value in ipairs(array) do
        if (predicate(value) ~= true) then
            return false
        end
    end

    return true
end

local function Any(array, predicate)
    if (predicate == nil) then
        return next(array) ~= nil
    end

    for _, value in ipairs(array) do
        if (predicate(value) == true) then
            return true
        end
    end

    return false
end

---@param array table # Table with numeric, contiguous keys
---@param predicate? fun(value:any):boolean
---@return boolean
function EsoAddonFramework_Framework_Array.Any(array, predicate)
    return Any(array, predicate)
end

---@param array table # Table with numeric, contiguous keys
function EsoAddonFramework_Framework_Array.Clear(array)
    for index = #array, 1, -1 do
        array[index] = nil
    end
end

local function Clone(array, deep)
    local clone = { }
    for _, value in ipairs(array) do
        if (deep == true and type(value) == "table") then
            table.insert(clone, Clone(value, true))
        else
            table.insert(clone, value)
        end
    end

    return clone
end

---@param array table # Table with numeric, contiguous keys
---@param deep? boolean
---@return table
function EsoAddonFramework_Framework_Array.Clone(array, deep)
    return Clone(array, deep)
end

---@param array table # Table with numeric, contiguous keys
---@param value any
---@param valueComparer? fun(arrayValue:any, searchValue:any):boolean
---@return boolean
function EsoAddonFramework_Framework_Array.Contains(array, value, valueComparer)
    for _, currentValue in ipairs(array) do
        if ((valueComparer ~= nil and valueComparer(currentValue, value)) or
            (valueComparer == nil and currentValue == value)) then
            return true
        end
    end

    return false
end

---@param array table # Table with numeric, contiguous keys
---@return number
function EsoAddonFramework_Framework_Array.Count(array)
    return #array
end

---@param array table # Table with numeric, contiguous keys
---@param valueComparer? fun(a:any, b:any):boolean
---@return table
function EsoAddonFramework_Framework_Array.Distinct(array, valueComparer)
    local distinct = { }

    for _, currentValue in ipairs(array) do
        if (not Any(
            distinct,
            function(value)
                if ((valueComparer ~= nil and valueComparer(currentValue, value)) or
                    (valueComparer == nil and currentValue == value)) then
                    return true
                end

                return false
            end)) then
            table.insert(distinct, currentValue)
        end
    end

    return distinct
end

---@param array table # Table with numeric, contiguous keys
---@return fun():number, any
function EsoAddonFramework_Framework_Array.Enumerate(array)
    return ipairs(array)
end

local function FirstOrDefault(array, predicate)
    if (predicate == nil) then
        local index = next(array)
        if (index == nil) then
            return nil
        end

        return array[index]
    end

    for _, value in ipairs(array) do
        if (predicate(value)) then
            return value
        end
    end

    return nil
end

---@param array table # Table with numeric, contiguous keys
---@param predicate? fun(value:any):boolean
---@return any
function EsoAddonFramework_Framework_Array.First(array, predicate)
    local value = FirstOrDefault(array, predicate)
    if (value == nil) then
        error("No value matched the predicate.")
    end

    return value
end

---@param array table # Table with numeric, contiguous keys
---@param predicate? fun(value:any):boolean
---@return any?
function EsoAddonFramework_Framework_Array.FirstOrDefault(array, predicate)
    return FirstOrDefault(array, predicate)
end

---@param array table # Table with numeric, contiguous keys
---@param value any
---@param valueComparer? fun(arrayValue:any, searchValue:any):boolean
---@return number
function EsoAddonFramework_Framework_Array.IndexOf(array, value, valueComparer)
    for currentIndex, currentValue in ipairs(array) do
        if ((valueComparer ~= nil and valueComparer(currentValue, value)) or
            (valueComparer == nil and currentValue == value)) then
            return currentIndex
        end
    end

    return 0
end

local function LastOrDefault(array, predicate)
    if (predicate == nil) then
        if (#array == 0) then
            return nil
        end

        return array[#array]
    end

    for index = #array, 1, -1 do
        if (predicate(array[index])) then
            return array[index]
        end
    end

    return nil
end

---@param array table # Table with numeric, contiguous keys
---@param predicate? fun(value:any):boolean
---@return any
function EsoAddonFramework_Framework_Array.Last(array, predicate)
    local value = LastOrDefault(array, predicate)
    if (value == nil) then
        error("No value matched the predicate.")
    end

    return value
end


---@param array table # Table with numeric, contiguous keys
---@param predicate? fun(value:any):boolean
---@return any?
function EsoAddonFramework_Framework_Array.LastOrDefault(array, predicate)
    return LastOrDefault(array, predicate)
end

---@param array table # Table with numeric, contiguous keys
---@param value any
---@param valueComparer? fun(arrayValue:any, searchValue:any):boolean
---@return number # Number of values removed
function EsoAddonFramework_Framework_Array.Remove(array, value, valueComparer)
    local removeCount = 0

    for index = #array, 1, -1 do
        if ((valueComparer ~= nil and valueComparer(array[index], value)) or
            (valueComparer == nil and array[index] == value)) then
            table.remove(array, index)
            removeCount = removeCount + 1
        end
    end

    return removeCount
end

---@param array table # Table with numeric, contiguous keys
---@param predicate fun(value:any):boolean
---@return number # Number of values removed
function EsoAddonFramework_Framework_Array.RemoveWhere(array, predicate)
    local removeCount = 0

    for index = #array, 1, -1 do
        if (predicate(array[index])) then
            table.remove(array, index)
            removeCount = removeCount + 1
        end
    end

    return removeCount
end

---@param array table # Table with numeric, contiguous keys
---@param selector fun(value:any):any
---@return table
function EsoAddonFramework_Framework_Array.Select(array, selector)
    local transformed = { }
    for _, value in ipairs(array) do
        table.insert(transformed, selector(value))
    end

    return transformed
end

---@param array table # Table with numeric, contiguous keys
---@param valueComparer? fun(a:any, b:any):boolean
function EsoAddonFramework_Framework_Array.Sort(array, valueComparer)
    table.sort(array, valueComparer)
end

---@param array table # Table with numeric, contiguous keys
---@param selector fun(value:any):any, any
---@returns table
function EsoAddonFramework_Framework_Array.ToMap(array, selector)
    local map = { }
    for _, value in ipairs(array) do
        local mapKey, mapValue = selector(value)
        map[mapKey] = mapValue
    end

    return map
end

---@param array table # Table with numeric, contiguous keys
---@param predicate fun(value:any):boolean
function EsoAddonFramework_Framework_Array.Where(array, predicate)
    local filtered = { }
    for _, value in ipairs(array) do
        if (predicate(value)) then
            table.insert(filtered, value)
        end
    end

    return filtered
end
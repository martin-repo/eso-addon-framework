require "Framework/Array"
require "Framework/String"

local Array = EsoAddonFramework_Framework_Array
local String = EsoAddonFramework_Framework_String

EsoAddonFramework_Framework_Map = { } -- Map mock

-- Add
do
    local array = { "Value1" }
    Array.Add(array, "Value2")
    assert(#array == 2)
    assert(array[1] == "Value1")
    assert(array[2] == "Value2")
end

    -- AddRange
do
    local array = { }
    Array.AddRange(array, { "Value1", "Value2" })
    assert(#array == 2)
    assert(array[1] == "Value1")
    assert(array[2] == "Value2")
end

    -- All
do
    local array = { "Value1", "Value2" }
    local all = Array.All(array, function(value) return String.StartsWith(value, "Value") end)
    assert(all == true)
    all = Array.All(array, function(value) return value == "Value1" end)
    assert(all == false)
end

-- Any
do
    local array = { }
    local any = Array.Any(array)
    assert(any == false)
    array = { "Any" }
    any = Array.Any(array)
    assert(any == true)

    array = { "Value1", "Value2" }
    any = Array.Any(array, function(value) return value == "Value1" end)
    assert(any == true)
    any = Array.Any(array, function(value) return value == "Value3" end)
    assert(any == false)
end

-- Clear
do
    local array = { "Value1" }
    Array.Clear(array)
    assert(#array == 0)
end

-- Clone
do
    local array = { "Value1", { "Value2", "Value3" } }
    local clone = Array.Clone(array)
    clone[2][1] = "Value4"
    assert(array ~= clone)
    assert(array[2][1] == "Value4")

    function EsoAddonFramework_Framework_Map.Clone(map, deep)
        return { "Value2", "Value3" }
    end

    array = { "Value1", { "Value2", "Value3" } }
    clone = Array.Clone(array, true)
    clone[2][1] = "Value4"
    assert(array ~= clone)
    assert(array[2][1] ~= "Value4")
end

-- Contains
do
    local array = { "Value1", "Value2" }
    local contains = Array.Contains(array, "Value2")
    assert(contains == true)
    contains = Array.Contains(array, "Value3")
    assert(contains == false)

    array = { "Value1", "Value2" }
    contains = Array.Contains(array, "1", function(arrayValue, searchValue) return String.EndsWith(arrayValue, searchValue) end)
    assert(contains == true)
    contains = Array.Contains(array, "3", function(arrayValue, searchValue) return String.EndsWith(arrayValue, searchValue) end)
    assert(contains == false)
end

-- Contains
do
    local array = { "Value1", "Value2" }
    local count = Array.Count(array)
    assert(count == 2)
end

-- Distinct
do
    local array = { "Value1", "Value2", "Value2", "Value1" }
    local distinct = Array.Distinct(array)
    assert(#distinct == 2)
    assert(distinct[1] == "Value1")
    assert(distinct[2] == "Value2")

    distinct = Array.Distinct(array, function(a, b) return string.sub(a, 6, 6) == string.sub(b, 6, 6) end)
    assert(#distinct == 2)
    assert(distinct[1] == "Value1")
    assert(distinct[2] == "Value2")
end

-- Enumerate
do
    local array = { "Value1", "Value2" }
    local arrayIterator, arrayReference, arrayIndex = Array.Enumerate(array)
    local arrayValue
    arrayIndex, arrayValue = arrayIterator(arrayReference, arrayIndex)
    assert(arrayIndex == 1)
    assert(arrayValue == "Value1")
    arrayIndex, arrayValue = arrayIterator(arrayReference, arrayIndex)
    assert(arrayIndex == 2)
    assert(arrayValue == "Value2")
    arrayIndex, arrayValue = arrayIterator(arrayReference, arrayIndex)
    assert(arrayIndex == nil)
    assert(arrayValue == nil)
end

-- First
do
    local array = { "Value1", "Value2", "Value3" }
    local first = Array.First(array)
    assert(first == "Value1")

    first = Array.First(array, function(value) return value == "Value2" end)
    assert(first == "Value2")

    local success, message = pcall(function() Array.First(array, function(value) return value == "Value4" end) end)
    assert(success == false)
    assert(String.EndsWith(message, "No value matched the predicate."))
end

-- FirstOrDefault
do
    local array = { "Value1", "Value2", "Value3" }

    local firstOrDefault = Array.FirstOrDefault(array)
    assert(firstOrDefault == "Value1")

    firstOrDefault = Array.FirstOrDefault(array, function(value) return value == "Value2" end)
    assert(firstOrDefault == "Value2")

    firstOrDefault = Array.FirstOrDefault(array, function(value) return value == "Value4" end)
    assert(firstOrDefault == nil)

    array = { }
    firstOrDefault = Array.FirstOrDefault(array)
    assert(firstOrDefault == nil)
end

-- IndexOf
do
    local array = { "Value1", "Value2" }
    local indexOf = Array.IndexOf(array, "Value2")
    assert(indexOf == 2)
    indexOf = Array.IndexOf(array, "2", function(arrayValue, searchValue) return String.EndsWith(arrayValue, searchValue) end)
    assert(indexOf == 2)
    indexOf = Array.IndexOf(array, "Value3")
    assert(indexOf == 0)
    indexOf = Array.IndexOf(array, "3", function(arrayValue, searchValue) return String.EndsWith(arrayValue, searchValue) end)
    assert(indexOf == 0)
end

-- Last
do
    local array = { "Value1", "Value2", "Value3" }
    local last = Array.Last(array)
    assert(last == "Value3")

    last = Array.Last(array, function(value) return value == "Value2" end)
    assert(last == "Value2")

    local success, message = pcall(function() Array.Last(array, function(value) return value == "Value4" end) end)
    assert(success == false)
    assert(String.EndsWith(message, "No value matched the predicate."))
end

-- LastOrDefault
do
    local array = { "Value1", "Value2", "Value3" }

    local lastOrDefault = Array.LastOrDefault(array)
    assert(lastOrDefault == "Value3")

    lastOrDefault = Array.LastOrDefault(array, function(value) return value == "Value2" end)
    assert(lastOrDefault == "Value2")

    lastOrDefault = Array.LastOrDefault(array, function(value) return value == "Value4" end)
    assert(lastOrDefault == nil)

    array = { }
    lastOrDefault = Array.LastOrDefault(array)
    assert(lastOrDefault == nil)
end

-- Remove
do
    local array = { "Value1", "Value2" }
    Array.Remove(array, "Value2")
    assert(#array == 1)
    assert(array[1] == "Value1")

    array = { "Value1", "Value2" }
    Array.Remove(array, "2", function(arrayValue, searchValue) return String.EndsWith(arrayValue, searchValue) end)
    assert(#array == 1)
    assert(array[1] == "Value1")
end

-- Remove
do
    local array = { "Value1", "Value2", "Value2", "Value3" }
    Array.RemoveWhere(array, function(value) return String.EndsWith(value, "2") end)
    assert(#array == 2)
    assert(array[1] == "Value1")
    assert(array[2] == "Value3")
end

-- Select
do
    local array = { "Value1", "Value2" }
    local select = Array.Select(array, function(value) return string.sub(value, 6, 6) end)
    assert(#select == 2)
    assert(select[1] == "1")
    assert(select[2] == "2")
end

-- Sort
do
    local array = { "Value2", "Value1" }
    Array.Sort(array)
    assert(#array == 2)
    assert(array[1] == "Value1")
    assert(array[2] == "Value2")

    array = { "A2", "B1" }
    Array.Sort(array, function(a, b) return string.sub(a, 2, 2) < string.sub(b, 2, 2) end)
    assert(#array == 2)
    assert(array[1] == "B1")
    assert(array[2] == "A2")
end

-- ToMap
do
    local array = { { "Value1", "ValueA"}, { "Value2", "ValueB"} }
    local map = Array.ToMap(array, function(value) return value[1], value[2] end)
    assert(map.Value1 == "ValueA")
    assert(map.Value2 == "ValueB")
end

-- Where
do
    local array = { "Value1", "Value2A", "Value2B", "Value3" }
    local where = Array.Where(array, function(value) return string.sub(value, 6, 6) == "2" end)
    assert(#where == 2)
    assert(where[1] == "Value2A")
    assert(where[2] == "Value2B")
end
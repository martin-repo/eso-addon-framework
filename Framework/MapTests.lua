require "Framework/Map"
require "Framework/String"

local Map = EsoAddonFramework_Framework_Map
local String = EsoAddonFramework_Framework_String

-- Add
do
    local map = { Key1 = "Value1", Key2 = "Value2" }
    Map.Add(map, "Key3", "Value3")
    assert(Map.Count(map) == 3)
    assert(map.Key1 == "Value1")
    assert(map.Key2 == "Value2")
    assert(map.Key3 == "Value3")

    map = { Key1 = "Value1", Key2 = "Value2" }
    local success, message = pcall(function() Map.Add(map, "Key2", "Value3") end)
    assert(success == false)
    assert(String.EndsWith(message, "The key already exists."))
end

-- All
do
    local map = { Key1 = "Value1", Key2 = "Value2" }
    local all = Map.All(map, function(key, value) return String.StartsWith(value, "Value") end)
    assert(all == true)

    all = Map.All(map, function(key, value) return value == "Value1" end)
    assert(all == false)
end

-- Any
do
    local map = { }
    local any = Map.Any(map)
    assert(any == false)

    map = { Key1 = "Value1", Key2 = "Value2" }
    any = Map.Any(map)
    assert(any == true)

    any = Map.Any(map, function(key, value) return value == "Value1" end)
    assert(any == true)

    any = Map.All(map, function(key, value) return value == "Value3" end)
    assert(any == false)
end

-- ByKey
do
    local map = { BKey1 = "Value1", AKey2 = "Value2" }
    local byKey = Map.ByKey(map)
    local byKeyKey, byKeyValue = byKey()
    assert(byKeyKey == "AKey2")
    assert(byKeyValue == "Value2")
    byKeyKey, byKeyValue = byKey()
    assert(byKeyKey == "BKey1")
    assert(byKeyValue == "Value1")
    byKeyKey, byKeyValue = byKey()
    assert(byKeyKey == nil)
    assert(byKeyValue == nil)

    byKey = Map.ByKey(map, function(a, b) return string.sub(a, 5, 5) < string.sub(b, 5, 5) end)
    byKeyKey, byKeyValue = byKey()
    assert(byKeyKey == "BKey1")
    assert(byKeyValue == "Value1")
    byKeyKey, byKeyValue = byKey()
    assert(byKeyKey == "AKey2")
    assert(byKeyValue == "Value2")
    byKeyKey, byKeyValue = byKey()
    assert(byKeyKey == nil)
    assert(byKeyValue == nil)
end

-- ByValue
do
    local map = { Key1 = "BValue1", Key2 = "AValue2" }
    local byValue = Map.ByValue(map)
    local byValueKey, byValueValue = byValue()
    assert(byValueKey == "Key2")
    assert(byValueValue == "AValue2")
    byValueKey, byValueValue = byValue()
    assert(byValueKey == "Key1")
    assert(byValueValue == "BValue1")
    byValueKey, byValueValue = byValue()
    assert(byValueKey == nil)
    assert(byValueValue == nil)

    byValue = Map.ByValue(map, function(a, b) return string.sub(a, 7, 7) < string.sub(b, 7, 7) end)
    byValueKey, byValueValue = byValue()
    assert(byValueKey == "Key1")
    assert(byValueValue == "BValue1")
    byValueKey, byValueValue = byValue()
    assert(byValueKey == "Key2")
    assert(byValueValue == "AValue2")
    byValueKey, byValueValue = byValue()
    assert(byValueKey == nil)
    assert(byValueValue == nil)
end

-- Clear
do
    local map = { Key1 = "Value1", Key2 = "Value2" }
    Map.Clear(map)
    assert(Map.Count(map) == 0)
end

-- Clone
do
    local map = { Key1 = "Value1", Key2 = { Key3 = "Value3", Key4 = "Value4" } }
    local clone = Map.Clone(map)
    clone.Key2.Key3 = "Value5"
    assert(map ~= clone)
    assert(map.Key2.Key3 == "Value5")

    map = { Key1 = "Value1", Key2 = { Key3 = "Value3", Key4 = "Value4" } }
    clone = Map.Clone(map, true)
    clone.Key2.Key3 = "Value5"
    assert(map ~= clone)
    assert(map.Key2.Key3 ~= "Value5")
end

-- ConcatMap
do
    local map = { Key1 = "Value1", Key2 = "Value2" }
    local other = { Key1 = "ValueA", Key3 = "Value3" }
    Map.ConcatMap(map, other)
    assert(Map.Count(map) == 3)
    assert(map.Key1 == "Value1")
    assert(map.Key2 == "Value2")
    assert(map.Key3 == "Value3")

    map = { Key1 = "Value1", Key2 = "Value2" }
    Map.ConcatMap(map, other, true)
    assert(Map.Count(map) == 3)
    assert(map.Key1 == "ValueA")
    assert(map.Key2 == "Value2")
    assert(map.Key3 == "Value3")
end

-- Count
do
    local map = { Key1 = "Value1", Key2 = "Value2" }
    local count = Map.Count(map)
    assert(count == 2)
end

-- Enumerate
do
    local map = { Key1 = "Value1", Key2 = "Value2" }
    local mapIterator, mapReference, mapKey = Map.Enumerate(map)
    local mapValue
    mapKey, mapValue = mapIterator(mapReference, mapKey)
    assert(mapKey == "Key1" or mapKey == "Key2")
    assert(mapValue == "Value1" or mapValue == "Value2")
    mapKey, mapValue = mapIterator(mapReference, mapKey)
    assert(mapKey == "Key1" or mapKey == "Key2")
    assert(mapValue == "Value1" or mapValue == "Value2")
    mapKey, mapValue = mapIterator(mapReference, mapKey)
    assert(mapKey == nil)
    assert(mapValue == nil)
end

-- GetKey
do
    local map = { Key1 = "Value1", Key2 = "Value2" }
    local key = Map.GetKey(map, "Value2")
    assert(key == "Key2")

    key = Map.GetKey(map, "2", function(mapValue, searchValue) return String.EndsWith(mapValue, searchValue) end)
    assert(key == "Key2")
end

-- GetKeys
do
    local map = { Key1 = "Value1", Key2A = "Value2A", Key2B = "Value2B" }
    local keys = Map.GetKeys(map, function(mapKey, mapValue) return String.StartsWith(mapValue, "Value2") end)
    assert(#keys == 2)
    assert(keys[1] == "Key2A")
    assert(keys[2] == "Key2B")

    keys = Map.GetKeys(map, function(mapKey, mapValue) return String.StartsWith(mapValue, "Value2") end, function(a, b) return a > b end)
    assert(#keys == 2)
    assert(keys[1] == "Key2B")
    assert(keys[2] == "Key2A")
end

-- Keys
do
    local map = { Key1 = "Value1", Key2 = "Value2" }
    local keys = Map.Keys(map)
    assert(#keys == 2)
    assert(keys[1] == "Key1")
    assert(keys[2] == "Key2")

    keys = Map.Keys(map, function(a, b) return a > b end)
    assert(#keys == 2)
    assert(keys[1] == "Key2")
    assert(keys[2] == "Key1")
end

-- Remove
do
    local map = { Key1 = "Value1", Key2 = "Value2", Key3 = "Value3" }
    Map.Remove(map, "Key2")

    local keys = Map.Keys(map)
    assert(#keys == 2)
    assert(keys[1] == "Key1")
    assert(keys[2] == "Key3")

    local values = Map.Values(map)
    assert(#values == 2)
    assert(values[1] == "Value1")
    assert(values[2] == "Value3")

    local success, message = pcall(function() Map.Remove(map, "Key4") end)
    assert(success == false)
    assert(String.EndsWith(message, "The key does not exist."))
end

-- Select
do
    local map = { Key1 = "Value1", Key2 = "Value2" }
    local values = Map.Select(map, function(value) return value .. "A" end)
    assert(Map.Count(values) == 2)
    assert(values.Key1 == "Value1A")
    assert(values.Key2 == "Value2A")
end

-- Values
do
    local map = { Key1 = "Value1", Key2 = "Value2" }
    local values = Map.Values(map)
    assert(#values == 2)
    assert(values[1] == "Value1")
    assert(values[2] == "Value2")

    values = Map.Values(map, function(a, b) return a > b end)
    assert(#values == 2)
    assert(values[1] == "Value2")
    assert(values[2] == "Value1")
end

-- Where
do
    local map = { Key1 = "Value1", Key2A = "Value2A", Key2B = "Value2B", Key3 = "Value3" }
    local where = Map.Where(map, function(key, value) return value.sub(value, 6, 6) == "2" end)

    local enumerable = Map.ByKey(where)

    local key, value = enumerable()
    assert(key == "Key2A")
    assert(value == "Value2A")

    key, value = enumerable()
    assert(key == "Key2B")
    assert(value == "Value2B")

    key, value = enumerable()
    assert(key == nil)
    assert(value == nil)
end
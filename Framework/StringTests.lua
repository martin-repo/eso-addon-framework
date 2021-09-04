require "Framework/Array"
require "Framework/Color"
require "Framework/String"

local Color = EsoAddonFramework_Framework_Color
local String = EsoAddonFramework_Framework_String

EsoAddonFramework_Framework_Console = { } -- Console mock

-- EndsWith
do
    local str = "Abcdef"
    local endsWith = String.EndsWith(str, "def")
    assert(endsWith == true)
    endsWith = String.EndsWith(str, "Def")
    assert(endsWith == false)
end

-- Format
do
    local str = "Abc"
    local format = String.Format(str)
    assert(format == "|ceeeeeeAbc|r")

    str = "Abc {1} {2} {1}"
    format = String.Format(str, "one", "two")
    assert(format == "|ceeeeeeAbc |c00ff00one|ceeeeee |c00ff00two|ceeeeee |c00ff00one|ceeeeee|r")

    str = "Abc"
    format = String.Format(str, "one", "two")
    assert(format == "|ceeeeeeAbc|r ; one ; two")

    str = "Abc {1} {2}"
    format = String.Format(str, "one")
    assert(format == "|ceeeeeeAbc |c00ff00one|ceeeeee {2}|r ; {2} missing")

    str = "Abc {1:Red}"
    format = String.Format(str, "one")
    assert(format == "|ceeeeeeAbc |cff2222one|ceeeeee|r")

    str = "Abc {Def} {1}"
    format = String.Format(str, "one")
    assert(format == "|ceeeeeeAbc |c00ff00Def|ceeeeee |c00ff00one|ceeeeee|r")

    str = "Abc {Def:Red} {1}"
    format = String.Format(str, "one")
    assert(format == "|ceeeeeeAbc |cff2222Def|ceeeeee |c00ff00one|ceeeeee|r")

    str = "Abc {Def Ghi:Red} {1}"
    format = String.Format(str, "one")
    assert(format == "|ceeeeeeAbc |cff2222Def Ghi|ceeeeee |c00ff00one|ceeeeee|r")

    str = "Abc {Def-Ghi /Jkl}"
    format = String.Format(str)
    assert(format == "|ceeeeeeAbc |c00ff00Def-Ghi /Jkl|ceeeeee|r")

    str = "Abc {Def-Ghi /Jkl:Red}"
    format = String.Format(str)
    assert(format == "|ceeeeeeAbc |cff2222Def-Ghi /Jkl|ceeeeee|r")
end

-- Join
do
    -- Empty
    local array = { }
    local join = String.Join(array, ",")
    assert(join == "")

    join = String.Join(array, ",", "and")
    assert(join == "")

    -- Single
    array = { "a" }
    join = String.Join(array, ",")
    assert(join == "a")

    join = String.Join(array, ",", "and")
    assert(join == "a")

    -- Duo
    array = { "a", "b" }
    join = String.Join(array, ", ")
    assert(join == "a, b")

    join = String.Join(array, ", ", " and ")
    assert(join == "a and b")

    -- Multi
    array = { "a", "b", "c", "d" }
    join = String.Join(array, ", ")
    assert(join == "a, b, c, d")

    join = String.Join(array, ", ", " and ")
    assert(join == "a, b, c and d")
end

-- SetColor
do
    local str = "Abc"
    local setColor = String.SetColor(str, Color.Blue)
    assert(setColor == "|c00ffffAbc|r")

    str = "Abc"
    setColor = String.SetColor(str, Color.Gray)
    assert(setColor == "|c888888Abc|r")
end

-- Split
do
    local str = "Abc_Def_Ghi"
    local parts = String.Split(str, "_")
    assert(#parts == 3)
    assert(parts[1] == "Abc")
    assert(parts[2] == "Def")
    assert(parts[3] == "Ghi")

    str = "Abc__Def"
    parts = String.Split(str, "_")
    assert(#parts == 2)
    assert(parts[1] == "Abc")
    assert(parts[2] == "Def")

    str = "AbcDefGhi"
    parts = String.Split(str, "_")
    assert(#parts == 1)
    assert(parts[1] == "AbcDefGhi")

    str = "_Abc_"
    parts = String.Split(str, "_")
    assert(#parts == 1)
    assert(parts[1] == "Abc")
end

-- StartsWith
do
    local str = "Abcdef"
    local startsWith = String.StartsWith(str, "Abc")
    assert(startsWith == true)
    startsWith = String.StartsWith(str, "abc")
    assert(startsWith == false)
end

-- StripColorCodes
do
    local str = "|cffffffAbc|c000000Def|r"
    local stripColorCodes = String.StripColorCodes(str)
    assert(stripColorCodes == "AbcDef")
end
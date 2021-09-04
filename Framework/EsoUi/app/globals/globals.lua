--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:23' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

EVENT_MANAGER = GetEventManager()


--App implementation of zo_mixin 
------------------------------

function zo_mixin(object, ...)
    for i = 1, select("#", ...) do
        local source = select(i, ...)
        for k,v in pairs(source) do
            object[k] = v
        end
    end
end

function ZO_ColorizeString(r, g, b, string)
    return string.format("|c%.2x%.2x%.2x%s|r", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255), string)
end


--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

function ZO_CadwellSort(entry1, entry2)
    if entry1.order == entry2.order then
        return entry1.name < entry2.name
    else
        return entry1.order < entry2.order
    end
end

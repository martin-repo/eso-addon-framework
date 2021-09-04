--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

-- ==================================================================================
-- Input Handlers - All input handlers (mouse down, mouse click, mouse enter, etc) work in the same manner. For each handler,
-- a table of slot types is maintained. When an input event happens, if an entry matching the interacted slot type exists, the 
-- functions listed within that entry are executed in the listed order. However, upon the first function returning true, execution
-- stops.
-- ==================================================================================

--convenience function to execute handlers
function RunHandlers(handlerTable, slot, ...)
    local handlers = handlerTable[slot.slotType]
    if(not handlers) then return end

    for i = 1,#handlers do
        local done, returnVal = handlers[i](slot, ...)
        --terminate on the first handler that returns something that's not false or nil
        if(done) then
            return done, returnVal
        end
    end

    return false
end

function RunClickHandlers(handlerTable, slot, buttonId, ...)
    local handlers = handlerTable[slot.slotType]
    if(not handlers) then
        return 
    end
   
    local buttonHandlers = handlers[buttonId]
    if(not buttonHandlers) then return end
   
    for i = 1,#buttonHandlers do
        local done, returnVal = buttonHandlers[i](slot, ...)
        --terminate on the first handler that returns something that's not false or nil
        if(done) then
            return done, returnVal
        end
    end

    return false
end
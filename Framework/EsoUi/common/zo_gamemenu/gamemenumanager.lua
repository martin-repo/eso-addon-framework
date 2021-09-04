--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:25' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

------------------------
-- GameMenuManager
--
-- Collects and manages data to be used in game menues
------------------------

local subcategoryEntries = {}

function ZO_GameMenuManager_GetVisibleSettingsEntries()
    local settingsSubcategoryEntries = {}
    for i, entry in ipairs(subcategoryEntries) do
        local visible = entry.visible == nil or entry.visible
        if type(visible) == "function" then
            visible = visible()
        end
        if visible and entry.categoryName == GetString(SI_GAME_MENU_SETTINGS) then
            table.insert(settingsSubcategoryEntries, entry)
        end
    end
    return settingsSubcategoryEntries
end

function ZO_GameMenuManager_GetSubcategoriesEntries()
    return subcategoryEntries
end

function ZO_GameMenu_AddSettingPanel(data)
    data.categoryName = GetString(SI_GAME_MENU_SETTINGS)
    table.insert(subcategoryEntries, data)
end

function ZO_GameMenu_AddControlsPanel(data)
    data.categoryName = GetString(SI_GAME_MENU_CONTROLS)
    table.insert(subcategoryEntries, data)
end
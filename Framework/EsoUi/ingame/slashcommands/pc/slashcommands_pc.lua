--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

SLASH_COMMANDS[GetString(SI_SLASH_QUIT)] = function (txt)
    Quit()
end

SLASH_COMMANDS[GetString(SI_SLASH_FPS)] = function(txt)
    if GetSetting_Bool(SETTING_TYPE_UI, UI_SETTING_SHOW_FRAMERATE) then
        SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_FRAMERATE, "false")
    else
        SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_FRAMERATE, "true")
    end
end

SLASH_COMMANDS[GetString(SI_SLASH_LATENCY)] = function(txt)
    if GetSetting_Bool(SETTING_TYPE_UI, UI_SETTING_SHOW_LATENCY) then
        SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_LATENCY, "false")
    else
        SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_LATENCY, "true")
    end
end

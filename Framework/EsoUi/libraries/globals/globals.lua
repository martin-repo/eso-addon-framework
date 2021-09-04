--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

--[[ A Generally Accessible place for global callback registration and dispersal ]]--
CALLBACK_MANAGER = ZO_CallbackObject:New()

function NormalizePointToControl(x, y, control)
    local left, top, right, bottom = control:GetScreenRect()
    local width, height = right - left, bottom - top

    if width == 0 then width = 0.001 end
    if height == 0 then height = 0.001 end

    return (x - left) / width, (y - top) / height
end

function NormalizeMousePositionToControl(control)
    local mouseX, mouseY = GetUIMousePosition()
    return NormalizePointToControl(mouseX, mouseY, control)
end

function NormalizeUICanvasPoint(x, y)
    local width, height = GuiRoot:GetDimensions()
    return x / width, y / height
end

local function OnAddOnLoaded(event, name)
    if name == "ZO_Common" then
        zo_randomseed(GetSecondsSinceMidnight())
        EVENT_MANAGER:UnregisterForEvent("Globals_Common", EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent("Globals_Common", EVENT_ADD_ON_LOADED, OnAddOnLoaded)


local g_ignoreMouseDownEditFocusLoss = false

function IgnoreMouseDownEditFocusLoss()
    g_ignoreMouseDownEditFocusLoss = true
end

local function OnGlobalMouseDown(event, button)
    if g_ignoreMouseDownEditFocusLoss then
        g_ignoreMouseDownEditFocusLoss = false
        return
    end

    --If an edit control is focused and the player clicks off of it, then clear the focus
    if button == MOUSE_BUTTON_INDEX_LEFT then
        local focusEdit = WINDOW_MANAGER:GetFocusControl()
        if focusEdit then
            if not MouseIsOver(focusEdit) then
                focusEdit:LoseFocus()
            end
        end
    end
end

EVENT_MANAGER:RegisterForEvent("Globals_Common", EVENT_GLOBAL_MOUSE_DOWN, OnGlobalMouseDown)


local function OnPlayerDeactivated()
    ZO_Dialogs_ReleaseAllDialogs(true)
end

EVENT_MANAGER:RegisterForEvent("Globals_Common", EVENT_PLAYER_DEACTIVATED, OnPlayerDeactivated)

function SetupEditControlForNameValidation(editControl, maxNameLength)
    editControl:SetMaxInputChars(maxNameLength or CHARNAME_MAX_LENGTH)
    editControl:AddValidCharacter('\'')
    editControl:AddValidCharacter('-')
    editControl:AddValidCharacter(' ')
end

--[[
    Background Image Resizing Utility
--]]

local BG_ASPECT_RATIO = 1680 / 1050

local function GetAppropriateDimenions()
    local width, height = GuiRoot:GetDimensions()
    local windowAspectRatio = width / height

    -- If you want to show the whole image no matter what the resolution is, but letter box it, just change > to <
    if(windowAspectRatio > BG_ASPECT_RATIO) then
        height = width / BG_ASPECT_RATIO
    else
        width = height * BG_ASPECT_RATIO
    end

    return width, height
end

function ZO_ResizeControlForBestScreenFit(control)
    local width, height = GetAppropriateDimenions()
    control:SetDimensions(width, height)
end

function ZO_ResizeTextureWidthAndMaintainAspectRatio(texture, width)
    local originalX, originalY = texture:GetTextureFileDimensions()
    if originalX > width then
        local newY = (width / originalX) * originalY
        texture:SetWidth(width)
        texture:SetHeight(newY)
    else
        texture:SetWidth(originalX)
        texture:SetHeight(originalY)
    end
end

function ZO_StripGrammarMarkupFromCharacterName(characterName)
    return zo_strformat("<<1>>", characterName)
end

local ABBREVIATION_THRESHOLD = zo_pow(10, GetDigitGroupingSize())
-- Anywhere using ZO_AbbreviateNumber needs to ultimately run through ZO_FastFormatDecimalNumber because <<f:1>> does not work with suffixes.
function ZO_AbbreviateNumber(amount, precision, useUppercaseSuffixes)
    if amount >= ABBREVIATION_THRESHOLD then
        local shortAmount, suffix = AbbreviateNumber(amount, precision, useUppercaseSuffixes)

        return ZO_CommaDelimitDecimalNumber(shortAmount) .. suffix
    else
        return amount
    end
end

-- Anywhere using ZO_AbbreviateAndLocalizeNumber must NOT get passed through a <<f:1>> grammar format
function ZO_AbbreviateAndLocalizeNumber(amount, precision, useUppercaseSuffixes)
    if amount >= ABBREVIATION_THRESHOLD then
        local shortAmount, suffix = AbbreviateNumber(amount, precision, useUppercaseSuffixes)

        local formattedNumber = ZO_CommaDelimitDecimalNumber(shortAmount) .. suffix
        return ZO_FastFormatDecimalNumber(formattedNumber)
    else
        return amount
    end
end

function ZO_GetSpecializedItemTypeText(itemType, specializedItemType)
    if specializedItemType == SPECIALIZED_ITEMTYPE_NONE then
        return GetString("SI_ITEMTYPE", itemType)
    else
        return GetString("SI_SPECIALIZEDITEMTYPE", specializedItemType)
    end
end

function ZO_GetSpecializedItemTypeTextBySlot(bagId, slotIndex)
    local itemType, specializedItemType = GetItemType(bagId, slotIndex)
    return ZO_GetSpecializedItemTypeText(itemType, specializedItemType)
end

function ZO_GetCraftingSkillName(craftingType)
    return GetCraftingSkillName(craftingType)
end
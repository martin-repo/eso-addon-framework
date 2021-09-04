--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_GAMEPAD_COMBO_BOX_FONT = "ZoFontGamepad27"
ZO_GAMEPAD_COMBO_BOX_HIGHLIGHTED_FONT = "ZoFontGamepad36"
ZO_GAMEPAD_COMBO_BOX_PADDING = 16

-------------------------------------------------------------------------------
-- ZO_ComboBox_Gamepad
-------------------------------------------------------------------------------

ZO_ComboBox_Gamepad = ZO_Object.MultiSubclass(ZO_ComboBox_Base, ZO_CallbackObject)

function ZO_ComboBox_Gamepad:New(...)
    local object = ZO_CallbackObject.New(self)
    object:Initialize(...)
    return object
end

function ZO_ComboBox_Gamepad:Initialize(control)
    ZO_ComboBox_Base.Initialize(self, control)

    control.comboBoxObject = self

    self:InitializeKeybindStripDescriptors()
    self.m_active = false
    self.dropdownTemplate = ZO_GAMEPAD_COMBOBOX_DROPDOWN_TEMPLATE_STANDARD

    self.m_dropdown = GAMEPAD_COMBO_BOX_DROPDOWN
    self.m_focus = ZO_GamepadFocus:New(control)

    self.m_highlightedIndex = 1

    self.m_highlightColor = ZO_SELECTED_TEXT
    self.m_normalColor = ZO_DISABLED_TEXT
    
    self.m_font = ZO_GAMEPAD_COMBO_BOX_FONT
    self.m_highlightFont = ZO_GAMEPAD_COMBO_BOX_HIGHLIGHTED_FONT

    -- find the difference in font size to keep the width of text the same between them
    -- so line wrapping looks consistent between the two fonts
    local _, unselectedSize = _G[self.m_font]:GetFontInfo()
    local _, selectedSize = _G[self.m_highlightFont]:GetFontInfo()
    self.m_fontRatio = unselectedSize / selectedSize
end

function ZO_ComboBox_Gamepad:ShowDropdownInternal()
    self:ClearMenuItems()
    self.m_dropdown:SetTemplate(self.dropdownTemplate)

    self.m_dropdown:SetPadding(self.m_padding)

    self:AddMenuItems()

    self.m_container:SetHidden(true)
    self.m_dropdown:Show()
    self:SetVisible(true)
    self:HighlightSelectedItem()
end

function ZO_ComboBox_Gamepad:HideDropdownInternal()
    self:ClearMenuItems()
    self:SetVisible(false)

    self.m_container:SetHidden(false)
    self.m_dropdown:Hide()
    self:SetActive(false)

    self:FireCallbacks("OnHideDropdown")
end

function ZO_ComboBox_Gamepad:OnClearItems()
    self.m_highlightedIndex = nil
    self.m_currentData = nil
end

function ZO_ComboBox_Gamepad:OnItemAdded()
    if not self.m_highlightedIndex then
        self.m_highlightedIndex = 1
    end
end

function ZO_ComboBox_Gamepad:GetNormalColor(item)
    local itemColor = item.m_normalColor or self.m_normalColor
    return itemColor
end

function ZO_ComboBox_Gamepad:GetHighlightColor(item)
    local itemColor = item.m_highlightColor or self.m_highlightColor
    return itemColor
end

function ZO_ComboBox_Gamepad:GetHeight()
    if(self.m_selectedItemText) then
        return self.m_selectedItemText:GetTextHeight()
    end
    return self.m_container:GetHeight()
end

function ZO_ComboBox_Gamepad:AddMenuItems()
    for i = 1, #self.m_sortedItems do
        -- The variable item must be defined locally here, otherwise it won't work as an upvalue to the selection helper
        local item = self.m_sortedItems[i]
        local control = self.m_dropdown:AddItem(item)
        
        self:SetupMenuItemControl(control, item)

        local focusEntry = {
            control = control,
            data = item,
            activate = function(control, data) self:OnItemSelected(control, data) end,
            deactivate = function(control, data) self:OnItemDeselected(control, data) end,
        }
        self.m_focus:AddEntry(focusEntry)
    end

    self.m_dropdown:AnchorToControl(self.m_container, 0)
end

function ZO_ComboBox_Gamepad:SetupMenuItemControl(control, item)
    control.nameControl = control:GetNamedChild("Name")
    control.nameControl:SetText(item.name)
    control.nameControl:SetColor(self:GetNormalColor(item):UnpackRGBA())

    control.nameControl:SetFont(self.m_highlightFont) -- Use the highlighted font for sizing purposes
    control.nameControl:SetWidth(self.m_container:GetWidth())
    local height = control.nameControl:GetTextHeight()
    control:SetHeight(height)
    self.m_dropdown:AddHeight(height)

    if self.m_font then
        control.nameControl:SetFont(self.m_font)
        control.nameControl:SetWidth(self.m_container:GetWidth() * self.m_fontRatio)
    end
end

function ZO_ComboBox_Gamepad:OnItemSelected(control, data)
    control.nameControl:SetWidth(self.m_container:GetWidth())
    control.nameControl:SetColor(self:GetHighlightColor(data):UnpackRGBA())
    control.nameControl:SetFont(self.m_highlightFont)
    self:UpdateAnchors(control)

    self.m_currentData = data
    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor, self.m_keybindState)
    self:FireCallbacks("OnItemSelected", control, data)
end

function ZO_ComboBox_Gamepad:OnItemDeselected(control, data)
    control.nameControl:SetWidth(self.m_container:GetWidth() * self.m_fontRatio)
    control.nameControl:SetColor(self:GetNormalColor(data):UnpackRGBA())
    control.nameControl:SetFont(self.m_font)

    self:FireCallbacks("OnItemDeselected", control, data)
end

function ZO_ComboBox_Gamepad:ClearMenuItems()
   self.m_focus:RemoveAllEntries()
   self.m_dropdown:Clear()
end

function ZO_ComboBox_Gamepad:SetActive(active)
    if self.m_active ~= active then
        self.m_active = active

        if self.m_active then
            self.m_focus:Activate()
            self.m_keybindState = KEYBIND_STRIP:PushKeybindGroupState()
            KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor, self.m_keybindState)
        else
            self.m_focus:Deactivate()
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor, self.m_keybindState)
            KEYBIND_STRIP:PopKeybindGroupState()
            
            if self.deactivatedCallback and not self.blockDeactivatedCallback then
               self.deactivatedCallback(self.deactivatedCallbackArgs)
            end
        end
    end
end

function ZO_ComboBox_Gamepad:HighlightSelectedItem()
    self:SetHighlightedItem(self.m_highlightedIndex)
end

function ZO_ComboBox_Gamepad:SelectHighlightedItem()
    local focusItem = self.m_focus:GetFocusItem()
    local focusIndex = self.m_focus:GetFocus()
    if focusIndex then
        self.m_highlightedIndex = focusIndex -- This needs to come before self:SelectItem() otherwise self.m_focus:GetFocus() always returns nil
    end

    if focusItem then
        self:SelectItem(focusItem.data)
        PlaySound(SOUNDS.DEFAULT_CLICK)
    end
   
    self:Deactivate()
end

function ZO_ComboBox_Gamepad:IsHighlightedItemEnabled()
    if self.m_currentData then
        return self.m_currentData.enabled ~= false
    end
    return true
end

function ZO_ComboBox_Gamepad:SelectItemByIndex(index, ignoreCallback)
    self.m_highlightedIndex = index
    ZO_ComboBox_Base.SelectItemByIndex(self, index, ignoreCallback)
end

function ZO_ComboBox_Gamepad:SetHighlightedItem(highlightIndex, reselectIndex)
    self.m_focus:SetFocusByIndex(highlightIndex, reselectIndex)
end

function ZO_ComboBox_Gamepad:TrySelectItemByData(itemData, ignoreCallback)
    for i, data in ipairs(self.m_sortedItems) do
        if data.name == itemData.name then
            self:SelectItemByIndex(i, ignoreCallback)
            return true
        end
    end
    return false
end

do
    local INCLUDE_SAVED_INDEX = true
    function ZO_ComboBox_Gamepad:GetHighlightedIndex()
        return self.m_focus:GetFocus(INCLUDE_SAVED_INDEX)
    end
end

function ZO_ComboBox_Gamepad:Activate()
    self:SetActive(true)
    ZO_ComboBox_OpenDropdown(self:GetContainer())
    PlaySound(SOUNDS.COMBO_CLICK)
end

function ZO_ComboBox_Gamepad:Deactivate(blockCallback)
    self.blockDeactivatedCallback = blockCallback
    ZO_ComboBox_HideDropdown(self:GetContainer())
    self.blockDeactivatedCallback = false
end

function ZO_ComboBox_Gamepad:IsActive()
    return self.m_active
end

function ZO_ComboBox_Gamepad:SetDeactivatedCallback(callback, args)
    self.deactivatedCallbackArgs = args
    self.deactivatedCallback = callback
end

function ZO_ComboBox_Gamepad:SetKeybindAlignment(alignment)
    self.keybindStripDescriptor.alignment = alignment
end

function ZO_ComboBox_Gamepad:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor =
    {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        
        -- since we can now have combo boxes in dialogs and in normal ui elements
        -- we want to make sure our combo box is listening for the proper keybinds
        -- based on whether or not a dialog is active
        {
            keybind = "UI_SHORTCUT_NEGATIVE",
            name = GetString(SI_GAMEPAD_BACK_OPTION),
            callback = function()
               PlaySound(SOUNDS.GAMEPAD_MENU_BACK)
               self:Deactivate()
            end,
            visible = function() return not ZO_Dialogs_IsShowingDialog() end,
        },

        {
            keybind = "DIALOG_NEGATIVE",
            name = GetString(SI_GAMEPAD_BACK_OPTION),
            callback = function()
               self:Deactivate()
            end,
            visible = ZO_Dialogs_IsShowingDialog,
        },

        {
            keybind = "UI_SHORTCUT_PRIMARY",
            name = GetString(SI_GAMEPAD_SELECT_OPTION),
            callback = function()
                self:SelectHighlightedItem()
            end,
            enabled = function()
                return self:IsHighlightedItemEnabled()
            end,
            visible = function() return not ZO_Dialogs_IsShowingDialog() end,
        },

        {
            keybind = "DIALOG_PRIMARY",
            name = GetString(SI_GAMEPAD_SELECT_OPTION),
            callback = function()
                self:SelectHighlightedItem()
            end,
            enabled = function()
                return self:IsHighlightedItemEnabled()
            end,
            visible = ZO_Dialogs_IsShowingDialog,
        },
    }
end

function ZO_ComboBox_Gamepad:UpdateAnchors(selectedControl)
    -- The control box will always be centered on the original dropdown location
    local topItem = self.m_focus:GetItem(1)
    local topControl = topItem.control
    local offset = topControl:GetTop() - selectedControl:GetTop()

    self.m_dropdown:AnchorToControl(self.m_container, offset)
end

-------------------------------------------------------------------------------
-- ZO_GamepadComboBoxDropdown
-------------------------------------------------------------------------------

-- ZO_ComboBox_Gamepad_Dropdown is a singleton that is used by the current dropdown to display a list
ZO_GAMEPAD_COMBOBOX_DROPDOWN_TEMPLATE_STANDARD = "ZO_ComboBox_Item_Gamepad"
ZO_GAMEPAD_COMBOBOX_DROPDOWN_TEMPLATE_MULTISELECTION = "ZO_MultiSelection_ComboBox_Item_Gamepad"

ZO_GamepadComboBoxDropdown = ZO_Object:Subclass()

function ZO_GamepadComboBoxDropdown:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function ZO_GamepadComboBoxDropdown:Initialize(control)
    self.dropdownControl = control
    self.scrollControl = control:GetNamedChild("Scroll")
    self.backgroundControl = control:GetNamedChild("Background")
    self.templateName = ZO_GAMEPAD_COMBOBOX_DROPDOWN_TEMPLATE_STANDARD
    self.pools = 
    {
        [ZO_GAMEPAD_COMBOBOX_DROPDOWN_TEMPLATE_STANDARD] = ZO_ControlPool:New(ZO_GAMEPAD_COMBOBOX_DROPDOWN_TEMPLATE_STANDARD, self.scrollControl, ZO_GAMEPAD_COMBOBOX_DROPDOWN_TEMPLATE_STANDARD),
        [ZO_GAMEPAD_COMBOBOX_DROPDOWN_TEMPLATE_MULTISELECTION] = ZO_ControlPool:New(ZO_GAMEPAD_COMBOBOX_DROPDOWN_TEMPLATE_MULTISELECTION, self.scrollControl, ZO_GAMEPAD_COMBOBOX_DROPDOWN_TEMPLATE_MULTISELECTION)
    }
    self.lastControlAdded = nil
    self.height = 0
    self.padding = 0
    self.borderPadding = ZO_GAMEPAD_COMBO_BOX_PADDING
    self.minY = 70
    local function RefreshMaxY()
        self.maxY = GuiRoot:GetHeight() + ZO_GAMEPAD_QUADRANT_BOTTOM_OFFSET
    end
    RefreshMaxY()
    EVENT_MANAGER:RegisterForEvent("GamepadComboBoxDropdown", EVENT_SCREEN_RESIZED, RefreshMaxY)
end

function ZO_GamepadComboBoxDropdown:SetPadding(padding)
    self.padding = padding
end

function ZO_GamepadComboBoxDropdown:Show()
    self.dropdownControl:SetHidden(false)
end

function ZO_GamepadComboBoxDropdown:Hide()
    self.dropdownControl:SetHidden(true)
end

function ZO_GamepadComboBoxDropdown:AnchorToControl(control, offsetY)
    local controlTop = control:GetTop()
    local dropDownTop = controlTop + offsetY - self.borderPadding 
    local dropDownBottom = controlTop + offsetY + self.height + self.borderPadding

    local topYDelta = 0
    if dropDownTop < self.minY then
        topYDelta = (self.minY - dropDownTop)
    end

    local bottomYDelta = 0
    if dropDownBottom > self.maxY then
        bottomYDelta = (dropDownBottom - self.maxY)
    end

    self.dropdownControl:SetAnchor(TOPLEFT, control, TOPLEFT, 0, offsetY)
    self.dropdownControl:SetDimensions(control:GetWidth(), self.height)

    local backgroundOffsetYTop = -self.borderPadding + topYDelta
    local backgroundOffsetBottomTop = self.borderPadding - bottomYDelta

    self.scrollControl:SetAnchor(TOPLEFT, self.dropdownControl, TOPLEFT, -ZO_GAMEPAD_COMBO_BOX_PADDING, backgroundOffsetYTop)
    self.scrollControl:SetAnchor(BOTTOMRIGHT, self.dropdownControl, BOTTOMRIGHT, ZO_GAMEPAD_COMBO_BOX_PADDING, backgroundOffsetBottomTop)

    self.backgroundControl:SetAnchor(TOPLEFT, self.dropdownControl, TOPLEFT, -ZO_GAMEPAD_COMBO_BOX_PADDING, backgroundOffsetYTop)
    self.backgroundControl:SetAnchor(BOTTOMRIGHT, self.dropdownControl, BOTTOMRIGHT, ZO_GAMEPAD_COMBO_BOX_PADDING, backgroundOffsetBottomTop)
end

function ZO_GamepadComboBoxDropdown:AcquireControl(item, relativeControl)
    local padding = self.padding

    local controlPool = self:GetControlPoolFromTemplate(self.template)
    local control, key = controlPool:AcquireObject()

    control:SetAnchor(RIGHT, self.m_container, RIGHT, 0, padding, ANCHOR_CONSTRAINS_X)

    if relativeControl then
        control:SetAnchor(TOPLEFT, relativeControl, BOTTOMLEFT, 0, padding)
    else
        control:SetAnchor(TOPLEFT, self.dropdownControl, TOPLEFT, 0, padding)
    end

    control.key = key
    control.item = item

    return control
end

function ZO_GamepadComboBoxDropdown:AddHeight(height)
    self.height = self.height + height
end

function ZO_GamepadComboBoxDropdown:AddItem(data)
    local control = self:AcquireControl(data, self.lastControlAdded)
    self.lastControlAdded = control
    return control
end

function ZO_GamepadComboBoxDropdown:Clear()
    for _, pool in pairs(self.pools) do
        pool:ReleaseAllObjects()
    end
    self.lastControlAdded = nil
    self.height = 0
end

function ZO_GamepadComboBoxDropdown:SetTemplate(template)
    self.template = template
end

function ZO_GamepadComboBoxDropdown:GetControlPoolFromTemplate(template)
    return self.pools[template]
end

-- This is a control used by all gamepad combo boxes to display the dropdown
function ZO_ComboBox_Gamepad_Dropdowm_Initialize(control)
    GAMEPAD_COMBO_BOX_DROPDOWN = ZO_GamepadComboBoxDropdown:New(control)
end

-------------------------------------------------------------------------------
-- ZO_MultiSelection_ComboBox_Gamepad
-------------------------------------------------------------------------------

ZO_MultiSelection_ComboBox_Gamepad = ZO_ComboBox_Gamepad:Subclass()

function ZO_MultiSelection_ComboBox_Gamepad:New(...)
    return ZO_ComboBox_Gamepad.New(self, ...)
end

function ZO_MultiSelection_ComboBox_Gamepad:Initialize(control)
    ZO_ComboBox_Gamepad.Initialize(self, control)

    self.dropdownTemplate = ZO_GAMEPAD_COMBOBOX_DROPDOWN_TEMPLATE_MULTISELECTION
    self.itemDataToControl = {}
end

-- Overridden function
function ZO_MultiSelection_ComboBox_Gamepad:SelectHighlightedItem()
    local focusItem = self.m_focus:GetFocusItem()
    local focusIndex = self.m_focus:GetFocus()
    if focusIndex then
        self.m_highlightedIndex = focusIndex -- This needs to come before self:SelectItem() otherwise self.m_focus:GetFocus() always returns nil
    end

    if focusItem then
        self:SelectItem(focusItem.data)
        PlaySound(SOUNDS.DEFAULT_CLICK)
    end
end

-- Overridden function
function ZO_MultiSelection_ComboBox_Gamepad:SelectItem(item, ignoreCallback)
    self.currentItemData:ToggleItemSelected(item)
    local newSelectedState = self.currentItemData:IsItemSelected(item)
    local control = self.itemDataToControl[item]
    if self.currentItemData:IsItemSelected(item) then
        ZO_CheckButton_SetChecked(control.checkBox)
    else
        ZO_CheckButton_SetUnchecked(control.checkBox)
    end

    if item.callback and not ignoreCallback then
        item.callback(self, item.name, item, newSelectedState)
    end
    self:RefreshSelectedItemText()
end

-- Overridden function
function ZO_MultiSelection_ComboBox_Gamepad:SetupMenuItemControl(control, item)
    ZO_ComboBox_Gamepad.SetupMenuItemControl(self, control, item)
    control.checkBox = control:GetNamedChild("CheckBox")

    if self.currentItemData:IsItemSelected(item) then
        ZO_CheckButton_SetChecked(control.checkBox)
    else
        ZO_CheckButton_SetUnchecked(control.checkBox)
    end

    self.itemDataToControl[item] = control
end

-- Overridden function
function ZO_MultiSelection_ComboBox_Gamepad:ShowDropdownInternal()
    self.itemDataToControl = {}
    ZO_ComboBox_Gamepad.ShowDropdownInternal(self)
end

function ZO_MultiSelection_ComboBox_Gamepad:LoadData(data)
    self.currentItemData = data
    self:ClearItems()

    for i, item in ipairs(data.entryItems) do
        self:AddItem(item, ZO_COMBOBOX_SUPPRESS_UPDATE)
    end

    self:UpdateItems()
    self:RefreshSelectedItemText()
end

function ZO_MultiSelection_ComboBox_Gamepad:SetNoSelectionText(text)
    self.noSelectionText = text
    self:RefreshSelectedItemText()
end

function ZO_MultiSelection_ComboBox_Gamepad:SetMultiSelectionTextFormatter(textFormatter)
    self.multiSelectionTextFormatter = textFormatter
    self:RefreshSelectedItemText()
end

function ZO_MultiSelection_ComboBox_Gamepad:RefreshSelectedItemText()
    local numSelectedEntries = self:GetNumSelectedEntries()
    if numSelectedEntries > 0 then
        if self.multiSelectionTextFormatter then
            self:SetSelectedItemText(zo_strformat(self.multiSelectionTextFormatter, numSelectedEntries))
        end
    elseif self.noSelectionText then
        self:SetSelectedItemText(self.noSelectionText)
    end
end

function ZO_MultiSelection_ComboBox_Gamepad:GetNumSelectedEntries()
    if self.currentItemData then
        return self.currentItemData:GetNumSelectedItems()
    end

    return 0
end

-- ZO_MultiSelection_ComboBox_Data_Gamepad
-------------------------------------------

ZO_MultiSelection_ComboBox_Data_Gamepad = ZO_Object:Subclass()

function ZO_MultiSelection_ComboBox_Data_Gamepad:New()
    local object = ZO_Object.New(self)
    object:Initialize()
    return object
end

function ZO_MultiSelection_ComboBox_Data_Gamepad:Initialize()
    self.entryItems = {}
    self.selectedItems = {}
end

function ZO_MultiSelection_ComboBox_Data_Gamepad:Clear()
    ZO_ClearNumericallyIndexedTable(self.entryItems)
    self:ClearAllSelections()
end

function ZO_MultiSelection_ComboBox_Data_Gamepad:AddItem(item)
    table.insert(self.entryItems, item)
end

function ZO_MultiSelection_ComboBox_Data_Gamepad:GetAllItems()
    return self.entryItems
end

function ZO_MultiSelection_ComboBox_Data_Gamepad:ToggleItemSelected(item)
    local newSelectedState = not self:IsItemSelected(item)
    self:SetItemSelected(item, newSelectedState)
end

function ZO_MultiSelection_ComboBox_Data_Gamepad:SetItemSelected(item, isSelected)
    if isSelected ~= self:IsItemSelected(item) then
        if isSelected then
            self:AddItemToSelected(item)
        else
            self:RemoveItemFromSelected(item)
        end
    end
end

function ZO_MultiSelection_ComboBox_Data_Gamepad:SetItemIndexSelected(itemIndex, isSelected)
    self:SetItemSelected(self.entryItems[itemIndex], isSelected)
end

function ZO_MultiSelection_ComboBox_Data_Gamepad:GetNumSelectedItems()
    return #self.selectedItems
end

function ZO_MultiSelection_ComboBox_Data_Gamepad:GetSelectedItems()
    return self.selectedItems
end

function ZO_MultiSelection_ComboBox_Data_Gamepad:AddItemToSelected(item)
    table.insert(self.selectedItems, item)
end

function ZO_MultiSelection_ComboBox_Data_Gamepad:RemoveItemFromSelected(item)
    for i, itemData in ipairs(self.selectedItems) do
        if itemData == item then
            table.remove(self.selectedItems, i)
            return
        end
    end
end

function ZO_MultiSelection_ComboBox_Data_Gamepad:ClearAllSelections()
    ZO_ClearNumericallyIndexedTable(self.selectedItems)
end

function ZO_MultiSelection_ComboBox_Data_Gamepad:IsItemSelected(item)
    for i, itemData in ipairs(self.selectedItems) do
        if itemData == item then
            return true
        end
    end

    return false
end
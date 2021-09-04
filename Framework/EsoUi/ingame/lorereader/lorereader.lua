--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

--[[ Lore Reader ]]--
local LoreReader = ZO_Object:Subclass()

function LoreReader:New(...)
    local loreReader = ZO_Object.New(self)
    loreReader:Initialize(...)
    
    return loreReader
end

function LoreReader:Initialize(control)
    control.owner = self
    self.control = control

    self.bookContainer = control:GetNamedChild("BookContainer")
    self.mediumBg = self.bookContainer:GetNamedChild("MediumBg")

    self.firstPage = self.bookContainer:GetNamedChild("FirstPage")
    self.firstPage.scrollChild = self.firstPage:GetNamedChild("Child")
    self.title = self.firstPage.scrollChild:GetNamedChild("Title")
    self.firstPage.body = self.firstPage.scrollChild:GetNamedChild("Body")

    self.secondPage = self.bookContainer:GetNamedChild("SecondPage")
    self.secondPage.scrollChild = self.secondPage:GetNamedChild("Child")
    self.secondPage.body = self.secondPage.scrollChild:GetNamedChild("Body")

    local function OnShowBook(eventCode, title, body, medium, showTitle, bookId)
        local willShow = self:Show(title, body, medium, showTitle)
        if willShow then
            PlaySound(self.OpenSound)
        else
            EndInteraction(INTERACTION_BOOK)
        end
    end

    local function OnHideBook()
        SCENE_MANAGER:Hide("loreReaderInteraction")
    end

    local function OnAllGuiScreensResized()
        if not self.control:IsHidden() then
            self.pageGrouping = 1
            self:LayoutText()
        end
    end

    control:RegisterForEvent(EVENT_SHOW_BOOK, OnShowBook)
    control:RegisterForEvent(EVENT_HIDE_BOOK, OnHideBook)
    control:RegisterForEvent(EVENT_ALL_GUI_SCREENS_RESIZED, OnAllGuiScreensResized)

    self:InitializeKeybindStripDescriptors()

    LORE_READER_INVENTORY_SCENE = ZO_Scene:New("loreReaderInventory", SCENE_MANAGER)
    LORE_READER_LORE_LIBRARY_SCENE = ZO_Scene:New("loreReaderLoreLibrary", SCENE_MANAGER)
    LORE_READER_INTERACTION_SCENE = ZO_Scene:New("loreReaderInteraction", SCENE_MANAGER)
    GAMEPAD_LORE_READER_INVENTORY_SCENE = ZO_Scene:New("gamepad_loreReaderInventory", SCENE_MANAGER)
    GAMEPAD_LORE_READER_LORE_LIBRARY_SCENE = ZO_Scene:New("gamepad_loreReaderLoreLibrary", SCENE_MANAGER)
    GAMEPAD_LORE_READER_INTERACTION_SCENE = ZO_Scene:New("gamepad_loreReaderInteraction", SCENE_MANAGER)

    local function OnPCSceneStateChange(oldState, newState)
        if(newState == SCENE_SHOWING) then
            KEYBIND_STRIP:RemoveDefaultExit()
            KEYBIND_STRIP:AddKeybindButtonGroup(self.PCKeybindStripDescriptor)
            self.keybindStripDescriptor = self.PCKeybindStripDescriptor
        elseif(newState == SCENE_HIDDEN) then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.PCKeybindStripDescriptor)
            KEYBIND_STRIP:RestoreDefaultExit()
        end
    end

    local function OnGamepadSceneStateChange(oldState, newState)
        if(newState == SCENE_SHOWING) then
            KEYBIND_STRIP:AddKeybindButtonGroup(self.gamepadKeybindStripDescriptor)
            self.keybindStripDescriptor = self.gamepadKeybindStripDescriptor
        elseif(newState == SCENE_HIDDEN) then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.gamepadKeybindStripDescriptor)
        end
    end

    LORE_READER_INVENTORY_SCENE:RegisterCallback("StateChange", OnPCSceneStateChange)
    LORE_READER_LORE_LIBRARY_SCENE:RegisterCallback("StateChange", OnPCSceneStateChange)
    LORE_READER_INTERACTION_SCENE:RegisterCallback("StateChange", OnPCSceneStateChange)
    GAMEPAD_LORE_READER_INVENTORY_SCENE:RegisterCallback("StateChange", OnGamepadSceneStateChange)
    GAMEPAD_LORE_READER_LORE_LIBRARY_SCENE:RegisterCallback("StateChange", OnGamepadSceneStateChange)
    GAMEPAD_LORE_READER_INTERACTION_SCENE:RegisterCallback("StateChange", OnGamepadSceneStateChange)
end

function LoreReader:InitializeKeybindStripDescriptors()
    local customKeybindControl = self.control:GetNamedChild("KeyStripMouseButtons")
    customKeybindControl:SetHidden(true)
    customKeybindControl.owner = self

    self.PCKeybindStripDescriptor =
    {
        -- Turn pages
        {
            alignment = KEYBIND_STRIP_ALIGN_CENTER,
            name = GetString(SI_LORE_READER_TURN_PAGES),
            keybind = "CUSTOM_LORE_READER",
            callback = function() end,
            customKeybindControl = customKeybindControl,
            visible = function() return self.maxPageGroupings > 1 end,
        },

        -- The keyboard exit should just close this scene (so if it was pushed on the scene stack it will go back, such as going back to the lore library)
        {
            name = GetString(SI_EXIT_BUTTON),
            keybind = "UI_SHORTCUT_EXIT",
            order = -10000,
            callback = function()
                SCENE_MANAGER:HideCurrentScene()
            end,
        },
    }

    self.gamepadKeybindStripDescriptor =
    {
        -- Gamepad turn page backward
        {
            alignment = KEYBIND_STRIP_ALIGN_CENTER,
            name = GetString(SI_LORE_READER_PREVIOUS_PAGE),
            keybind = "UI_SHORTCUT_LEFT_TRIGGER",
            callback = function() 
                self:ChangePageGrouping(-1)
            end,
            enabled = function() return self.pageGrouping ~= 1 end,
            visible = function() return self.maxPageGroupings > 1 end,
        },

        -- Gamepad turn page forward
        {
            alignment = KEYBIND_STRIP_ALIGN_CENTER,
            name = GetString(SI_LORE_READER_NEXT_PAGE),
            keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
            callback = function() 
                self:ChangePageGrouping(1)
            end,
            enabled = function() return self.pageGrouping ~= self.maxPageGroupings end,
            visible = function() return self.maxPageGroupings > 1 end,
        },
    }

    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.gamepadKeybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON)
end

function LoreReader:Show(title, body, medium, showTitle)
    local isGamepad = IsInGamepadPreferredMode()
    self:SetupBook(title, body, medium, showTitle, isGamepad)
    if SCENE_MANAGER:IsShowingBaseScene() then
        if isGamepad then
            SCENE_MANAGER:Show("gamepad_loreReaderInteraction")
        else
            SCENE_MANAGER:Show("loreReaderInteraction")
        end
    else
        local currentSceneName = SCENE_MANAGER:GetCurrentScene():GetName()
        if currentSceneName == "loreLibrary" or currentSceneName == "bookSetGamepad" then
            if isGamepad then
                SCENE_MANAGER:Push("gamepad_loreReaderLoreLibrary")
            else
                SCENE_MANAGER:Push("loreReaderLoreLibrary")
            end
        elseif currentSceneName == "inventory" or currentSceneName == "gamepad_inventory_item_filter" or currentSceneName == "gamepad_inventory_root" then
            if isGamepad then
                SCENE_MANAGER:Push("gamepad_loreReaderInventory")
            else
                SCENE_MANAGER:Push("loreReaderInventory")
            end
        else
            return false
        end
    end

    return true
end

function LoreReader:SetupBook(title, body, medium, showTitle, isGamepad)
    self:ApplyMedium(medium, isGamepad)
    self.pageGrouping = 1
    self:SetText(title, body, showTitle)
end

function LoreReader:OnHide()
    EndInteraction(INTERACTION_BOOK)
    PlaySound(self.CloseSound)
end

local READER_MEDIA = {
    [BOOK_MEDIUM_NONE] = {}, -- Intentionally left blank to cause UI errors if referenced.
    [BOOK_MEDIUM_YELLOWED_PAPER] = {
        NumPages = 2,
        Bg = "EsoUI/Art/LoreLibrary/loreLibrary_paperBook.dds",

        keyboardFonts = {
                            TitleFont = "ZoFontBookPaperTitle",
                            BodyFont = "ZoFontBookPaper",
                        },
        gamepadFonts = {
                            TitleFont = "ZoFontGamepadBookPaperTitle",
                            BodyFont = "ZoFontGamepadBookPaper",
                        },

        OpenSound = SOUNDS.BOOK_OPEN,
        CloseSound = SOUNDS.BOOK_CLOSE,
        TurnPageSound = SOUNDS.BOOK_PAGE_TURN,
    },
    [BOOK_MEDIUM_ANIMAL_SKIN] = {
        NumPages = 2,
        Bg = "EsoUI/Art/LoreLibrary/loreLibrary_skinBook.dds",

        keyboardFonts = {
                            TitleFont = "ZoFontBookSkinTitle",
                            BodyFont = "ZoFontBookSkin",
                        },
        gamepadFonts = {
                            TitleFont = "ZoFontGamepadBookSkinTitle",
                            BodyFont = "ZoFontGamepadBookSkin",
                        },

        OpenSound = SOUNDS.BOOK_OPEN,
        CloseSound = SOUNDS.BOOK_CLOSE,
        TurnPageSound = SOUNDS.BOOK_PAGE_TURN,
    },
    [BOOK_MEDIUM_RUBBING_PAPER] = {
        NumPages = 2,
        Bg = "EsoUI/Art/LoreLibrary/loreLibrary_rubbingBook.dds",

        keyboardFonts = {
                            TitleFont = "ZoFontBookRubbingTitle",
                            BodyFont = "ZoFontBookRubbing",
                        },
        gamepadFonts = {
                            TitleFont = "ZoFontGamepadBookRubbingTitle",
                            BodyFont = "ZoFontGamepadBookRubbing",
                        },

        OpenSound = SOUNDS.BOOK_OPEN,
        CloseSound = SOUNDS.BOOK_CLOSE,
        TurnPageSound = SOUNDS.BOOK_PAGE_TURN,
    },
    [BOOK_MEDIUM_LETTER] = {
        NumPages = 1,

        Bg = "EsoUI/Art/LoreLibrary/loreLibrary_letter.dds",

        keyboardFonts = {
                            TitleFont = "ZoFontBookLetterTitle",
                            BodyFont = "ZoFontBookLetter",
                        },
        gamepadFonts = {
                            TitleFont = "ZoFontGamepadBookLetterTitle",
                            BodyFont = "ZoFontGamepadBookLetter",
                        },

        PageWidth = 520,
        PageHeight = 725,

        OpenSound = SOUNDS.LORE_NOTE_OPEN,
        CloseSound = SOUNDS.LORE_NOTE_CLOSE,
        TurnPageSound = SOUNDS.LORE_NOTE_PAGE_TURN,
    },
    [BOOK_MEDIUM_NOTE] = {
        NumPages = 1,

        Bg = "EsoUI/Art/LoreLibrary/loreLibrary_note.dds",

        keyboardFonts = {
                            TitleFont = "ZoFontBookNoteTitle",
                            BodyFont = "ZoFontBookNote",
                        },
        gamepadFonts = {
                            TitleFont = "ZoFontGamepadBookNoteTitle",
                            BodyFont = "ZoFontGamepadBookNote",
                        },

        PageWidth = 520,
        PageHeight = 725,

        OpenSound = SOUNDS.LORE_NOTE_OPEN,
        CloseSound = SOUNDS.LORE_NOTE_CLOSE,
        TurnPageSound = SOUNDS.LORE_NOTE_PAGE_TURN,
    },
    [BOOK_MEDIUM_SCROLL] = {
        NumPages = 1,

        Bg = "EsoUI/Art/LoreLibrary/loreLibrary_scroll.dds",

        keyboardFonts = {
                            TitleFont = "ZoFontBookScrollTitle",
                            BodyFont = "ZoFontBookScroll",
                        },
        gamepadFonts = {
                            TitleFont = "ZoFontGamepadBookScrollTitle",
                            BodyFont = "ZoFontGamepadBookScroll",
                        },

        PageWidth = 480,
        PageHeight = 650,
        FontAlpha = .65,

        OpenSound = SOUNDS.LORE_NOTE_OPEN,
        CloseSound = SOUNDS.LORE_NOTE_CLOSE,
        TurnPageSound = SOUNDS.LORE_NOTE_PAGE_TURN,
    },
    [BOOK_MEDIUM_STONE_TABLET] = {
        NumPages = 1,

        Bg = "EsoUI/Art/LoreLibrary/loreLibrary_stoneTablet.dds",

        keyboardFonts = {
                            TitleFont = "ZoFontBookTabletTitle",
                            BodyFont = "ZoFontBookTablet",
                        },
        gamepadFonts = {
                            TitleFont = "ZoFontGamepadBookTabletTitle",
                            BodyFont = "ZoFontGamepadBookTablet",
                        },

        PageHeight = 765,
        PageWidth = 780,
        FontAlpha = .65,
        FontStyleColor = ZO_ColorDef:New(1, 1, 1, .8),

        OpenSound = SOUNDS.TABLET_OPEN,
        CloseSound = SOUNDS.TABLET_CLOSE,
        TurnPageSound = SOUNDS.TABLET_PAGE_TURN,
    },
    [BOOK_MEDIUM_METAL] = {
        NumPages = 2,
        Bg = "EsoUI/Art/LoreLibrary/loreLibrary_dwemerBook.dds",

        keyboardFonts = {
                            TitleFont = "ZoFontBookMetalTitle",
                            BodyFont = "ZoFontBookMetal",
                        },
        gamepadFonts = {
                            TitleFont = "ZoFontGamepadBookMetalTitle",
                            BodyFont = "ZoFontGamepadBookMetal",
                        },

        LeftPageXOffset = 95,
        RightPageXOffset = -80,
        FontStyleColor = ZO_ColorDef:New(1, 1, 1, .4),

        OpenSound = SOUNDS.BOOK_METAL_OPEN,
        CloseSound = SOUNDS.BOOK_METAL_CLOSE,
        TurnPageSound = SOUNDS.BOOK_METAL_PAGE_TURN,
    },
    [BOOK_MEDIUM_METAL_TABLET] = {
        NumPages = 1,
        Bg = "EsoUI/Art/LoreLibrary/loreLibrary_dwemerPage.dds",

        keyboardFonts = {
                            TitleFont = "ZoFontBookMetalTitle",
                            BodyFont = "ZoFontBookMetal",
                        },
        gamepadFonts = {
                            TitleFont = "ZoFontGamepadBookMetalTitle",
                            BodyFont = "ZoFontGamepadBookMetal",
                        },

        PageWidth = 520,
        PageHeight = 725,
        FontStyleColor = ZO_ColorDef:New(1, 1, 1, .4),

        OpenSound = SOUNDS.BOOK_METAL_OPEN,
        CloseSound = SOUNDS.BOOK_METAL_CLOSE,
        TurnPageSound = SOUNDS.BOOK_METAL_PAGE_TURN,
    },
}

function LoreReader:ApplyMedium(medium, isGamepad)
    local mediumData = READER_MEDIA[medium] or READER_MEDIA[BOOK_MEDIUM_YELLOWED_PAPER]
    self.renderablePageHeight = mediumData.PageHeight or 660

    self.mediumBg:SetTexture(mediumData.Bg)

    local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_BOOK_MEDIUM, medium)
    self.title:SetColor(r, g, b, mediumData.FontAlpha or .8)
    local styleR, styleG, styleB, styleA
    if mediumData.FontStyleColor then
        styleR, styleG, styleB, styleA = mediumData.FontStyleColor:UnpackRGBA()
    else
        styleR, styleG, styleB, styleA = 0, 0, 0, 1
    end
    self.title:SetStyleColor(styleR, styleG, styleB, styleA)
    self.firstPage.body:SetColor(r, g, b, mediumData.FontAlpha or .8)
    self.firstPage.body:SetStyleColor(styleR, styleG, styleB, styleA)
    self.secondPage.body:SetColor(r, g, b, mediumData.FontAlpha or .8)
    self.secondPage.body:SetStyleColor(styleR, styleG, styleB, styleA)

    local titleFont
    local bodyFont
    if isGamepad then
        titleFont = mediumData.gamepadFonts.TitleFont
        bodyFont = mediumData.gamepadFonts.BodyFont
    else
        titleFont = mediumData.keyboardFonts.TitleFont
        bodyFont = mediumData.keyboardFonts.BodyFont
    end

    self.title:SetFont(titleFont)
    self.firstPage:SetHeight(self.renderablePageHeight)
    self.firstPage.body:SetFont(bodyFont)

    self.secondPage:SetHeight(self.renderablePageHeight)
    self.secondPage.body:SetFont(bodyFont)

    self.firstPage:ClearAnchors()
    self.secondPage:ClearAnchors()

    local pageWidth = mediumData.PageWidth or 375
    local pageYOffset = mediumData.PageYOffset or -20
    self.title:SetWidth(pageWidth)
    self.numPagesPerGrouping = mediumData.NumPages
    if self.numPagesPerGrouping > 1 then
        local leftPageXOffset = mediumData.LeftPageXOffset or 100
        local rightPageXOffset = mediumData.RightPageXOffset or -95

        self.firstPage:SetAnchor(LEFT, nil, LEFT, leftPageXOffset, pageYOffset)
        self.secondPage:SetAnchor(RIGHT, nil, RIGHT, rightPageXOffset, pageYOffset)
    else
        local pageXOffset = mediumData.LeftPageXOffset or 0
        self.firstPage:SetAnchor(CENTER, nil, CENTER, pageXOffset, pageYOffset)
    end
    
    self.firstPage:SetWidth(pageWidth)
    self.firstPage.body:SetWidth(pageWidth)
    self.secondPage:SetWidth(pageWidth)
    self.secondPage.body:SetWidth(pageWidth)

    self.CloseSound = mediumData.CloseSound
    self.OpenSound = mediumData.OpenSound
    self.TurnPageSound = mediumData.TurnPageSound
end

local function CalculatePageHeight(fontHeight, maxHeight)
    return zo_floor(maxHeight / fontHeight) * fontHeight
end

function LoreReader:LayoutText()
    local bodyFontHeight = self.firstPage.body:GetFontHeight()
    --Calculate the number of full lines that can fit in the page then save the height of that many lines as pageHeight.
    self.pageHeight = CalculatePageHeight(bodyFontHeight, self.renderablePageHeight)

    self.firstPage:SetHeight(self.pageHeight)
    self.firstPage.body:ClearAnchors()

    local titleHeight = 0
    local yOffsetNeededToAlignLines = 0

    if self.showTitle then
        self.title:SetHidden(false)
        self.title:SetText(self.titleText)

        titleHeight = self.title:GetTextHeight()
        yOffsetNeededToAlignLines = bodyFontHeight - (titleHeight % bodyFontHeight)

        self.firstPage.body:SetAnchor(TOP, self.title, BOTTOM, 0, yOffsetNeededToAlignLines)
    else
        self.title:SetHidden(true)
        self.firstPage.body:SetAnchor(TOP, self.title, TOP, 0, 0)
    end
    
    self.firstPage.body:SetText(self.bodyText)

    if self.numPagesPerGrouping > 1 then
        self.secondPage:SetHidden(false)
        self.secondPage:SetHeight(self.pageHeight)
        self.secondPage.body:SetText(self.bodyText)
        self.secondPageAdditionalOffset = self.pageHeight - (titleHeight + yOffsetNeededToAlignLines)
        self.secondPage:SetVerticalScroll(self.secondPageAdditionalOffset)
    else
        self.secondPage:SetHidden(true)
    end

    self.firstPage:SetVerticalScroll(0)
    
    --The title height + the spacing between the title and body + the body height
    local entireHeight = titleHeight + yOffsetNeededToAlignLines + self.firstPage.body:GetTextHeight()

    --There are cases where the entire height is just barely larger than what can fit in one page (or two pages, or any integer number of pages). This leads to us
    --allocating a whole new page to show the bottom of the last line which often doesn't even have anything visible going on. The slop value is used to modify the
    --calculation so that if the amount that overflows the page is less than 10% of one line in height we don't bother making a new page. This pretty much only happens
    --due to minor floating point differences, but we might as well handle as much as we can.
    local slop = (bodyFontHeight * 0.1) / self.pageHeight
    local numPages = zo_ceil((entireHeight / self.pageHeight) - slop)
    self.maxPageGroupings = zo_ceil(numPages / self.numPagesPerGrouping)

    self:UpdatePagingButtons()
end

function LoreReader:SetText(title, body, showTitle)
    self.titleText = title
    self.bodyText = body
    self.showTitle = showTitle

    self:LayoutText()
end

function LoreReader:ChangePageGrouping(offset)
    local newPage = zo_clamp(self.pageGrouping + offset, 1, self.maxPageGroupings)
    if self.pageGrouping ~= newPage then
        self.pageGrouping = newPage
        local scrollOffset = (self.pageGrouping - 1) * self.pageHeight * self.numPagesPerGrouping
        self.firstPage:SetVerticalScroll(scrollOffset)
        if self.numPagesPerGrouping > 1 then
            self.secondPage:SetVerticalScroll(scrollOffset + self.secondPageAdditionalOffset)
        end

        self:UpdatePagingButtons()
        PlaySound(self.TurnPageSound)
    end
end

function LoreReader:UpdatePagingButtons()
    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
end

--[[ XML Handlers ]]--
function ZO_LoreReader_OnInitialize(control)
    LORE_READER = LoreReader:New(control)
end

function ZO_LoreReader_OnHide(control)
    control.owner:OnHide()
end

function ZO_LoreReader_OnClicked(control, button)
    if button == MOUSE_BUTTON_INDEX_LEFT then
        control.owner:ChangePageGrouping(-1)
    elseif button == MOUSE_BUTTON_INDEX_RIGHT then
        control.owner:ChangePageGrouping(1)
    end
end

function ZO_LoreReader_OnPagePreviousClicked(control)
    control.owner:ChangePageGrouping(-1)
end

function ZO_LoreReader_OnPageNextClicked(control)
    control.owner:ChangePageGrouping(1)
end
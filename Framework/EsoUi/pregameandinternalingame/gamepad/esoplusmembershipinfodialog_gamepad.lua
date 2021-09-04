--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:29' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_EsoPlusMembershipInfoDialog_Gamepad = ZO_Object:Subclass()

function ZO_EsoPlusMembershipInfoDialog_Gamepad:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function ZO_EsoPlusMembershipInfoDialog_Gamepad:Initialize(control)
    self.control = control

    self:InitializeDialog(control)

    local keybindLabelText = string.format("%s %s", ZO_Keybindings_GenerateIconKeyMarkup(KEY_GAMEPAD_BUTTON_2), zo_strformat(SI_GAMEPAD_BACK_OPTION))
    self.control:GetNamedChild("BackKeybind"):SetText(keybindLabelText)
    self:BuildDialogInfo()

    ZO_Dialogs_RegisterCustomDialog("ESO_PLUS_MEMBERSHIP_INFO", self.dialogInfo)
end

function ZO_EsoPlusMembershipInfoDialog_Gamepad:InitializeDialog(dialog)
    dialog.fragment = ZO_FadeSceneFragment:New(dialog)
    ZO_GenericGamepadDialog_OnInitialized(dialog)

    self.benefitLinePool = ZO_ControlPool:New("ZO_GamepadMembershipInfoDialog_BenefitLine", dialog.scrollChild)

    local function SetupBenefitLine(benefitLine)
        benefitLine.iconTexture = benefitLine:GetNamedChild("Icon")
        benefitLine.headerLabel = benefitLine:GetNamedChild("HeaderText")
        benefitLine.lineLabel = benefitLine:GetNamedChild("LineText")
    end
    self.benefitLinePool:SetCustomFactoryBehavior(SetupBenefitLine)
end

function ZO_EsoPlusMembershipInfoDialog_Gamepad:BuildDialogInfo()
    self.dialogInfo =
    {
        setup = function(...) self:DialogSetupFunction(...) end,
        customControl = self.control,
        gamepadInfo = 
        {
            dialogType = GAMEPAD_DIALOGS.CUSTOM,
        },
        title =
        {
            text = SI_MARKET_SUBSCRIPTION_PAGE_BENEFITS_TITLE,
        },
        mainText =
        {
            text = "", -- no main text
        },
        buttons =
        {
            {
                --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
                name = "Gamepad Membership Dialog Back",
                ethereal = true,
                keybind = "DIALOG_NEGATIVE",
                clickSound = SOUNDS.DIALOG_DECLINE,
                callback = function(dialog)
                    self:Hide()
                end,
            },
        }
    }
end

function ZO_EsoPlusMembershipInfoDialog_Gamepad:DialogSetupFunction(dialog)
    dialog.headerData.titleTextAlignment = TEXT_ALIGN_CENTER
    ZO_GamepadGenericHeader_Refresh(dialog.header, dialog.headerData)

    self.benefitLinePool:ReleaseAllObjects()

    local numLines = GetNumGamepadMarketSubscriptionBenefitLines()
    local controlToAnchorTo = dialog.scrollChild
    for i = 1, numLines do
        local lineText, headerText, icon = GetGamepadMarketSubscriptionBenefitLineInfo(i);
        local benefitLine = self.benefitLinePool:AcquireObject()
        benefitLine.lineLabel:SetText(lineText)
        benefitLine.headerLabel:SetText(headerText)
        benefitLine.iconTexture:SetTexture(icon)
        benefitLine:ClearAnchors()
        if i == 1 then
            benefitLine:SetAnchor(TOPLEFT, controlToAnchorTo, TOPLEFT, 0, 0)
        else
            benefitLine:SetAnchor(TOPLEFT, controlToAnchorTo, BOTTOMLEFT, 0, 25)
        end
        controlToAnchorTo = benefitLine
    end
end

function ZO_EsoPlusMembershipInfoDialog_Gamepad:Show()
    ZO_Dialogs_ShowGamepadDialog("ESO_PLUS_MEMBERSHIP_INFO")
end

function ZO_EsoPlusMembershipInfoDialog_Gamepad:Hide()
    ZO_Dialogs_ReleaseDialog("ESO_PLUS_MEMBERSHIP_INFO")
end

--
--[[ XML Handlers ]]--
--

function ZO_EsoPlusMembershipInfoDialog_Gamepad_OnInitialized(control)
    ZO_ESO_PLUS_MEMBERSHIP_DIALOG = ZO_EsoPlusMembershipInfoDialog_Gamepad:New(control)
end
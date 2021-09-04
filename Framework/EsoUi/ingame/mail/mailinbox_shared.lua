--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:27' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

MAIL_ENTRY_SORT_KEYS =
{
    ["secsSinceReceived"]  = { numeric = true, tiebreaker = "mailId" },
    ["priority"] = { numeric = true, tiebreaker = "secsSinceReceived" },
    ["mailId"] = { isId64 = true },
}
MAIL_ENTRY_FIRST_SORT_KEY = "priority"

local function FormatSubject(subject, returned)
    local formattedSubject
    if(subject == "") then
        formattedSubject = GetString(SI_MAIL_READ_NO_SUBJECT)
    else
        formattedSubject = subject
    end

    if(returned) then
        formattedSubject = zo_strformat(SI_MAIL_READ_RETURNED_SUBJECT, formattedSubject)
    end

    return formattedSubject
end


local function GetFormattedSubject(self)
    if not self.formattedSubject then
        self.formattedSubject = FormatSubject(self.subject, self.returned)
    end
    return self.formattedSubject
end

local function GetFormattedReplySubject(self)
    local formattedSubject = GetFormattedSubject(self)
    local tag = GetString(SI_MAIL_READ_REPLY_TAG_NO_LOC)
    local tagLength = #tag
    if string.sub(formattedSubject, 1, tagLength) ~= tag then
        return string.format("%s %s", GetString(SI_MAIL_READ_REPLY_TAG_NO_LOC), formattedSubject)
    end
    return formattedSubject
end

local function GetExpiresText(self)
    if not self.expiresText then
        if not self.expiresInDays then
            self.expiresText = GetString(SI_MAIL_READ_NO_EXPIRATION)
        elseif self.expiresInDays > 0  then
            self.expiresText = zo_strformat(SI_MAIL_READ_EXPIRES_LABEL, self.expiresInDays)
        else
            self.expiresText = GetString(SI_MAIL_READ_EXPIRES_LESS_THAN_ONE_DAY)
        end
    end
    return self.expiresText
end

local function GetReceivedText(self)
    if not self.receivedText then
        self.receivedText = ZO_FormatDurationAgo(self.secsSinceReceived)
    end
    return self.receivedText
end

local function IsExpirationImminent(self)
    return self.expiresInDays and self.expiresInDays <= 3
end

function ZO_MailInboxShared_PopulateMailData(dataTable, mailId)
    local senderDisplayName, senderCharacterName, subject, icon, unread, fromSystem, fromCS, returned, numAttachments, attachedMoney, codAmount, expiresInDays, secsSinceReceived = GetMailItemInfo(mailId)
    dataTable.mailId = mailId
    dataTable.subject = subject
    dataTable.returned = returned
    dataTable.senderDisplayName = senderDisplayName
    dataTable.senderCharacterName = senderCharacterName
    dataTable.expiresInDays = expiresInDays
    dataTable.unread = unread
    dataTable.numAttachments = numAttachments
    dataTable.attachedMoney = attachedMoney
    dataTable.codAmount = codAmount
    dataTable.secsSinceReceived = secsSinceReceived
    dataTable.fromSystem = fromSystem
    dataTable.fromCS = fromCS
    dataTable.isFromPlayer = not (fromSystem or fromCS)
    dataTable.priority = fromCS and 1 or 2
    dataTable.GetFormattedSubject = GetFormattedSubject
    dataTable.GetFormattedReplySubject = GetFormattedReplySubject
    dataTable.GetExpiresText = GetExpiresText
    dataTable.GetReceivedText = GetReceivedText
    dataTable.isReadInfoReady = IsReadMailInfoReady(mailId)
    dataTable.IsExpirationImminent = IsExpirationImminent
end

function ZO_GetNextMailIdIter(state, var1)
    return GetNextMailId(var1)
end

function ZO_MailInboxShared_TakeAll(mailId)
	local numAttachments = GetMailAttachmentInfo(mailId)
	if numAttachments then
		TakeMailAttachedItems(mailId)
	end
    TakeMailAttachedMoney(mailId)
end

function ZO_MailInboxShared_UpdateInbox(mailData, fromControl, subjectControl, expiresControl, receivedControl, bodyControl)
    local body = ReadMail(mailData.mailId)
    if body == "" then
        body = GetString(SI_MAIL_READ_NO_BODY)
    end

    -- Header and Body.
    fromControl:SetText(mailData.senderDisplayName)
    if(mailData.fromCS or mailData.fromSystem) then
        fromControl:SetColor(ZO_GAME_REPRESENTATIVE_TEXT:UnpackRGBA())
    else
        fromControl:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
    end

    subjectControl:SetText(mailData:GetFormattedSubject())

    if expiresControl then
        local expiresText = mailData:GetExpiresText()
        if mailData:IsExpirationImminent() then
            expiresText = ZO_ERROR_COLOR:Colorize(expiresText)
        end
        expiresControl:SetText(expiresText)
    end

    if receivedControl then
        receivedControl:SetText(mailData:GetReceivedText())
    end

    bodyControl:SetText(body)
end

--Mail Interaction
------------------------

local ZO_MailInteractionFragment = ZO_SceneFragment:Subclass()

function ZO_MailInteractionFragment:New()
    return ZO_SceneFragment.New(self)
end

function ZO_MailInteractionFragment:Show()                            
    RequestOpenMailbox()
    self:OnShown()
end

function ZO_MailInteractionFragment:Hide()
    CloseMailbox()
    self:OnHidden()
end

MAIL_INTERACTION_FRAGMENT = ZO_MailInteractionFragment:New()
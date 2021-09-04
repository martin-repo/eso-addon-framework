--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local HelpOverview_Keyboard = ZO_HelpScreenTemplate_Keyboard:Subclass()

function HelpOverview_Keyboard:New(...)
    return ZO_HelpScreenTemplate_Keyboard.New(self, ...)
end

function HelpOverview_Keyboard:Initialize(control)
	HELP_CUSTOMER_SERVICE_OVERVIEW_KEYBOARD_FRAGMENT = ZO_FadeSceneFragment:New(control)

	local iconData =
	{
		name = GetString(SI_CUSTOMER_SERVICE_OVERVIEW),
		categoryFragment = HELP_CUSTOMER_SERVICE_OVERVIEW_KEYBOARD_FRAGMENT,
        up = "EsoUI/Art/Help/help_tabIcon_overview_up.dds",
        down = "EsoUI/Art/Help/help_tabIcon_overview_down.dds",
        over = "EsoUI/Art/Help/help_tabIcon_overview_over.dds",
	}
	ZO_HelpScreenTemplate_Keyboard.Initialize(self, control, iconData)

	self.helpIntroDetailsBody = control:GetNamedChild("DetailsContainerScrollChildIntroDetailsBody")
	self.helpIntroDetailsBody:SetText(GetHelpOverviewIntroParagraph())

	self.helpQuestionAnswerContainer = control:GetNamedChild("DetailsContainerScrollChildQuestionAnswerContainer")

	self:InitializeQuestionsAndAnswers()
end

function HelpOverview_Keyboard:InitializeQuestionsAndAnswers()
	local numQAs = GetNumHelpOverviewQuestionAnswers()
	local lastAnswer

	for i = 1, numQAs do
		local question = CreateControlFromVirtual(self.helpQuestionAnswerContainer:GetName() .. "Question" .. i, self.helpQuestionAnswerContainer, "ZO_HelpOverview_Keyboard_Question")
		local answer = CreateControlFromVirtual(self.helpQuestionAnswerContainer:GetName() .. "Answer" .. i, self.helpQuestionAnswerContainer, "ZO_HelpOverview_Keyboard_Answer")

		if i == 1 then
			question:SetAnchor(TOPLEFT)
		else
			question:SetAnchor(TOPLEFT, lastAnswer, BOTTOMLEFT, 0, 40)
		end

		answer:SetAnchor(TOPLEFT, question, BOTTOMLEFT, 0, 10)

		local questionText, answerText = GetHelpOverviewQuestionAnswerPair(i)
		question:SetText(questionText)
		answer:SetText(answerText)

		lastAnswer = answer
	end
end

--Global XML

function ZO_HelpOverview_Keyboard_OnInitialized(self)
    HELP_CUSTOMER_SERVICE_OVERVIEW_KEYBOARD = HelpOverview_Keyboard:New(self)
end
--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

----------------------
-- ZO_AbstractSingleTemplateGridScrollList
----------------------

ZO_AbstractSingleTemplateGridScrollList = ZO_AbstractGridScrollList:Subclass()

function ZO_AbstractSingleTemplateGridScrollList:SetHeaderTemplate(templateName, height, setupFunc, onHideFunc, resetControlFunc)
    self.headerOperationId = self:AddHeaderTemplate(templateName, height, setupFunc, onHideFunc, resetControlFunc)
    self.headerTemplateName = templateName
end

function ZO_AbstractSingleTemplateGridScrollList:SetGridEntryTemplate(templateName, width, height, setupFunc, onHideFunc, resetControlFunc, spacingX, spacingY, centerEntries)
    self.entryOperationId = self:AddEntryTemplate(templateName, width, height, setupFunc, onHideFunc, resetControlFunc, spacingX, spacingY, centerEntries)
    self.entryTemplateName = templateName
    self:SetAutoFillEntryTemplate(templateName)
end

-- Note: Order matters. When using this function, it must be called after SetGridEntryTemplate
function ZO_AbstractSingleTemplateGridScrollList:SetGridEntryVisibilityFunction(visiblityFunction)
    ZO_ScrollList_SetVisibilityFunction(self.list, self.entryOperationId, visiblityFunction)
end

function ZO_AbstractSingleTemplateGridScrollList:AddEntry(data)
    if not data.gridHeaderTemplate then
        data.gridHeaderTemplate = self.headerTemplateName
    end
    ZO_AbstractGridScrollList.AddEntry(self, data, self.entryTemplateName)
end

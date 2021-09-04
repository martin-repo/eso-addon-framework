--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_HousingFurnitureProducts_Gamepad = ZO_HousingFurnitureList_Gamepad:Subclass()

function ZO_HousingFurnitureProducts_Gamepad:New(...)
    return ZO_HousingFurnitureList_Gamepad.New(self, ...)
end

function ZO_HousingFurnitureProducts_Gamepad:Initialize(owner)
    ZO_HousingFurnitureList_Gamepad.Initialize(self, owner)

    SHARED_FURNITURE:RegisterCallback("MarketProductsChanged", function(fromSearch)
        if fromSearch then
            self:ResetSavedPositions()
        end
    end)
end

function ZO_HousingFurnitureProducts_Gamepad:InitializeKeybindStripDescriptors()
    ZO_HousingFurnitureList_Gamepad.InitializeKeybindStripDescriptors(self)

    -- purchase
    self:AddFurnitureListKeybind(
        {
            name = GetString(SI_HOUSING_FURNITURE_BROWSER_PURCHASE_KEYBIND),
            keybind = "UI_SHORTCUT_PRIMARY",
            callback = function()
                local targetData = self.furnitureList.list:GetTargetData()
                if targetData then
                    local furnitureObject = targetData.furnitureObject
                    local IS_PURCHASE = false
                    RequestPurchaseMarketProduct(furnitureObject.marketProductId, furnitureObject.presentationIndex, IS_PURCHASE)
                end
            end,
            enabled = function()
                local targetData = self.furnitureList.list:GetTargetData()
                if targetData == nil then
                    return false
                else
                    local furnitureObject = targetData.furnitureObject
                    if not furnitureObject:CanBePurchased() then
                        local expectedPurchaseResult = CouldPurchaseMarketProduct(furnitureObject.marketProductId, furnitureObject.presentationIndex)
                        return false, GetString("SI_MARKETPURCHASABLERESULT", expectedPurchaseResult)
                    end
                end

                return true
            end,
        }
    )

    -- gift
    self:AddFurnitureListKeybind(
        {
            name = GetString(SI_HOUSING_FURNITURE_BROWSER_GIFT_KEYBIND),
            keybind = "UI_SHORTCUT_RIGHT_STICK",
            visible =  function()
                            local targetData = self.furnitureList.list:GetTargetData()
                            if targetData then
                                local furnitureObject = targetData.furnitureObject
                                return IsMarketProductGiftable(furnitureObject.marketProductId, furnitureObject.presentationIndex)
                            end
                            return false
                        end,
            callback =  function()
                            local targetData = self.furnitureList.list:GetTargetData()
                            if targetData then
                                local furnitureObject = targetData.furnitureObject
                                local IS_GIFT = true
                                RequestPurchaseMarketProduct(furnitureObject.marketProductId, furnitureObject.presentationIndex, IS_GIFT)
                            end
                        end,
        }
    )

    local buyCrownsKeybind = MARKET_CURRENCY_GAMEPAD:GetBuyCrownsKeybind("UI_SHORTCUT_SECONDARY")

    self:AddFurnitureListKeybind(buyCrownsKeybind)

    table.insert(self.categoryKeybindStripDescriptor, buyCrownsKeybind)
end

function ZO_HousingFurnitureProducts_Gamepad:GetCategoryTreeDataRoot()
    return SHARED_FURNITURE:GetMarketProductCategoryTreeData()
end

function ZO_HousingFurnitureProducts_Gamepad:OnFurnitureTargetChanged(list, targetData, oldTargetData)
    ZO_HousingFurnitureList_Gamepad.OnFurnitureTargetChanged(self, list, targetData, oldTargetData)

    ZO_HousingFurnitureBrowser_Base.PreviewFurniture(targetData.furnitureObject)
    self:UpdateCurrentKeybinds()
end

function ZO_HousingFurnitureProducts_Gamepad:GetNoItemText()
    if SHARED_FURNITURE:AreThereMarketProducts() then
        return GetString(SI_HOUSING_FURNITURE_NO_SEARCH_RESULTS)
    else
        return GetString(SI_HOUSING_FURNITURE_NO_MARKET_PRODUCTS)
    end
end

function ZO_HousingFurnitureProducts_Gamepad:OnShowing()
    ZO_HousingFurnitureList_Gamepad.OnShowing(self)

    UpdateMarketDisplayGroup(MARKET_DISPLAY_GROUP_HOUSE_EDITOR)
    MARKET_CURRENCY_GAMEPAD:SetVisibleMarketCurrencyTypes({MKCT_CROWNS, MKCT_CROWN_GEMS})
    MARKET_CURRENCY_GAMEPAD:Show()
    local currencyStyle = MARKET_CURRENCY_GAMEPAD:ModifyKeybindStripStyleForCurrency(KEYBIND_STRIP_GAMEPAD_STYLE)
    KEYBIND_STRIP:SetStyle(currencyStyle)
end

function ZO_HousingFurnitureProducts_Gamepad:OnHiding()
    ZO_HousingFurnitureList_Gamepad.OnHiding(self)
    MARKET_CURRENCY_GAMEPAD:Hide()
    KEYBIND_STRIP:SetStyle(KEYBIND_STRIP_GAMEPAD_STYLE)
end
--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

function ZO_ConfirmSendGift_Shared_ShouldRestartGiftFlow(giftResult)
    return giftResult == GIFT_ACTION_RESULT_CANNOT_GIFT_TO_PLAYER or giftResult == GIFT_ACTION_RESULT_RECIPIENT_NOT_FOUND
end

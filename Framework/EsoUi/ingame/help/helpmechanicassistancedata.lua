--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_QUEST_ASSISTANCE_CATEGORIES_DATA =
{
    categoryEnumStringPrefix = "SI_CUSTOMERSERVICEQUESTASSISTANCECATEGORIES",
    categoryEnumOrderedValues = 
    {
        CUSTOMER_SERVICE_QUEST_ASSISTANCE_CATEGORY_NONE,
        CUSTOMER_SERVICE_QUEST_ASSISTANCE_CATEGORY_NPC_MOBS,
        CUSTOMER_SERVICE_QUEST_ASSISTANCE_CATEGORY_ITEM_MISSING,
    },
    invalidCategory = CUSTOMER_SERVICE_QUEST_ASSISTANCE_CATEGORY_NONE,
    ticketCategoryMap =
    {
        [CUSTOMER_SERVICE_QUEST_ASSISTANCE_CATEGORY_NPC_MOBS] =
        {
            ticketCategory = TICKET_CATEGORY_QUEST_NPC_MOBS,
        },
        [CUSTOMER_SERVICE_QUEST_ASSISTANCE_CATEGORY_ITEM_MISSING] =
        {
            ticketCategory = TICKET_CATEGORY_QUEST_ITEM_MISSING,
        },
    }
}

ZO_ITEM_ASSISTANCE_CATEGORIES_DATA =
{
    categoryEnumStringPrefix = "SI_CUSTOMERSERVICEITEMASSISTANCECATEGORIES",
    categoryEnumOrderedValues =
    {
        CUSTOMER_SERVICE_ITEM_ASSISTANCE_CATEGORY_NONE,
        CUSTOMER_SERVICE_ITEM_ASSISTANCE_CATEGORY_MISSING_CROWNS,
        CUSTOMER_SERVICE_ITEM_ASSISTANCE_CATEGORY_FROM_CROWN_STORE,
        CUSTOMER_SERVICE_ITEM_ASSISTANCE_CATEGORY_LOST,
        CUSTOMER_SERVICE_ITEM_ASSISTANCE_CATEGORY_CANT_ACQUIRE,
    },
    invalidCategory = CUSTOMER_SERVICE_ITEM_ASSISTANCE_CATEGORY_NONE,
    ticketCategoryMap =
    {
        [CUSTOMER_SERVICE_ITEM_ASSISTANCE_CATEGORY_MISSING_CROWNS] =
        {
            ticketCategory = TICKET_CATEGORY_ITEM_MISSING_CROWNS,
        },
        [CUSTOMER_SERVICE_ITEM_ASSISTANCE_CATEGORY_FROM_CROWN_STORE] =
        {
            ticketCategory = TICKET_CATEGORY_ITEM_FROM_CROWN_STORE,
        },
        [CUSTOMER_SERVICE_ITEM_ASSISTANCE_CATEGORY_LOST] =
        {
            ticketCategory = TICKET_CATEGORY_ITEM_LOST,
        },
        [CUSTOMER_SERVICE_ITEM_ASSISTANCE_CATEGORY_CANT_ACQUIRE] =
        {
            ticketCategory = TICKET_CATEGORY_ITEM_CANT_ACQUIRE,
        },
    }
}
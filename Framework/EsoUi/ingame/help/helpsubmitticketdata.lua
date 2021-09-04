--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:26' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_HELP_TICKET_FIELD_TYPE =
{
    IMPACT =  1,
    CATEGORY = 2,
    SUBCATEGORY = 3,
    DETAILS = 4,
    DESCRIPTION = 5,
    ATTACH_SCREENSHOT = 6,
    SUBMIT = 7,
}

ZO_HELP_SUBMIT_FEEDBACK_FIELD_DATA =
{
    [ZO_HELP_TICKET_FIELD_TYPE.IMPACT] =
    {
        enumStringPrefix = "SI_CUSTOMERSERVICESUBMITFEEDBACKIMPACTS",
        iterationBegin = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_IMPACT_ITERATION_BEGIN,
        iterationEnd = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_IMPACT_ITERATION_END,
        invalidEntry = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_IMPACT_NONE,
    },
    [ZO_HELP_TICKET_FIELD_TYPE.CATEGORY] =
    {
        enumStringPrefix = "SI_CUSTOMERSERVICESUBMITFEEDBACKCATEGORIES",
        universallyAddEnum = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_NONE,
        iterationBegin = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_CATEGORY_ITERATION_BEGIN + 1,
        iterationEnd = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_CATEGORY_ITERATION_END,
        sortFunction = function(left, right)
            return left.name < right.name
        end,
        invalidEntry = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_CATEGORY_NONE,
    },
    [ZO_HELP_TICKET_FIELD_TYPE.SUBCATEGORY] =
    {
        enumStringPrefix = "SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES",
        universallyAddEnum = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_NONE,
        otherEnum = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_OTHER,
        categoryContextualData = 
        {
            [CUSTOMER_SERVICE_SUBMIT_FEEDBACK_CATEGORY_ALLIANCE_WAR] =
            {
                iterationBegin = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_ALLIANCE_WAR_1,
                iterationEnd = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_ALLIANCE_WAR_END - 1,
            },
            [CUSTOMER_SERVICE_SUBMIT_FEEDBACK_CATEGORY_AUDIO] =
            {
                iterationBegin = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_AUDIO_1,
                iterationEnd = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_AUDIO_END - 1,
            },
            [CUSTOMER_SERVICE_SUBMIT_FEEDBACK_CATEGORY_CRAFTING] =
            {
                iterationBegin = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_CRAFTING_1,
                iterationEnd = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_CRAFTING_END - 1,
            },
            [CUSTOMER_SERVICE_SUBMIT_FEEDBACK_CATEGORY_COMBAT] =
            {
                iterationBegin = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_COMBAT_1,
                iterationEnd = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_COMBAT_END - 1,
            },
            [CUSTOMER_SERVICE_SUBMIT_FEEDBACK_CATEGORY_ITEMS] =
            {
                iterationBegin = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_ITEMS_1,
                iterationEnd = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_ITEMS_END - 1,
                detailsTitle = GetString(SI_CUSTOMER_SERVICE_ITEM_NAME),
            },
            [CUSTOMER_SERVICE_SUBMIT_FEEDBACK_CATEGORY_CROWN_STORE] =
            {
                iterationBegin = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_CROWN_STORE_1,
                iterationEnd = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_CROWN_STORE_END - 1,
            },
            [CUSTOMER_SERVICE_SUBMIT_FEEDBACK_CATEGORY_GRAPHICS] =
            {
                iterationBegin = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_GRAPHICS_1,
                iterationEnd = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_GRAPHICS_END - 1,
            },
            [CUSTOMER_SERVICE_SUBMIT_FEEDBACK_CATEGORY_QUESTS] =
            {
                iterationBegin = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_QUESTS_1,
                iterationEnd = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_QUESTS_END - 1,
                detailsTitle = GetString(SI_CUSTOMER_SERVICE_QUEST_NAME),
            },
            [CUSTOMER_SERVICE_SUBMIT_FEEDBACK_CATEGORY_TEXT] =
            {
                iterationBegin = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_TEXT_1,
                iterationEnd = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_TEXT_END - 1,
            },
            [CUSTOMER_SERVICE_SUBMIT_FEEDBACK_CATEGORY_DUNGEONS] =
            {
                iterationBegin = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_DUNGEONS_1,
                iterationEnd = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_DUNGEONS_END - 1,
            },
            [CUSTOMER_SERVICE_SUBMIT_FEEDBACK_CATEGORY_HOUSING] =
            {
                iterationBegin = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_HOUSING_1,
                iterationEnd = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_HOUSING_END - 1,
            },
            [CUSTOMER_SERVICE_SUBMIT_FEEDBACK_CATEGORY_JUSTICE] =
            {
                iterationBegin = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_JUSTICE_1,
                iterationEnd = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_JUSTICE_END - 1,
            },
            [CUSTOMER_SERVICE_SUBMIT_FEEDBACK_CATEGORY_PERFORMANCE] =
            {
                iterationBegin = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_PERFORMANCE_1,
                iterationEnd = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_PERFORMANCE_END - 1,
            },
            [CUSTOMER_SERVICE_SUBMIT_FEEDBACK_CATEGORY_UI] =
            {
                iterationBegin = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_UI_1,
                iterationEnd = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_UI_END - 1,
            },
        },
        invalidEntry = CUSTOMER_SERVICE_SUBMIT_FEEDBACK_SUBCATEGORY_NONE,
    },
}
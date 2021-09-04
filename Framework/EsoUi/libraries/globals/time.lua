--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

ZO_ONE_MINUTE_IN_SECONDS = 60
ZO_ONE_HOUR_IN_MINUTES = 60
ZO_ONE_DAY_IN_HOURS = 24
ZO_ONE_MONTH_IN_DAYS = 30
ZO_ONE_HOUR_IN_SECONDS = ZO_ONE_HOUR_IN_MINUTES * ZO_ONE_MINUTE_IN_SECONDS -- = 3600
ZO_ONE_DAY_IN_SECONDS = ZO_ONE_DAY_IN_HOURS * ZO_ONE_HOUR_IN_SECONDS -- = 86400
ZO_ONE_MONTH_IN_SECONDS = ZO_ONE_MONTH_IN_DAYS * ZO_ONE_DAY_IN_SECONDS -- = 2592000
ZO_ONE_DAY_IN_MINUTES = ZO_ONE_DAY_IN_HOURS * ZO_ONE_HOUR_IN_MINUTES -- = 1440

ZO_ONE_SECOND_IN_MILLISECONDS = 1000
ZO_ONE_MINUTE_IN_MILLISECONDS = ZO_ONE_MINUTE_IN_SECONDS * ZO_ONE_SECOND_IN_MILLISECONDS -- = 60000
ZO_ONE_HOUR_IN_MILLISECONDS = ZO_ONE_HOUR_IN_MINUTES * ZO_ONE_MINUTE_IN_MILLISECONDS -- = 3600000
ZO_ONE_DAY_IN_MILLISECONDS = ZO_ONE_DAY_IN_HOURS * ZO_ONE_HOUR_IN_MILLISECONDS -- = 86400000

function ZO_FormatTime(seconds, formatStyle, precision, direction)
   return FormatTimeSeconds(seconds, formatStyle, precision, direction or TIME_FORMAT_DIRECTION_NONE)
end

function ZO_FormatTimeMilliseconds(milliseconds, formatType, precisionType, direction)
    return FormatTimeMilliseconds(milliseconds, formatType, precisionType, direction or TIME_FORMAT_DIRECTION_NONE)
end

function ZO_FormatCountdownTimer(seconds)
    if(seconds > 3 * ZO_ONE_MINUTE_IN_SECONDS) then
        return ZO_FormatTime(seconds, TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
    else
        return ZO_FormatTime(seconds, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
    end
end

function ZO_FormatTimeLargestTwo(seconds, format)
    if(seconds > ZO_ONE_DAY_IN_SECONDS) then
        seconds = zo_round(seconds / ZO_ONE_HOUR_IN_SECONDS) * ZO_ONE_HOUR_IN_SECONDS
    elseif(seconds > ZO_ONE_HOUR_IN_SECONDS) then
        seconds = zo_round(seconds / ZO_ONE_MINUTE_IN_SECONDS) * ZO_ONE_MINUTE_IN_SECONDS
    end
    return ZO_FormatTime(seconds, format, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
end

function ZO_FormatDurationAgo(seconds)
    if(seconds < ZO_ONE_MINUTE_IN_SECONDS) then
        return GetString(SI_TIME_DURATION_NOT_LONG_AGO), ZO_ONE_MINUTE_IN_SECONDS - seconds
    else
        local timeText, nextUpdateTimeInSec = ZO_FormatTime(seconds, TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_ASCENDING)
        return zo_strformat(SI_TIME_DURATION_AGO, timeText), nextUpdateTimeInSec
    end
end

function ZO_FormatRelativeTimeStamp(timestamp, precisionType)
    return ZO_FormatTimeMilliseconds(timestamp, TIME_FORMAT_STYLE_RELATIVE_TIMESTAMP, precisionType or TIME_FORMAT_PRECISION_TENTHS)
end

function ZO_FormatTimeAsDecimalWhenBelowThreshold(seconds, secondsThreshold, overThresholdTimeFormatOverride)
    secondsThreshold = secondsThreshold or 10
    if seconds < secondsThreshold then
        return ZO_FormatTime(seconds, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL_SHOW_TENTHS_SECS, TIME_FORMAT_PRECISION_TENTHS, TIME_FORMAT_DIRECTION_DESCENDING)
    elseif overThresholdTimeFormatOverride then
        return ZO_FormatTime(seconds, overThresholdTimeFormatOverride, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
    else
        return ZO_FormatTimeLargestTwo(seconds, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL)
    end
end

function ZO_FormatTimeShowUnitOverThresholdShowDecimalUnderThreshold(seconds, showUnitOverThresholdS, showDecimalUnderThresholdS, overThresholdTimeFormatOverride)
    assert(showDecimalUnderThresholdS < showUnitOverThresholdS, "Decimal threshold must be less than no unit threshold")
    showUnitOverThresholdS = showUnitOverThresholdS or ZO_ONE_MINUTE_IN_SECONDS
    showDecimalUnderThresholdS = showDecimalUnderThresholdS or 10
    if seconds < showDecimalUnderThresholdS then
        return string.format("%.1f", seconds)
    elseif seconds < showUnitOverThresholdS then
        return string.format("%d", zo_decimalsplit(seconds))
    elseif overThresholdTimeFormatOverride then
        return ZO_FormatTime(seconds, overThresholdTimeFormatOverride, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
    else
        return ZO_FormatTimeLargestTwo(seconds, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL)
    end
end

local CLOCK_FORMAT = (GetCVar("Language.2") == "en") and TIME_FORMAT_PRECISION_TWELVE_HOUR or TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR

function ZO_FormatClockTime()
    local localTimeSinceMidnight = GetSecondsSinceMidnight()
    local text, secondsUntilNextUpdate = ZO_FormatTime(localTimeSinceMidnight, TIME_FORMAT_STYLE_CLOCK_TIME, CLOCK_FORMAT)
    return text, secondsUntilNextUpdate
end

function ZO_SetClockFormat(clockFormat)
    -- Doesn't currently take effect until the next clock update.
    if CLOCK_FORMAT ~= clockFormat then
        CLOCK_FORMAT = clockFormat
        ZO_BuildHoursSinceMidnightPerHourTable()
    end
end

function ZO_GetClockFormat()
    return CLOCK_FORMAT
end

local g_normalizationTime = GetFrameTimeSeconds()

function ZO_NormalizeSecondsPositive(secs)
    return GetFrameTimeSeconds() - g_normalizationTime + secs
end

function ZO_NormalizeSecondsNegative(secs)
    return GetFrameTimeSeconds() - g_normalizationTime - secs
end

function ZO_NormalizeSecondsSince(secsSinceRequest)
    return ZO_NormalizeSecondsNegative(secsSinceRequest)
end

function ZO_NormalizeSecondsUntil(secsUntilExpiry)
    return ZO_NormalizeSecondsPositive(secsUntilExpiry)
end

do
    ZO_TIME_ESTIMATE_STYLE =
    {
        ANGLE_BRACKETS = 1,
        ARITHMETIC = 2,
    }

    local textUnknown = GetString(SI_STR_TIME_UNKNOWN)

    local textMinuteEstimate = GetString(SI_STR_TIME_LESS_THAN_MINUTE)
    local textMinuteEstimateShort = GetString(SI_STR_TIME_LESS_THAN_MINUTE_SHORT)

    local textHourEstimate = GetString(SI_STR_TIME_GREATER_THAN_HOUR)
    local textHourEstimateShort = GetString(SI_STR_TIME_GREATER_THAN_HOUR_SHORT)
    local textHourEstimatePlus = GetString(SI_STR_TIME_GREATER_THAN_HOUR_PLUS)
    local textHourEstimatePlusShort = GetString(SI_STR_TIME_GREATER_THAN_HOUR_PLUS_SHORT)

    local function GetLessThanStringId(formatType, estimateStyle)
        --Only the angle bracket style has been designed
        return formatType == TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT and textMinuteEstimateShort or textMinuteEstimate
    end

    local function GetGreaterThanStringId(formatType, estimateStyle)
        if estimateStyle == ZO_TIME_ESTIMATE_STYLE.ANGLE_BRACKETS then
            return formatType == TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT and textHourEstimateShort or textHourEstimate
        elseif estimateStyle == ZO_TIME_ESTIMATE_STYLE.ARITHMETIC then
            return formatType == TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT and textHourEstimatePlusShort or textHourEstimatePlus
        end 
    end

    function ZO_GetSimplifiedTimeEstimateText(estimatedTimeMs, formatType, precisionType, estimateStyle)
        formatType = formatType or TIME_FORMAT_STYLE_COLONS
        precisionType = precisionType or TIME_FORMAT_PRECISION_TWELVE_HOUR
        estimateStyle = estimateStyle or ZO_TIME_ESTIMATE_STYLE.ANGLE_BRACKETS
        
        if estimatedTimeMs == 0 then
            return textUnknown
        elseif estimatedTimeMs < ZO_ONE_MINUTE_IN_MILLISECONDS then
            return GetLessThanStringId(formatType, estimateStyle)
        elseif estimatedTimeMs > ZO_ONE_HOUR_IN_MILLISECONDS then
            return GetGreaterThanStringId(formatType, estimateStyle)
        else
            return ZO_FormatTimeMilliseconds(estimatedTimeMs, formatType, precisionType)
        end
    end
end

do
    local hoursSinceMidnightPerHour = {}

    function ZO_BuildHoursSinceMidnightPerHourTable()
        hoursSinceMidnightPerHour = {}
        for i = 0, 23 do
            table.insert(hoursSinceMidnightPerHour, { value = i, name = ZO_FormatTime(i * ZO_ONE_HOUR_IN_MINUTES * ZO_ONE_MINUTE_IN_SECONDS, TIME_FORMAT_STYLE_CLOCK_TIME, CLOCK_FORMAT) })
        end
    end

    ZO_BuildHoursSinceMidnightPerHourTable()

    function ZO_GetHoursSinceMidnightPerHourTable()
        return hoursSinceMidnightPerHour
    end

    function ZO_PopulateHoursSinceMidnightPerHourComboBox(comboBox, onSelectionCallback, selectedValue)
        comboBox:ClearItems()

        local selectedEntry
        for i, data in ipairs(hoursSinceMidnightPerHour) do
            local entry = comboBox:CreateItemEntry(data.name, onSelectionCallback)
            entry.value = data.value
            entry.index = i
            if data.value == selectedValue then
                selectedEntry = entry
            end
            comboBox:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
        end

        local IGNORE_CALLBACK = true
        if selectedEntry then
            comboBox:SelectItemByIndex(selectedEntry.index, IGNORE_CALLBACK)
        end
    end
end


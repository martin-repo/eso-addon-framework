--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]

local BossBar = ZO_Object:Subclass()

local SMOOTH_ANIMATE_BAR = true
local SET_BAR = false

function BossBar:New(...)
    local bar = ZO_Object.New(self)
    bar:Initialize(...)
    return bar
end

function BossBar:Initialize(control)
    self.control = control
    self.healthText = control:GetNamedChild("HealthText")
    self.bars = { GetControl(control, "HealthBarLeft"), GetControl(control, "HealthBarRight") }
    self.bossHealthValues = {}

    for i = 1, #self.bars do
        local gradient = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_HEALTH]
        ZO_StatusBar_SetGradientColor(self.bars[i], gradient)
    end

    self.bossUnitTags = {}
    for i = 1, MAX_BOSSES do
        self.bossUnitTags["boss"..i] = true
    end

    local function PowerUpdateHandlerFunction(unitTag, powerPoolIndex, powerType, powerPool, powerPoolMax)
        self:OnPowerUpdate(unitTag, powerType)
    end
    local powerUpdateEventHandler = ZO_MostRecentPowerUpdateHandler:New("BossBar", PowerUpdateHandlerFunction)
    powerUpdateEventHandler:AddFilterForEvent(REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
    powerUpdateEventHandler:AddFilterForEvent(REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")

    control:RegisterForEvent(EVENT_BOSSES_CHANGED, function(_, forceReset) self:RefreshAllBosses(forceReset) end)
    control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, function() self:OnPlayerActivated() end)
    control:RegisterForEvent(EVENT_INTERFACE_SETTING_CHANGED, function(_, settingSystem, settingId) self:OnInterfaceSettingChanged(settingSystem, settingId) end)

    self:ApplyStyle() -- Setup initial visual style based on current mode.
    control:RegisterForEvent(EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function() self:OnGamepadPreferredModeChanged() end)
end

function BossBar:ApplyStyle()
    ApplyTemplateToControl(self.control, ZO_GetPlatformTemplate("ZO_BossBar"))
end

function BossBar:OnGamepadPreferredModeChanged()
    self:ApplyStyle()
end

function BossBar:AddBoss(unitTag)
    self.bossHealthValues[unitTag] = {}
    self:RefreshBossHealth(unitTag)
end

function BossBar:RemoveBoss(unitTag)
    self.bossHealthValues[unitTag] = nil
end

function BossBar:RefreshBossHealth(unitTag)
    local bossEntry = self.bossHealthValues[unitTag]

    if bossEntry ~= nil then
        local health, maxHealth = GetUnitPower(unitTag, POWERTYPE_HEALTH)
        bossEntry.health = health
        bossEntry.maxHealth = maxHealth
    end
end

function BossBar:RefreshBossHealthBar(smoothAnimate)
    local totalHealth = 0
    local totalMaxHealth = 0

    for unitTag, bossEntry in pairs(self.bossHealthValues) do
        totalHealth = totalHealth + bossEntry.health
        totalMaxHealth = totalMaxHealth + bossEntry.maxHealth
    end

    local halfHealth = zo_floor(totalHealth / 2)
    local halfMax = zo_max(zo_floor(totalMaxHealth / 2), 1)

    for i = 1, #self.bars do
        ZO_StatusBar_SmoothTransition(self.bars[i], halfHealth, halfMax, not smoothAnimate)
    end
    
    self.healthText:SetText(ZO_FormatResourceBarCurrentAndMax(totalHealth, totalMaxHealth))

    COMPASS_FRAME:SetBossBarActive(totalHealth > 0)
end

function BossBar:RefreshAllBosses(forceReset)
    --if there are multiple bosses and one of them dies and despawns in the middle of the fight we
    --still want to show them as part of the boss bar (otherwise it will reset to 100%).
    local currentBossCount = 0
    for unitTag in pairs(self.bossUnitTags) do
        if(DoesUnitExist(unitTag)) then
            self:AddBoss(unitTag)
            currentBossCount = currentBossCount + 1
        end
    end

    --if there are no bosses left it's safe to reset everything
    if(forceReset or (currentBossCount == 0 and next(self.bossHealthValues) ~= nil)) then
        self.bossHealthValues = {}
    end

    self:RefreshBossHealthBar(SET_BAR)
end

--Events

function BossBar:OnPowerUpdate(unitTag, powerType)
    if(self.bossUnitTags[unitTag]) then
        self:RefreshBossHealth(unitTag)
        self:RefreshBossHealthBar(SMOOTH_ANIMATE_BAR)
    end
end

function BossBar:OnPlayerActivated()
    self:RefreshAllBosses()
    COMPASS_FRAME:SetBossBarReady(true)
end

function BossBar:OnInterfaceSettingChanged(settingSystem, settingId)
    if settingSystem == SETTING_TYPE_UI and settingId == UI_SETTING_RESOURCE_NUMBERS then
        self:RefreshBossHealthBar(SET_BAR)
    end
end

--Global XML

function ZO_BossBar_OnInitialized(self)
    BOSS_BAR = BossBar:New(self)
end
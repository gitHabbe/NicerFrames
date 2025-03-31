local GetQuestDifficultyColor = GetQuestDifficultyColor
local UnitName = UnitName
local UnitLevel = UnitLevel
local UnitHealth = UnitHealth
local UnitPower = UnitPower
local UnitHealthMax = UnitHealthMax
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local CombatFeedback_OnUpdate = CombatFeedback_OnUpdate
local frames = {}

function NicerFrames:UpdateValues()
    if #frames < 1 then
        frames = {
            PlayerFrameCustom = PlayerFrameCustom,
            TargetFrameCustom = TargetFrameCustom,
            PetFrameCustom = PetFrameCustom,
            TargetOfTargetFrameCustom = TargetOfTargetFrameCustom,
        }
    end

    self:UpdateLevel()
    self:UpdateName()
    self:UpdateHealthAndPower()
    self:UpdateDruidBar()
    self:UpdateCombatText()
end

function NicerFrames:UpdateLevel()
    for _, frame in pairs(frames) do
        local levelText = _G[frame:GetName() .. "TextureFrameLevelText"]
        if levelText then
            local level = UnitLevel(frame.unit)
            local bossSkull = _G[frame:GetName() .. "TextureFrameBossSkull"]

            local color = GetQuestDifficultyColor(level)
            levelText:SetText(level)
            if color.r == 1 and color.g == 1 and color.b == 0 and color.a == nil then
                levelText:SetTextColor(0.99999780301005, 0.81960606575012, 0, 0.99999779462814)
            else
                levelText:SetTextColor(color.r, color.g, color.b, color.a)
            end

            local fontPath, _, fontFlags = levelText:GetFont()
            levelText:SetFont(fontPath, 11, fontFlags)
        end
    end
end

function NicerFrames:UpdateName()
    for _, frame in pairs(frames) do
        local nameText = _G[frame:GetName() .. "HealthBarNameText"]
        if nameText then
            local name = UnitName(frame.unit)
            if self.db.profile.customPlayerName ~= "" and (frame.unit == "player" or UnitName(frame.unit) == UnitName("player")) then
                name = self.db.profile.customPlayerName
            end
            nameText:SetText(name)
        end
    end
end

function NicerFrames:UpdateHealthAndPower()
    for _, frame in pairs(frames) do
        local healthBar = _G[frame:GetName() .. "HealthBar"]
        local health = UnitHealth(frame.unit)
        local maxHealth = UnitHealthMax(frame.unit)
        healthBar:SetMinMaxValues(0, maxHealth)
        healthBar:SetValue(health)

        local powerBar = _G[frame:GetName() .. "PowerBar"]
        local power = UnitPower(frame.unit)
        local maxPower = UnitPowerMax(frame.unit)
        powerBar:SetMinMaxValues(0, maxPower)
        powerBar:SetValue(power)

        self:ToggleTextVisibility(frame)
    end
end

function NicerFrames:UpdateDruidBar()
    local powerType = UnitPowerType("player")
    if self.db.profile.hideDruidBar or (powerType ~= 1 and powerType ~= 3) then return end
    local druidBarStatus = _G["PlayerFrameCustomDruidBarStatus"]
   	local maxmana = UnitPowerMax("player", 0)
   	druidBarStatus:SetMinMaxValues(0, maxmana)
   	local currmana = UnitPower("player", 0)
   	druidBarStatus:SetValue(currmana)
    local druidBarText = _G["PlayerFrameCustomDruidBarStatusText"]
    druidBarText:SetText(self:FormatResourceText(self.db.profile.manaFormat, currmana, maxmana))
end

function NicerFrames:UpdateCombatText()
    if not self.db.profile.hideCombatText then
        if not self.updateTimer1 and not self.updateTimer2 and not self.updateTimer3 then
            self.updateTimer1 = self:ScheduleRepeatingTimer(function() CombatFeedback_OnUpdate(PlayerFrameCustom) end, 0.05)
            self.updateTimer2 = self:ScheduleRepeatingTimer(function() CombatFeedback_OnUpdate(TargetFrameCustom) end, 0.05)
            self.updateTimer3 = self:ScheduleRepeatingTimer(function() CombatFeedback_OnUpdate(PetFrameCustom) end, 0.05)
        end
    else
        if self.updateTimer1 then
            self:CancelTimer(self.updateTimer1)
        end
        if self.updateTimer2 then
            self:CancelTimer(self.updateTimer2)
        end
        if self.updateTimer3 then
            self:CancelTimer(self.updateTimer3)
        end
        self.updateTimer1 = nil
        self.updateTimer2 = nil
        self.updateTimer3 = nil
    end
end

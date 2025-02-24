local AddonName = "NicerFrames"
local LSM = LibStub("LibSharedMedia-3.0")
NicerFrames = LibStub("AceAddon-3.0"):NewAddon(AddonName, "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")

NicerFrames.buildInfo = select(2, GetBuildInfo())
NicerFrames.build = tonumber(NicerFrames.buildInfo)
NicerFrames.tocVersion = select(4, GetBuildInfo())
NicerFrames.isClassic = NicerFrames.build > 40000 and NicerFrames.tocVersion > 20000 and NicerFrames.tocVersion < 40000
NicerFrames.isClassic60 = NicerFrames.build > 40000 and NicerFrames.tocVersion < 20000
NicerFrames.isTBC = NicerFrames.build > 5000 and NicerFrames.build < 10000
NicerFrames.isWotlk = NicerFrames.build > 9000 and NicerFrames.build < 13000

local AURA_START_X = 1
local AURA_START_Y = 5

local function ModifyBuffParent(frame, buffName, index, numDebuffs, anchorIndex, size, offsetX, offsetY)
    local buffFrame = _G[buffName .. index]
    if not buffFrame then return end
    buffFrame:SetParent(TargetFrameCustom)
    if index == 1 then
        buffFrame:ClearAllPoints()
        if UnitIsFriend("player", frame.unit) or numDebuffs == 0 then
            buffFrame:SetPoint("TOPLEFT", TargetFrameCustom, "BOTTOMLEFT", AURA_START_X, AURA_START_Y)
        else
            if frame.debuffs then
                buffFrame:SetPoint("TOPLEFT", frame.debuffs, "BOTTOMLEFT", 0, -offsetY)
            end
        end

        if frame.buffs then
            frame.buffs:SetParent(TargetFrameCustom)
        end
    end
end

local function ModifyDebuffParent(frame, debuffName, index, numBuffs, anchorIndex, size, offsetX, offsetY)
    local debuffFrame = _G[debuffName .. index]
    if not debuffFrame then return end
    debuffFrame:SetParent(TargetFrameCustom)
    if index == 1 then
        debuffFrame:ClearAllPoints()
        if UnitIsFriend("player", frame.unit) and numBuffs > 0 then
            if frame.buffs then
                debuffFrame:SetPoint("TOPLEFT", frame.buffs, "BOTTOMLEFT", 0, -offsetY)
            else
                debuffFrame:SetPoint("TOPLEFT", TargetFrameCustom, "BOTTOMLEFT", AURA_START_X, AURA_START_Y)
            end
        else
            debuffFrame:SetPoint("TOPLEFT", TargetFrameCustom, "BOTTOMLEFT", AURA_START_X, AURA_START_Y)
        end

        if frame.debuffs then
            frame.debuffs:SetParent(TargetFrameCustom)
        end
    end
end

function NicerFrames:AddOnLeaveEvent(frame)
    local textTypes = {
        "Health",
        "Power"
    }
    for _, textType in ipairs(textTypes) do
        local UnitTextType, UnitMaxTextType
        if textType == "Health" then
            UnitTextType = UnitHealth
            UnitMaxTextType = UnitHealthMax
        elseif textType == "Power" then
            UnitTextType = UnitPower
            UnitMaxTextType = UnitPowerMax
        end
        local resourceBar = _G[frame:GetName() .. textType .. "Bar"]
        local resourceText = _G[resourceBar:GetName() .. "Text"]
        if resourceBar:GetScript("OnLeave") then return end
        resourceBar:EnableMouse(true)
        resourceBar:SetScript("OnMouseDown", function(self, button)
            frame:GetScript("OnClick")(frame, button)
        end)
        resourceBar:SetScript("OnLeave", function(self2)
            local resourceType = UnitTextType(frame.unit)
            local maxResourceType = UnitMaxTextType(frame.unit)
            local isMaxResource = resourceType == maxResourceType
            local alwaysShow = self.db.profile.alwaysShowStatusText
            local hideFull = self.db.profile.hideFullStatusTexts

            if (isMaxResource and hideFull) or not alwaysShow then
                resourceText:Hide()
            end
        end)
        resourceBar:SetScript("OnEnter", function(self2)
            _G[self2:GetName() .. "Text"]:Show();
        end)
    end
end

function NicerFrames:OnInitialize()
    self:InitDatabase()
    LibStub("AceConfig-3.0"):RegisterOptionsTable(AddonName, Options2)
    self.options = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddonName, AddonName)

    self:RegisterOptionCategory("General", Options["args"]["General"])
    self:RegisterOptionCategory("Frame specific", Options["args"]["Frame specific"])
    self:RegisterOptionCategory("Debug", Options["args"]["Debug"])
    self:RegisterOptionCategory("Profiles", Options.args.profiles)
    -- self:CreateCenterLine()
end

function NicerFrames:CreateCenterLine()
    local centerLine = CreateFrame("Frame", nil, UIParent)
    centerLine:SetWidth(1)
    centerLine:SetHeight(GetScreenHeight())
    centerLine:SetPoint("TOP", UIParent, "TOP", 0, 0)
    local t = centerLine:CreateTexture()
    t:SetAllPoints()
    t:SetTexture(1, 0, 0, 0.5)
end

function NicerFrames:RegisterOptionCategory(name, optionsPath)
    LibStub("AceConfig-3.0"):RegisterOptionsTable(name, optionsPath)
    self.options[name] = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(name, name, AddonName)
end

function NicerFrames:STANDARD_UPDATE()
    self:UpdateFrame()
end

function NicerFrames:PLAYER_ENTERING_WORLD()
    PlayerFrameCustom.isMoving = false
    TargetFrameCustom.isMoving = false
    PetFrameCustom.isMoving = false

    CombatFeedback_Initialize(PlayerFrameCustom, PlayerFrameCustomTextureFrameHitIndicator, 34);
    TargetFrameCustomTextureFrameHitIndicator:ClearAllPoints()
    TargetFrameCustomTextureFrameHitIndicator:SetPoint("CENTER", TargetFrameCustomTextureFrame, "CENTER", 63, 4)
    CombatFeedback_Initialize(TargetFrameCustom, TargetFrameCustomTextureFrameHitIndicator, 34);
    PetFrameCustomTextureFrameHitIndicator:ClearAllPoints()
    PetFrameCustomTextureFrameHitIndicator:SetPoint("CENTER", PetFrameCustomTextureFrame, "CENTER", -36, 5)
    CombatFeedback_Initialize(PetFrameCustom, PetFrameCustomTextureFrameHitIndicator, 34);
    self:UpdateFrame()

    function MyUpdateFunction()
        CombatFeedback_OnUpdate(PlayerFrameCustom)
    end

    function MyUpdateFunction2()
        CombatFeedback_OnUpdate(TargetFrameCustom)
    end

    function MyUpdateFunction3()
        CombatFeedback_OnUpdate(PetFrameCustom)
    end

    self.updateTimer = self:ScheduleRepeatingTimer(MyUpdateFunction, 0.05)
    self.updateTimer = self:ScheduleRepeatingTimer(MyUpdateFunction2, 0.05)
    self.updateTimer = self:ScheduleRepeatingTimer(MyUpdateFunction3, 0.05)

    hooksecurefunc("TargetFrame_UpdateBuffAnchor", ModifyBuffParent)
    hooksecurefunc("TargetFrame_UpdateDebuffAnchor", ModifyDebuffParent)
end

function NicerFrames:PLAYER_TARGET_CHANGED()
    local targetExists = UnitExists("target")
    local targetOfTargetExists = UnitExists("targettarget")
    if targetExists then
        TargetFrameCustom:Show()
        self:UpdateFrame()
    else
        TargetFrameCustom:Hide()
    end
    if targetOfTargetExists then
        TargetOfTargetFrameCustom:Show()
    else
        TargetOfTargetFrameCustom:Hide()
    end
end

function NicerFrames:PLAYER_REGEN_ENABLED()
    self.isCombat = nil
end

function NicerFrames:PLAYER_REGEN_DISABLED()
    self.isCombat = 1
end

function NicerFrames:CreateUnitFrame(unit, frameName, parent)
    local frame = CreateFrame("Button", frameName, parent, "PlayerFrameCustom")
    frame.unit = unit
    frame.parent = parent
    frame:SetAttribute("unit", unit)
    RegisterUnitWatch(frame)


    self:AddOnLeaveEvent(frame)

    frame:RegisterForClicks("AnyUp")
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnMouseDown", function(frameObj, button)
        if not IsShiftKeyDown() then return end
        if button == "LeftButton" then
            frame:StartMoving()
            frame.isMoving = true
        end
    end)

    frame:SetScript("OnMouseUp", function(frameObj, button)
        if button == "LeftButton" then
            frame:StopMovingOrSizing()
            NicerFrames:SaveFramePosition(frameObj)
            frame.isMoving = false
        end
    end)

    return frame
end

function NicerFrames:UNIT_PET(event, unit)
    if unit ~= "player" then return end
    local playerPetExists = UnitExists("pet")
    if playerPetExists then
        PetFrameCustom:Show()
    else
        PetFrameCustom:Hide()
    end
    self:UpdateFrame()
end

function NicerFrames:UNIT_COMBAT(event, ...)
    local arg1, arg2, arg3, arg4, arg5 = ...
    if arg1 == "target" then
        CombatFeedback_OnCombatEvent(TargetFrameCustom, arg2, arg3, arg4, arg5);
    elseif arg1 == "player" then
        CombatFeedback_OnCombatEvent(PlayerFrameCustom, arg2, arg3, arg4, arg5);
    elseif arg1 == "pet" then
        CombatFeedback_OnCombatEvent(PetFrameCustom, arg2, arg3, arg4, arg5);
    end
end

function NicerFrames:READY_CHECK()
    local readyCheck = _G["PlayerFrameCustomReadyCheck"]
    readyCheck:Show()
    local readyCheckStatus = GetReadyCheckStatus("player");
    if readyCheckStatus then
        if readyCheckStatus == "ready" then
            ReadyCheck_Confirm(readyCheck, 1);
        elseif readyCheckStatus == "notready" then
            ReadyCheck_Confirm(readyCheck, 0);
        else
            ReadyCheck_Start(readyCheck);
        end
    else
        readyCheck:Hide();
    end
end

function NicerFrames:ROSTER_UPDATE()
    PlayerFrameCustomGroupIndicatorParent:Hide()
    local numRaidMembers = GetNumRaidMembers()
    if numRaidMembers == 0 then return end
    for i = 1, MAX_RAID_MEMBERS do
        if i <= numRaidMembers then
            local name, _, subgroup = GetRaidRosterInfo(i)
            if name == UnitName("player") then
                PlayerFrameCustomGroupIndicatorParentGroupIndicatorText:SetText(GROUP .. " " .. subgroup)
                local groupIndicatorParent = _G[frame:GetName() .. "GroupIndicatorParent"]
                groupIndicatorParent:SetWidth(PlayerFrameCustomGroupIndicatorParentGroupIndicatorText:GetWidth() + 40);
                groupIndicatorParent:Show()
            end
        end
    end
end

function NicerFrames:ApplyRestGlow(self2, elapsed)
    if (PlayerFrameCustomTextureFrameStatusTexture:IsShown()) then
        local alpha   = 255
        local counter = self2.statusCounter + elapsed
        local sign    = self2.statusSign

        if (counter > 0.5) then
            sign = -sign;
            self2.statusSign = sign
        end
        counter = mod(counter, 0.5)
        self2.statusCounter = counter

        if (sign == 1) then
            alpha = (55 + (counter * 400)) / 255
        else
            alpha = (255 - (counter * 400)) / 255
        end
        PlayerFrameCustomTextureFrameStatusTexture:SetAlpha(alpha)
        PlayerFrameCustomTextureFrameRestGlow:SetAlpha(alpha)
    end
end

function NicerFrames:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UNIT_HEALTH", "STANDARD_UPDATE")
    self:RegisterEvent("UNIT_MAXHEALTH", "STANDARD_UPDATE")
    self:RegisterEvent("UNIT_MANA", "STANDARD_UPDATE")
    self:RegisterEvent("UNIT_MAXMANA", "STANDARD_UPDATE")
    self:RegisterEvent("UNIT_NAME_UPDATE", "STANDARD_UPDATE")
    self:RegisterEvent("PLAYER_LEVEL_UP", "STANDARD_UPDATE")
    self:RegisterEvent("UNIT_PORTRAIT_UPDATE", "STANDARD_UPDATE")
    self:RegisterEvent("PORTRAITS_UPDATED", "STANDARD_UPDATE")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("UNIT_PET")
    self:RegisterEvent("UNIT_COMBAT")
    self:RegisterEvent("READY_CHECK")
    self:RegisterEvent("RAID_TARGET_UPDATE", "STANDARD_UPDATE")

    self:RegisterEvent("PARTY_MEMBERS_CHANGED", "ROSTER_UPDATE")
    self:RegisterEvent("PARTY_LEADER_CHANGED", "ROSTER_UPDATE")
    self:RegisterEvent("RAID_ROSTER_UPDATE", "ROSTER_UPDATE")

    local NicerFramesPlayer = self:CreateUnitFrame("player", "PlayerFrameCustom", UIParent)
    NicerFramesPlayer:SetScript("OnClick", PlayerFrameCustom_OnClick)
    NicerFramesPlayer.statusCounter = 0;
    NicerFramesPlayer.statusSign = -1;
    NicerFramesPlayer:SetScript("OnUpdate", function(self2, elapsed) self:ApplyRestGlow(self2, elapsed) end)
    NicerFramesPlayer:SetAttribute("*type1", "target")
    local NicerFramesTarget = self:CreateUnitFrame("target", "TargetFrameCustom", UIParent)
    NicerFramesTarget:SetScript("OnClick", PlayerFrameCustom_OnClick)
    local NicerFramesPet = self:CreateUnitFrame("pet", "PetFrameCustom", UIParent)
    NicerFramesPet:SetScript("OnClick", PlayerFrameCustom_OnClick)
    local NicerFramesTargetOfTarget = self:CreateUnitFrame("targettarget", "TargetOfTargetFrameCustom", UIParent)
    NicerFramesTargetOfTarget:EnableMouse(true)
    NicerFramesTargetOfTarget:SetAttribute("*type1", "target")
    PlayerFrame:Hide()
    TargetFrame:Hide()
    PetFrame:Hide()
    TargetFrame:SetScript("OnEvent", nil)
    TargetFrame:UnregisterAllEvents()
    local function BlizzardTargetFrameEvents(self2, event, ...)
        local arg1 = ...
        if event == "PLAYER_ENTERING_WORLD" then
            TargetFrame_Update(self2)
            TargetFrame_UpdateAuras(self2)
            TargetFrame:Hide()
        elseif event == "PLAYER_TARGET_CHANGED" then
            TargetFrame_Update(self2)
            TargetFrame_UpdateAuras(self2)
        elseif event == "UNIT_AURA" then
            if arg1 == "target" then
                TargetFrame_UpdateAuras(self2)
            end
        end
        TargetFrame:Hide()
    end
    TargetFrame:SetScript("OnEvent", BlizzardTargetFrameEvents)
    TargetFrame:RegisterEvent("UNIT_AURA")
    TargetFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    TargetFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    NicerFramesTarget:SetScript("OnEnter", function(self2)
        UnitFrame_UpdateTooltip(self2)
    end)
    NicerFramesTarget:SetScript("OnLeave", function(self2)
        GameTooltip:FadeOut()
    end)
    NicerFramesPlayer:SetScript("OnEnter", function(self2)
        UnitFrame_UpdateTooltip(self2)
    end)
    NicerFramesPlayer:SetScript("OnLeave", function(self2)
        GameTooltip:FadeOut()
    end)
    NicerFramesPet:SetScript("OnEnter", function(self2)
        UnitFrame_UpdateTooltip(self2)
    end)
    NicerFramesPet:SetScript("OnLeave", function(self2)
        GameTooltip:FadeOut()
    end)
    NicerFramesTargetOfTarget:SetScript("OnEnter", function(self2)
        UnitFrame_UpdateTooltip(self2)
    end)
    NicerFramesTargetOfTarget:SetScript("OnLeave", function(self2)
        GameTooltip:FadeOut()
    end)

    LSM:Register("statusbar", "LiteStep", "Interface\\AddOns\\NicerFrames\\Textures\\StatusBar\\LiteStep")
    LSM:Register("statusbar", "glaze", "Interface\\AddOns\\NicerFrames\\Textures\\StatusBar\\glaze")

    self:RefreshConfig()
    self:CreateSlashCommands()

    if self.db.profile.debugMode then
        -- self:SlashCommand("")
    end
end

function NicerFrames:ReloadInterface()
    ReloadUI()
end

function NicerFrames:RefreshConfig()
    local playerFrame = _G["PlayerFrameCustom"]
    self:Layout(playerFrame)
    local targetFrame = _G["TargetFrameCustom"]
    self:Layout(targetFrame)
    local petFrame = _G["PetFrameCustom"]
    self:Layout(petFrame)
    local targetOfTargetFrame = _G["TargetOfTargetFrameCustom"]
    self:Layout(targetOfTargetFrame)
    self:UpdateValues()
    self:UpdatePlayerFrameBorder()
end

function NicerFrames:CreateSlashCommands()
    self:RegisterChatCommand("nicerframes", "SlashCommand")
    self:RegisterChatCommand("nf", "SlashCommand")
end

function NicerFrames:SlashCommand(msg)
    if self.isClassic or self.isWotlk or self.isClassic60 then
        InterfaceOptionsFrame_OpenToCategory(self.options)
    elseif self.isTBC then
        InterfaceOptionsFrame_OpenToFrame(AddonName)
    end
end

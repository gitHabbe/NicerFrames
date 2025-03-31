local AddonName = "NicerFrames"
local LibStub = LibStub
local LSM = LibStub("LibSharedMedia-3.0")
local GetBuildInfo = GetBuildInfo
local UnitIsFriend = UnitIsFriend
local UnitHealth = UnitHealth
local UnitPower = UnitPower
local UnitHealthMax = UnitHealthMax
local UnitPowerMax = UnitPowerMax
local CreateFrame = CreateFrame
local UIParent = UIParent
local GetScreenHeight = GetScreenHeight
local ComboFrame = ComboFrame
local CombatFeedback_Initialize = CombatFeedback_Initialize
local CombatFeedback_OnUpdate = CombatFeedback_OnUpdate
local hooksecurefunc = hooksecurefunc
local UnitExists = UnitExists
local RegisterUnitWatch = RegisterUnitWatch
local IsShiftKeyDown = IsShiftKeyDown
local CombatFeedback_OnCombatEvent = CombatFeedback_OnCombatEvent
local GetReadyCheckStatus = GetReadyCheckStatus
local ReadyCheck_Confirm = ReadyCheck_Confirm
local ReadyCheck_Start = ReadyCheck_Start
local GetNumRaidMembers = GetNumRaidMembers
local MAX_RAID_MEMBERS = MAX_RAID_MEMBERS
local GetRaidRosterInfo = GetRaidRosterInfo
local UnitName = UnitName
local GROUP = GROUP
local mod = mod
local IsResting = IsResting
local PlayerFrame = PlayerFrame
local TargetFrame = TargetFrame
local PetFrame = PetFrame
local TargetFrame_Update = TargetFrame_Update
local TargetFrame_UpdateAuras = TargetFrame_UpdateAuras
local UnitFrame_UpdateTooltip = UnitFrame_UpdateTooltip
local GameTooltip = GameTooltip
local ReloadUI = ReloadUI
local InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory
local InterfaceOptionsFrame_OpenToFrame = InterfaceOptionsFrame_OpenToFrame
local ToggleDropDownMenu = ToggleDropDownMenu

NicerFrames = LibStub("AceAddon-3.0"):NewAddon(AddonName, "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")
NicerFrames.buildInfo = select(2, GetBuildInfo())
NicerFrames.build = tonumber(NicerFrames.buildInfo)
NicerFrames.tocVersion = select(4, GetBuildInfo())
NicerFrames.isClassic = NicerFrames.build > 40000 and NicerFrames.tocVersion > 20000 and NicerFrames.tocVersion < 40000
NicerFrames.isClassic60 = NicerFrames.build > 40000 and NicerFrames.tocVersion < 20000
NicerFrames.isTBC = NicerFrames.build > 5000 and NicerFrames.build < 10000
NicerFrames.isWotlk = NicerFrames.build > 9000 and NicerFrames.build < 13000

local AURA_START_X = 3
local AURA_START_Y = 5

local function ModifySpellbarPosition(spellbar)
    TargetFrameCustom.haveToT = true
    TargetFrameCustom.haveElite = true
    TargetFrameCustom.auraRows = 1

    if not TargetFrameCustom.spellbarAnchor then
        TargetFrameCustom.spellbarAnchor = spellbar
        spellbar:SetParent(TargetFrameCustom)
    end

    local xOffset = 24
    local yOffset = -26
    if NicerFrames.db.profile.unitFrameStyle == "ArenaLive" then
        xOffset = 40
        yOffset = -21
    end
    local a = UnitBuff("target", 1)
    local b = UnitDebuff("target", 1)
    TargetFrameSpellBar:SetParent(TargetFrameCustom)
    if not a and not b then
        TargetFrameSpellBar:SetPoint("TOPLEFT", TargetFrameCustom, "BOTTOMLEFT", xOffset, yOffset - 8)
    else
        TargetFrameSpellBar:SetPoint("TOPLEFT", TargetFrame.spellbarAnchor, "BOTTOMLEFT", 25, -18)
    end

end

local function ModifySpellbarPositionOnEvent(self2, event, ...)
    if self2.unit == "target" and (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START") then
        Target_Spellbar_AdjustPosition(self2)
    end
end

local function ModifyBuffParent(frame, buffName, index, numDebuffs, anchorIndex, size, offsetX, offsetY)
    local buffFrame = _G[buffName .. index]
    if not buffFrame then return end
    buffFrame:SetParent(TargetFrameCustom)
    if index == 1 then
        buffFrame:ClearAllPoints()
        local xOffset = 3
        local yOffset = 5
        if NicerFrames.db.profile.unitFrameStyle == "ArenaLive" then
            xOffset = 34
            yOffset = 2
        end
        if UnitIsFriend("player", frame.unit) or numDebuffs == 0 then
            buffFrame:SetPoint("TOPLEFT", TargetFrameCustom, "BOTTOMLEFT", xOffset, yOffset)
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
            if button == "RightButton" then
                local frameReference = ""
                if frame:GetName() == "PlayerFrameCustom" then frameReference = "PlayerFrame" end
                if frame:GetName() == "TargetFrameCustom" then frameReference = "TargetFrame" end
                if frame:GetName() == "PetFrameCustom" then frameReference = "PetFrame" end
                ToggleDropDownMenu(1, nil, _G[frameReference .. "DropDown"], "cursor")
            end
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
            _G[self2:GetName() .. "Text"]:Show()
        end)
    end
    if frame.unit == "player" then
        local resourceBar = _G["PlayerFrameCustomDruidBarStatus"]
        local resourceText = _G["PlayerFrameCustomDruidBarStatusText"]

        -- Create an invisible overlay frame for mouse events
        if not resourceBar.mouseOverlay then
            resourceBar.mouseOverlay = CreateFrame("Frame", "PlayerFrameCustomDruidBarMouseOverlay", resourceBar)

            resourceBar.mouseOverlay:SetPoint("TOPLEFT", resourceBar, "TOPLEFT", -5, 0)
            resourceBar.mouseOverlay:SetPoint("BOTTOMRIGHT", resourceBar, "BOTTOMRIGHT", 5, -3)

            resourceBar.mouseOverlay:EnableMouse(true)
            -- resourceBar.mouseOverlay:SetFrameLevel(1)

            resourceBar.mouseOverlay:SetScript("OnEnter", function(self)
                resourceText:Show()
            end)

            resourceBar.mouseOverlay:SetScript("OnLeave", function(self)
                local currmana = UnitPower(frame.unit, 0)
                local maxmana = UnitPowerMax(frame.unit, 0)
                local isMaxResource = currmana == maxmana
                local alwaysShow = NicerFrames.db.profile.alwaysShowStatusText
                local hideFull = NicerFrames.db.profile.hideFullStatusTexts

                if (isMaxResource and hideFull) or not alwaysShow then
                    resourceText:Hide()
                end
            end)
        end

        resourceBar:EnableMouse(false)
    end
end
function NicerFrames:OnInitialize()
    self:InitDatabase()
    LibStub("AceConfig-3.0"):RegisterOptionsTable(AddonName, Options2)
    self.options = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddonName, AddonName)

    self:RegisterOptionCategory("General", Options["args"]["General"])
    self:RegisterOptionCategory("Frame specific", Options["args"]["Frame specific"])
    self:RegisterOptionCategory("Profiles", Options.args.profiles)

    -- self:CreateCenterLine()
end

function NicerFrames:CreateCenterLine()
    local centerLine = CreateFrame("Frame", nil, UIParent)
    centerLine:SetWidth(1)
    centerLine:SetHeight(GetScreenHeight())
    centerLine:SetPoint("TOP", UIParent, "TOP", 0, 0)
    local texture = centerLine:CreateTexture()
    texture:SetAllPoints()
    texture:SetTexture(1, 0, 0, 0.5)
end

function NicerFrames:RegisterOptionCategory(name, optionsPath)
    LibStub("AceConfig-3.0"):RegisterOptionsTable(name, optionsPath)
    self.options[name] = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(name, name, AddonName)
end

function NicerFrames:STANDARD_UPDATE()
    self:UpdateFrames()
end

local function ModifyComboParent()
    local comboFrame = ComboFrame
    if not comboFrame then return end
    comboFrame:SetParent(TargetFrameCustom)
    comboFrame:ClearAllPoints()
    comboFrame:SetPoint("TOPRIGHT", TargetFrameCustom, "TOPRIGHT", 2, 11)
end

function NicerFrames:HookAurasAndCastBar()
    local addonName = "NicerAuras"
    local loaded, finished = IsAddOnLoaded(addonName)
    local addonFound = false

    if loaded then
        addonFound = true
    else
        -- Set up an event to check when it gets loaded
        self:RegisterEvent("ADDON_LOADED", function(event, loadedAddon)
            print(event)
            if loadedAddon == addonName then
                addonFound = true
                self:UnregisterEvent("ADDON_LOADED")
                ModifyBuffParent = function() end
                ModifyDebuffParent = function() end
            end
        end)
    end

    if not addonFound then
        hooksecurefunc("TargetFrame_UpdateBuffAnchor", ModifyBuffParent)
        hooksecurefunc("TargetFrame_UpdateDebuffAnchor", ModifyDebuffParent)
        hooksecurefunc("CastingBarFrame_OnEvent", ModifySpellbarPositionOnEvent)
        if not self.db.profile.hideDefaultCastBar then
            hooksecurefunc("Target_Spellbar_AdjustPosition", ModifySpellbarPosition)
        end
    end
    hooksecurefunc("ComboFrame_Update", ModifyComboParent)

    TargetFrameCustom.haveToT = true
    TargetFrameCustom.haveElite = true
    TargetFrameCustom.auraRows = 1
end

function NicerFrames:AssignCombatFeedback()
    CombatFeedback_Initialize(PlayerFrameCustom, PlayerFrameCustomTextureFrameHitIndicator, 34)
    TargetFrameCustomTextureFrameHitIndicator:ClearAllPoints()
    TargetFrameCustomTextureFrameHitIndicator:SetPoint("CENTER", TargetFrameCustomTextureFrame, "CENTER", 63, 4)
    CombatFeedback_Initialize(TargetFrameCustom, TargetFrameCustomTextureFrameHitIndicator, 34)
    PetFrameCustomTextureFrameHitIndicator:ClearAllPoints()
    PetFrameCustomTextureFrameHitIndicator:SetPoint("CENTER", PetFrameCustomTextureFrame, "CENTER", -36, 5)
    CombatFeedback_Initialize(PetFrameCustom, PetFrameCustomTextureFrameHitIndicator, 34)
end

function NicerFrames:PLAYER_ENTERING_WORLD()
    PlayerFrameCustom.isMoving = false
    TargetFrameCustom.isMoving = false
    PetFrameCustom.isMoving = false

    self:UpdateFrames()
    self:PLAYER_UPDATE_RESTING()
    self:LayoutRaidGroup()
    self:HookAurasAndCastBar()
    self:AssignCombatFeedback()
end

function NicerFrames:PLAYER_TARGET_CHANGED()
    local targetExists = UnitExists("target")
    local targetOfTargetExists = UnitExists("targettarget")
    if targetExists then
        TargetFrameCustom:Show()
        self:UpdateFrames()
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
    self:UpdateFrames()
end

function NicerFrames:UNIT_COMBAT(event, ...)
    local arg1, arg2, arg3, arg4, arg5 = ...
    if arg1 == "target" then
        CombatFeedback_OnCombatEvent(TargetFrameCustom, arg2, arg3, arg4, arg5)
    elseif arg1 == "player" then
        CombatFeedback_OnCombatEvent(PlayerFrameCustom, arg2, arg3, arg4, arg5)
    elseif arg1 == "pet" then
        CombatFeedback_OnCombatEvent(PetFrameCustom, arg2, arg3, arg4, arg5)
    end
end

function NicerFrames:READY_CHECK()
    local readyCheck = _G["PlayerFrameCustomReadyCheck"]
    readyCheck:Show()
    local readyCheckStatus = GetReadyCheckStatus("player")
    if readyCheckStatus then
        if readyCheckStatus == "ready" then
            ReadyCheck_Confirm(readyCheck, 1)
        elseif readyCheckStatus == "notready" then
            ReadyCheck_Confirm(readyCheck, 0)
        else
            ReadyCheck_Start(readyCheck)
        end
    else
        readyCheck:Hide()
    end
end

function NicerFrames:ROSTER_UPDATE()
    self:LayoutRaidGroup()
end

function NicerFrames:ApplyRestGlow(self2, elapsed)
    if (PlayerFrameCustomTextureFrameStatusTexture:IsShown()) then
        local alpha   = 255
        local counter = self2.statusCounter + elapsed
        local sign    = self2.statusSign

        if (counter > 0.5) then
            sign = -sign
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

function NicerFrames:PLAYER_UPDATE_RESTING()
    if IsResting() and not self.db.profile.hideRestGlow then
        PlayerFrameCustomTextureFrameStatusTexture:Show()
        PlayerFrameCustomTextureFrameRestGlow:Show()
        PlayerFrameCustom:SetScript("OnUpdate", function(self2, elapsed) self:ApplyRestGlow(self2, elapsed) end)
    else
        PlayerFrameCustomTextureFrameStatusTexture:Hide()
        PlayerFrameCustomTextureFrameRestGlow:Hide()
        PlayerFrameCustom:SetScript("OnUpdate", nil)
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
    self:RegisterEvent("UNIT_DISPLAYPOWER", "STANDARD_UPDATE")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("UNIT_PET")
    self:RegisterEvent("UNIT_COMBAT")
    self:RegisterEvent("READY_CHECK")
    self:RegisterEvent("PLAYER_UPDATE_RESTING")
    self:RegisterEvent("RAID_TARGET_UPDATE", "STANDARD_UPDATE")

    self:RegisterEvent("PARTY_MEMBERS_CHANGED", "ROSTER_UPDATE")
    self:RegisterEvent("PARTY_LEADER_CHANGED", "ROSTER_UPDATE")
    self:RegisterEvent("RAID_ROSTER_UPDATE", "ROSTER_UPDATE")

    local NicerFramesPlayer = self:CreateUnitFrame("player", "PlayerFrameCustom", UIParent)
    NicerFramesPlayer:SetScript("PostClick", PlayerFrameCustom_OnClick)
    NicerFramesPlayer.statusCounter = 0
    NicerFramesPlayer.statusSign = -1
    NicerFramesPlayer:EnableMouse(true)
    NicerFramesPlayer:SetAttribute("*type1", "target")
    local NicerFramesTarget = self:CreateUnitFrame("target", "TargetFrameCustom", UIParent)
    NicerFramesTarget:SetScript("OnClick", PlayerFrameCustom_OnClick)
    local NicerFramesPet = self:CreateUnitFrame("pet", "PetFrameCustom", UIParent)
    NicerFramesPet:SetScript("PostClick", PlayerFrameCustom_OnClick)
    NicerFramesPet:EnableMouse(true)
    NicerFramesPet:SetAttribute("*type1", "target")
    local NicerFramesTargetOfTarget = self:CreateUnitFrame("targettarget", "TargetOfTargetFrameCustom", UIParent)
    NicerFramesTargetOfTarget:EnableMouse(true)
    NicerFramesTargetOfTarget:SetAttribute("*type1", "target")
    PlayerFrame:Hide()
    TargetFrame:Hide()
    PetFrame:Hide()
    TargetFrame:SetScript("OnEvent", nil)
    TargetFrame:UnregisterAllEvents()

    local function SafeTargetFrameUpdate(frame)
        local originalFunction = Target_Spellbar_AdjustPosition
        Target_Spellbar_AdjustPosition = function() end
        TargetFrame_Update(frame)
        Target_Spellbar_AdjustPosition = originalFunction
    end

    local function SafeTargetFrameUpdateAuras(frame)
        local originalFunction = Target_Spellbar_AdjustPosition
        Target_Spellbar_AdjustPosition = function() end
        TargetFrame_UpdateAuras(frame)
        Target_Spellbar_AdjustPosition = originalFunction
    end

    local function BlizzardTargetFrameEvents(self2, event, ...)
        local arg1 = ...
        if event == "PLAYER_ENTERING_WORLD" then
            SafeTargetFrameUpdateAuras(self2)
            SafeTargetFrameUpdate(self2)
            TargetFrame:Hide()
        elseif event == "PLAYER_TARGET_CHANGED" then
            SafeTargetFrameUpdateAuras(self2)
            SafeTargetFrameUpdate(self2)
        elseif event == "UNIT_AURA" then
            if arg1 == "target" then
                SafeTargetFrameUpdateAuras(self2)
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
        self:SlashCommand("")
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
    self:LayoutPlayerFrameBorder()
end

function NicerFrames:ToggleDebugMode()
    self.db.profile.debugMode = not self.db.profile.debugMode
    self:RefreshConfig()
end

function NicerFrames:CreateSlashCommands()
    self:RegisterChatCommand("nicerframes", "SlashCommand")
    self:RegisterChatCommand("nf", "SlashCommand")
    self:RegisterChatCommand("nfdebug", "ToggleDebugMode")
end

function NicerFrames:SlashCommand(msg)
    if self.isClassic or self.isWotlk or self.isClassic60 then
        InterfaceOptionsFrame_OpenToCategory(self.options)
    elseif self.isTBC then
        InterfaceOptionsFrame_OpenToFrame(AddonName)
    end
end

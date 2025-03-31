local LSM = LibStub("LibSharedMedia-3.0")
local unpack = unpack
local SetPortraitTexture = SetPortraitTexture
local UnitExists = UnitExists
local UnitReaction = UnitReaction
local TargetFrame = TargetFrame
local IsResting = IsResting
local IsPartyLeader = IsPartyLeader
local HasLFGRestrictions = HasLFGRestrictions
local GetLootMethod = GetLootMethod
local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers
local UnitFactionGroup = UnitFactionGroup
local UnitIsPVPFreeForAll = UnitIsPVPFreeForAll
local UnitIsPVP = UnitIsPVP
local GetRaidTargetIndex = GetRaidTargetIndex
local SetRaidTargetIconTexture = SetRaidTargetIconTexture
local PowerBarColor = PowerBarColor
local UnitSelectionColor = UnitSelectionColor
local UnitClass = UnitClass
local UnitIsPlayer = UnitIsPlayer
local UIParent = UIParent
local UnitPowerType = UnitPowerType
local UnitClassification = UnitClassification
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local barTexture
local classTexCoords = {
    ["WARLOCK"] = { 0, 0.25, 0, 0.25 },
    ["ROGUE"] = { 0.25, 0.5, 0, 0.25 },
    ["PALADIN"] = { 0.50, 0.75, 0, 0.25 },
    ["MAGE"] = { 0.75, 1, 0, 0.25 },
    ["DRUID"] = { 0, 0.25, 0.25, 0.5 },
    ["HUNTER"] = { 0.25, 0.5, 0.25, 0.5 },
    ["PRIEST"] = { 0.50, 0.75, 0.25, 0.5 },
    ["SHAMAN"] = { 0.75, 1, 0.25, 0.5 },
    ["MONK"] = { 0, 0.25, 0.5, 0.75 },
    ["WARRIOR"] = { 0, 0.25, 0.75, 1 },
    ["DEATHKNIGHT"] = { 0.25, 0.5, 0.75, 1 },
}

local function invertTextureCoords(texture)
    if not texture then return end
    local ULx, _, _, LLy, URx, URy = texture:GetTexCoord()
    texture:SetTexCoord(URx, ULx, URy, LLy)
end

local function isApproxEqual(a, b, epsilon)
    epsilon = epsilon or 0.0001
    return math.abs(a - b) < epsilon
end

local function keyPathExistsInTable(tbl, keyPath)
    local keys = {}
    local keyList = string.gmatch(keyPath, "[^%.]+")
    for key in keyList do
        table.insert(keys, key)
    end
    local current = tbl
    for _, key in ipairs(keys) do
        if type(current) ~= "table" or current[key] == nil then
            return false
        end
        current = current[key]
    end
    return current
end

local function tableMerge(table1, table2)
    if type(table2) == "boolean" or type(table2) == "string" or type(table2) == "number" then
        return table2
    else
        for key, value in pairs(table2) do
            table1[key] = value
        end
        return table1
    end
end

function NicerFrames:GetFrameLayout(frame)
    local layout = self.frameLayouts[self.db.profile.unitFrameStyle] or self.frameLayouts["default"]
    if frame.unit == "pet" and self.db.profile.alternativePet then
        layout = self.frameLayouts["FlippedPet"]
    end
    return layout[frame.unit]
end

function NicerFrames:UpdateFrames()
    local playerFrame = _G["PlayerFrameCustom"]
    local targetFrame = _G["TargetFrameCustom"]
    local petFrame = _G["PetFrameCustom"]
    local targetOfTarget = _G["TargetOfTargetFrameCustom"]

    local petExists = UnitExists("pet")
    if playerFrame then self:Layout(playerFrame) end
    if targetFrame then self:Layout(targetFrame) end
    if petFrame and petExists then self:Layout(petFrame) end
    if targetOfTarget then self:Layout(targetOfTarget) end
    NicerFrames:UpdateValues()
end

function NicerFrames:Layout(frame)
    local unitExists = UnitExists(frame.unit)
    if not unitExists then return end

    barTexture = LSM:Fetch("statusbar", self.db.profile.barTexture)

    self:LayoutFrameSize(frame)
    self:LayoutFromFileAndDatabase(frame)
    self:LayoutParentFrame(frame)
    self:LayoutTextureFrame(frame)
    self:LayoutPortrait(frame)
    self:LayoutNameBar(frame)
    self:LayoutHealthBar(frame)
    self:LayoutPowerBar(frame)
    self:LayoutPortraitBorder(frame)
    self:LayoutDebugBackground(frame)
    self:LayoutPlayerFrameBorder()
    self:LayoutRaidGroup()
    self:LayoutDruidBar()
    if frame.unit == "target" or frame.unit == "player" then
        self:LayoutIcons(frame)
    end
    if frame.unit == "target" then
        self:LayoutTarget(frame)
    end
    if frame.unit == "player" then
        self:LayoutPlayerIcons(frame)
    end
end

function NicerFrames:LayoutFrameSize(frame)
    local layout = self:GetFrameLayout(frame)
    frame:SetSize(unpack(layout.size))
    frame:SetScale(self.db.profile[frame.unit .. "FrameScale"])
    TargetFrame:SetScale(self.db.profile.targetFrameScale)
end

function NicerFrames:LayoutFromFileAndDatabase(frame2)
    local setters = {
        size = function(frame, value)
            frame:SetSize(unpack(value))
        end,
        scale = function(frame, value)
            frame:SetScale(value)
        end,
        coords = function(frame, value)
            frame:SetTexCoord(unpack(value))
        end,
        alpha = function(frame, value)
            frame:SetAlpha(value)
        end,
        path = function(frame, value)
            frame:SetTexture(value)
        end,
        color = function(frame, value)
            frame:SetVertexColor(unpack(value))
        end,
        barColor = function(frame, value)
            frame:SetStatusBarColor(unpack(value))
        end,
        strata = function(frame, value)
            frame:SetFrameStrata(value)
        end,
        frameLevel = function(frame, value)
            frame:SetFrameLevel(value)
        end,
        text = function(frame, value)
            if value.inherits then
                frame:SetFontObject(value.inherits)
            end
            local fontPath, _, fontFlags = frame:GetFont()
            if self.db.profile.fontFamily then
                fontPath = LSM:Fetch("font", self.db.profile.fontFamily)
            end
            frame:SetFont(fontPath, value.size or 12, value.outline or "OUTLINE")
            local color = value.color or { 1, 1, 1 }
            frame:SetVertexColor(unpack(color))

            frame:SetShadowOffset(0, 0)
            frame:SetShadowColor(0, 0, 0, 0)
        end,
        position = function(frame, value)
            local point = value.point or _G[frame:GetName()]:GetPoint()
            local relativePoint = value.relativePoint or value.point
            local relativeTo = _G[value.relativeTo] or frame:GetParent()

            local x = value.x or 0
            local y = value.y or 0
            frame:ClearAllPoints()
            frame:SetPoint(point, relativeTo, relativePoint, x, y)
        end,
        position2 = function(frame, value)
            local relativePoint = value.relativePoint or value.point
            local relativeTo = value.relativeTo or groupIndicatorParent
            local x = value.x or 0
            local y = value.y or 0
            frame:SetPoint(value.point, relativeTo, relativePoint, x, y)
        end,
        hidden = function(frame, value)
            if value == true then
                frame:Hide()
            elseif value == false then
                pcall(function() frame:Show() end)
            end
        end
    }

    local layout = self:GetFrameLayout(frame2)

    for childFrameName, childFrameProps in pairs(layout) do
        local childFrame = _G[frame2:GetName() .. childFrameName]
        if childFrame then
            if childFrameProps.hidden == nil then childFrameProps.hidden = "asdf" end
            for property, propertyData in pairs(childFrameProps) do
                local frameProperty = frame2.unit .. "." .. childFrameName .. "." .. property
                local databaseProperty = keyPathExistsInTable(self.db.profile.frameSettings, frameProperty)
                if databaseProperty then
                    propertyData = tableMerge(propertyData, databaseProperty)
                end
                if setters[property] then
                    setters[property](childFrame, propertyData)
                end
            end
        end
    end
end

function NicerFrames:LayoutParentFrame(frame)
    if frame.isMoving then return end
    local layout = self:GetFrameLayout(frame)

    local xOffOld = self.db.profile[frame.unit .. "X"] or layout.position.x
    local yOffOld = self.db.profile[frame.unit .. "Y"] or layout.position.y
    local relativeTo = _G[self.db.profile[frame.unit .. "RelativeTo"]] or _G[layout.position.relativeTo] or UIParent

    if not xOffOld then return end

    local scale = frame:GetScale() or 1

    local xOffs = xOffOld / scale
    local yOffs = yOffOld / scale

    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", relativeTo, "TOPLEFT", xOffs, yOffs)
end

function NicerFrames:LayoutTextureFrame(frame)
    local textureFrame = _G[frame:GetName() .. "TextureFrame"]
    if not textureFrame then return end
    local layout = self:GetFrameLayout(frame)

    local textureFrameTexture = _G[frame:GetName() .. "TextureFrameTexture"]
    if textureFrameTexture then
        local color = NicerFrames.db.profile.textureFrameColor
        textureFrameTexture:SetVertexColor(color.r, color.g, color.b, color.a)
    end

    -- NameText
    local nameText = _G[frame:GetName() .. "HealthBarNameText"]
    local unitIsAPlayer = UnitIsPlayer(frame.unit)
    if nameText then
        if self.db.profile.nameColor and unitIsAPlayer then
            local _, className = UnitClass(frame.unit)
            local colors = RAID_CLASS_COLORS[className]
            nameText:SetTextColor(colors.r, colors.g, colors.b)
        end
    end

    -- LevelText
    local levelText = _G[textureFrame:GetName() .. "LevelText"]
    if frame.unit == "pet" then
        levelText:Hide()
    end
    if frame.unit == "targettarget" then
        nameText:Hide()
        levelText:Hide()
    end
end

function NicerFrames:LayoutPortrait(frame)
    local portraitFrame = _G[frame:GetName() .. "Portrait"]
    if not portraitFrame then return end
    local layout = self:GetFrameLayout(frame)

    local _, className = UnitClass(frame.unit)
    local unitIsPlayer = UnitIsPlayer(frame.unit)
    local portraitTexture = _G[portraitFrame:GetName() .. "Texture"]
    local unitFrameStyle = self.db.profile.unitFrameStyle
    local portraitIconStyle = self.db.profile.portraitIconStyle
    if portraitIconStyle == "NormalIcons" and unitIsPlayer then
        local coords = CLASS_ICON_TCOORDS[className]
        portraitTexture:SetTexture("Interface\\TARGETINGFRAME\\UI-Classes-Circles")
        portraitTexture:SetTexCoord(unpack(coords))
        if frame.unit == "player" then
            portraitTexture:SetSize(64, 64)
            portraitTexture:ClearAllPoints()
            portraitTexture:SetPoint("TOPLEFT", -4, 2)
        elseif frame.unit == "target" then
            portraitTexture:SetSize(64, 64)
            portraitTexture:ClearAllPoints()
            portraitTexture:SetPoint("TOPLEFT", -1, 2)
        elseif frame.unit == "targettarget" then
            if self.db.profile.unitFrameStyle == "Thick" then
                portraitTexture:SetSize(31, 31)
                portraitTexture:ClearAllPoints()
                portraitTexture:SetPoint("TOPLEFT", -5, 2)
            else
                portraitTexture:SetSize(38, 38)
                portraitTexture:ClearAllPoints()
                portraitTexture:SetPoint("TOPLEFT", -3, 4)
            end
        end
    elseif portraitIconStyle == "Cartoon" and unitIsPlayer and unitFrameStyle == "ArenaLive" then
        portraitTexture:SetTexCoord(unpack(classTexCoords[className]))
        portraitTexture:SetTexture("Interface\\Addons\\NicerFrames\\Textures\\ClassIcons\\512-all-icons-square.blp")
    elseif portraitIconStyle == "Cartoon" and unitIsPlayer then
        portraitTexture:SetTexCoord(unpack(classTexCoords[className]))
        portraitTexture:SetTexture("Interface\\Addons\\NicerFrames\\Textures\\ClassIcons\\512-all-icons.blp")
    elseif portraitIconStyle == "Cartoon2" and unitIsPlayer then
        portraitTexture:SetTexCoord(0, 1, 0, 1)
        portraitTexture:SetTexture("Interface\\Addons\\NicerFrames\\Textures\\ClassIcons\\" .. className)
    else
        SetPortraitTexture(portraitTexture, frame.unit)
        portraitTexture:SetTexCoord(unpack(layout.PortraitTexture.coords))
    end
    if frame.unit == "target" and self.db.profile.invertTargetPortrait then
        invertTextureCoords(portraitTexture)
    end
end

function NicerFrames:LayoutNameBar(frame)
    local layout = self:GetFrameLayout(frame)
    local nameBar = _G[frame:GetName() .. "NameBar"]
    local backgroundTexture = _G[frame:GetName() .. "Background"]
    if not nameBar or not layout.NameBar then return end

    local nameBarTexture = _G[nameBar:GetName() .. "Texture"]
    if not nameBarTexture then return end
    local unitExists = UnitExists(frame.unit)
    local unitIsPlayer = UnitIsPlayer(frame.unit)
    if self.db.profile.playerNameBar.classColor and unitExists and unitIsPlayer and self.db.profile.unitFrameStyle == "Default" then
        local _, className = UnitClass(frame.unit)
        local colors = RAID_CLASS_COLORS[className]
        nameBarTexture:SetTexture(barTexture)
        nameBarTexture:SetVertexColor(colors.r, colors.g, colors.b, 1)
        nameBar:Show()
        backgroundTexture:Hide()
    elseif unitExists and frame.unit == "target" then
        local r, g, b, a = UnitSelectionColor(frame.unit)
        nameBarTexture:SetVertexColor(r, g, b, a)
        nameBarTexture:SetTexture(barTexture)
        nameBar:Show()
        backgroundTexture:Hide()
    end
end

function NicerFrames:LayoutHealthBar(frame)
    local healthBar = _G[frame:GetName() .. "HealthBar"]
    if not healthBar then return end
    local layout = self:GetFrameLayout(frame)
    healthBar:SetStatusBarTexture(barTexture)

    local healthBarBg = _G[healthBar:GetName() .. "Background"]
    if not healthBarBg then return end
    local unitExists = UnitExists(frame.unit)
    local unitIsPlayer = UnitIsPlayer(frame.unit)
    local isNpc = not unitIsPlayer and frame.unit == "target"
    if self.db.profile.healthClassColor and unitExists and unitIsPlayer then
        local _, className = UnitClass(frame.unit)
        local colors = RAID_CLASS_COLORS[className]
        healthBar:SetStatusBarColor(colors.r, colors.g, colors.b, 1)
    elseif self.db.profile.unitFrameStyle == "Thick" then
        local r, g, b, a = UnitSelectionColor(frame.unit)
        if isApproxEqual(r, 0) and isApproxEqual(g, 0) and isApproxEqual(b, 1) and isApproxEqual(a, 1) then
            r, g, b, a = 0, 0.99999779462814, 0, 0.99999779462814
        end
        healthBar:SetStatusBarColor(r, g, b, a)
    else
        local color = layout.HealthBarBackground.color
        healthBarBg:SetTexture(unpack(color))
        healthBarBg:SetVertexColor(0, 0, 0, 0.3)
        healthBarBg:SetVertexColor(unpack(color))
    end
end

function NicerFrames:LayoutPowerBar(frame)
    local layout = self:GetFrameLayout(frame)
    local powerBar = _G[frame:GetName() .. "PowerBar"]
    if not powerBar then return end
    powerBar:SetStatusBarTexture(barTexture)

    local powerBarBg = _G[powerBar:GetName() .. "Background"]
    local powerType = UnitPowerType(frame.unit)
    local powerColor = PowerBarColor[powerType]
    if powerColor then
        local color = layout.PowerBarBackground.color
        powerBar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b)
        powerBarBg:SetVertexColor(unpack(color))
    end

    -- local powerBar = _G[frame:GetName() .. "PowerBar"]
    local druidBarStatus = _G["PlayerFrameCustomDruidBarStatus"]
    if druidBarStatus then
        druidBarStatus:SetStatusBarTexture(barTexture)
    end
end

function NicerFrames:LayoutPortraitBorder(frame)
    local layout = self:GetFrameLayout(frame)
    local portraitBorder = _G[frame:GetName() .. "TextureFramePortraitBorderTexture"]
    if portraitBorder and layout.TextureFramePortraitBorderTexture then
        local unitExists = UnitExists(frame.unit)
        local unitIsPlayer = UnitIsPlayer(frame.unit)
        local isNpc = not unitIsPlayer and frame.unit == "target"
        if self.db.profile.portraitBorder then
            if unitExists and unitIsPlayer then
                local _, className = UnitClass(frame.unit)
                local colors = RAID_CLASS_COLORS[className]
                portraitBorder:SetVertexColor(colors.r, colors.g, colors.b)
                portraitBorder:Show()
            elseif isNpc then
                local threatLevel = UnitReaction("player", "target")
                if threatLevel == 1 or threatLevel == 2 or threatLevel == 3 then
                    portraitBorder:SetVertexColor(1, 0, 0)
                elseif threatLevel == 4 then
                    portraitBorder:SetVertexColor(1, 1, 0)
                elseif threatLevel == 5 or threatLevel == 6 or threatLevel == 7 or threatLevel == 8 then
                    portraitBorder:SetVertexColor(0, 1, 0)
                end
                portraitBorder:Show()
            end
        else
            portraitBorder:Hide()
        end
        if frame.unit == "pet" then portraitBorder:Hide() end
    end
end

function NicerFrames:LayoutDebugBackground(frame, layout)
    local debugBackground = select(2, frame:GetRegions())
    if debugBackground and self.db.profile.debugMode then
        debugBackground:Show()
    else
        debugBackground:Hide()
    end
end

function NicerFrames:LayoutPlayerFrameBorder()
    local layout = self.frameLayouts[self.db.profile.unitFrameStyle] or self.frameLayouts["default"]
    layout = layout.player
    local texture = _G["PlayerFrameCustomTextureFrameTexture"]
    if not (self.db.profile.unitFrameStyle == "Default" or self.db.profile.unitFrameStyle == "Thick") then return end
    if self.db.profile.frameBorder == "Rare" then
        texture:SetTexture(layout.TextureFrameTexture.options.rare)
    elseif self.db.profile.frameBorder == "Elite" then
        texture:SetTexture(layout.TextureFrameTexture.options.elite)
    elseif self.db.profile.frameBorder == "RareElite" then
        texture:SetTexture(layout.TextureFrameTexture.options.rareelite)
    else
        texture:SetTexture(layout.TextureFrameTexture.path)
    end
end

function NicerFrames:LayoutRaidGroup()
    local numRaidMembers = GetNumRaidMembers()
    if self.db.profile.debugMode then
        numRaidMembers = 40
    end
    if numRaidMembers == 0 then
        PlayerFrameCustomGroupIndicatorParent:Hide()
        return
    end

    for i = 1, MAX_RAID_MEMBERS do
        if i <= numRaidMembers then
            local name, _, subgroup = GetRaidRosterInfo(i)
            if self.db.profile.debugMode then
                subgroup = 3
                name = UnitName("player")
            end
            if name == UnitName("player") then
                local groupIndicatorParent = _G[PlayerFrameCustom:GetName() .. "GroupIndicatorParent"]
                local groupText = _G[groupIndicatorParent:GetName() .. "GroupIndicatorText"]
                groupText:SetText(GROUP .. " " .. subgroup)
                groupIndicatorParent:SetWidth(groupText:GetWidth() + 40)
                groupIndicatorParent:Show()
            end
        end
    end
end

function NicerFrames:LayoutDruidBar()
    local powerType = UnitPowerType("player")
    local druidBar = _G["PlayerFrameCustomDruidBar"]
    if self.db.profile.hideDruidBar or (powerType ~= 1 and powerType ~= 3) then
        druidBar:Hide()
        return
    end

    local druidBarLeft = _G["PlayerFrameCustomDruidBarParentLeft"]
    local druidBarRight = _G["PlayerFrameCustomDruidBarParentRight"]
    local druidBarMiddle = _G["PlayerFrameCustomDruidBarParentMiddle"]

    if not druidBarLeft or not druidBarRight or not druidBarMiddle then return end

    local color = NicerFrames.db.profile.textureFrameColor
    druidBarLeft:SetVertexColor(color.r, color.g, color.b, color.a)
    druidBarRight:SetVertexColor(color.r, color.g, color.b, color.a)
    druidBarMiddle:SetVertexColor(color.r, color.g, color.b, color.a)
    druidBar:Show()
end

function NicerFrames:LayoutIcons(frame)
    if frame == nil then return end

    local leaderIcon = _G[frame:GetName() .. "TextureFrameLeaderIcon"]
    local masterLootIcon = _G[frame:GetName() .. "TextureFrameMasterIcon"]

    local isPlayerLeader = IsPartyLeader()
    if self.db.profile.debugMode then
        isPlayerLeader = true
    end
    if isPlayerLeader then
        if HasLFGRestrictions() then
            leaderIcon:Hide()
            -- PlayerGuideIcon:Show()
        else
            leaderIcon:Show()
            -- PlayerGuideIcon:Hide()
        end
    else
        leaderIcon:Hide();
        -- PlayerGuideIcon:Hide()
    end

    local _, lootMaster = GetLootMethod()
    local partyMembers = GetNumPartyMembers()
    local raidMembers = GetNumRaidMembers()
    if self.db.profile.debugMode then
        lootMaster = 0
        partyMembers = 5
        raidMembers = 10
    end
    if (lootMaster == 0 and (partyMembers > 0 or raidMembers > 0)) then
        masterLootIcon:Show()
    else
        masterLootIcon:Hide()
    end

    local factionGroup, factionName = UnitFactionGroup("player")
    local PvPIcon = _G[frame:GetName() .. "TextureFramePVPIcon"]
    local isPvPFreeForAll = UnitIsPVPFreeForAll(frame.unit)
    local isPvP = UnitIsPVP(frame.unit)
    if self.db.profile.debugMode then
        isPvP = true
    end
    if isPvPFreeForAll then
        PvPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
        PvPIcon:Show()
    elseif factionGroup and isPvP then
        PvPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-" .. factionGroup)
        PvPIcon:Show()
    else
        PvPIcon:Hide()
    end
end

function NicerFrames:LayoutTarget(frame)
    if frame == nil then return end
    local layout = self:GetFrameLayout(frame)
    if not layout.TextureFrameTexture.classifications or not layout.TextureFrameTexture.classifications.elite then
        return
    end
    local texture
    local classification = UnitClassification(frame.unit)
    if self.db.profile.debugMode then
        classification = "rare"
    end
    if (classification == "worldboss" or classification == "elite") then
        texture = layout.TextureFrameTexture.classifications.elite
    elseif classification == "rareelite" then
        texture = layout.TextureFrameTexture.classifications.rareelite
    elseif classification == "rare" then
        texture = layout.TextureFrameTexture.classifications.rare
    end
    if texture then
        TargetFrameCustomTextureFrameTexture:SetTexture(texture)
    end

    local levelText = _G[frame:GetName() .. "TextureFrameLevelText"]
    local level = UnitLevel(frame.unit)
    local bossSkull = _G[frame:GetName() .. "TextureFrameBossSkull"]
    if (level == 0) and frame.unit == "target" then
        bossSkull:Show()
        levelText:Hide()
    else
        bossSkull:Hide()
        levelText:Show()
    end
end

function NicerFrames:LayoutPlayerIcons(frame)
    if frame == nil then return end

    local layout = self:GetFrameLayout(frame)
    local restIcon = _G[frame:GetName() .. "TextureFrameRestIcon"]
    local combatIcon = _G[frame:GetName() .. "TextureFrameCombatIcon"]
    local levelText = _G[frame:GetName() .. "TextureFrameLevelText"]
    local status2 = _G[frame:GetName() .. "TextureFrameStatusTexture"]
    local restGlow = _G[frame:GetName() .. "TextureFrameRestGlow"]

    if IsResting() then
        restIcon:Show()
        levelText:Hide()
        combatIcon:Hide()
        if not self.db.profile.hideRestGlow then
            status2:Show()
            restGlow:Show()
        end
    elseif (PlayerFrameCustom.isCombat) then
        combatIcon:Show()
        restIcon:Hide()
        levelText:Hide()
        status2:Hide()
        restGlow:Hide()
    else
        combatIcon:Hide()
        restIcon:Hide()
        levelText:Show()
        status2:Hide()
        restGlow:Hide()
    end

    local index = GetRaidTargetIndex("target")
    local raidTargetIcon = TargetFrameCustomTextureFrameRaidTargetIcon
    if index and frame.unit == "target" then
        SetRaidTargetIconTexture(raidTargetIcon, index)
        raidTargetIcon:Show()
    else
        raidTargetIcon:Hide()
    end
end

local LSM = LibStub("LibSharedMedia-3.0")
local frames = {}
local barTexture, dropDown

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

function NicerFrames:UpdateLevel()
    for _, frame in pairs(frames) do
        local levelText = _G[frame:GetName() .. "TextureFrameLevelText"]
        if levelText then
            local level = UnitLevel(frame.unit)
            local color = GetQuestDifficultyColor(level)
            levelText:SetText(level)
            if color.r == 1 and color.g == 1 and color.b == 0 and color.a == nil then
                levelText:SetTextColor(0.99999780301005, 0.81960606575012, 0, 0.99999779462814)
            else
                levelText:SetTextColor(color.r, color.g, color.b, color.a)
            end

            local fontPath, _, fontFlags = levelText:GetFont()
            levelText:SetFont(fontPath, 11, fontFlags);
        end
    end
end

function NicerFrames:UpdatePlayerFrameBorder()
    local frame = PlayerFrameCustom
    local layout = self.frameLayouts[self.db.profile.unitFrameStyle] or self.frameLayouts["default"]
    local texture = _G[frame:GetName() .. "TextureFrameTexture"]
    if self.db.profile.unitFrameStyle ~= "Default" then return end
    if self.db.profile.frameBorder == "Rare" then
        texture:SetTexture(layout.player.TextureFrame.options.rare)
    elseif self.db.profile.frameBorder == "Elite" then
        texture:SetTexture(layout.player.TextureFrame.options.elite)
    elseif self.db.profile.frameBorder == "RareElite" then
        texture:SetTexture(layout.player.TextureFrame.options.rareElite)
    else
        texture:SetTexture(layout.player.TextureFrameTexture.path)
    end
end

function NicerFrames:ToggleTextVisibility(frame)
    local textTypes = { "Health", "Power" }
    for _, textType in ipairs(textTypes) do
        local UnitTextType, UnitMaxTextType, resourceFormat
        if textType == "Health" then
            UnitTextType = UnitHealth
            UnitMaxTextType = UnitHealthMax
            resourceFormat = self.db.profile.healthFormat
        elseif textType == "Power" then
            UnitTextType = UnitPower
            UnitMaxTextType = UnitPowerMax
            local powerType = UnitPowerType(frame.unit)
            if powerType == 1 or powerType == 2 or powerType == 3 or powerType == 6 then
                resourceFormat = self.db.profile.energyFormat
            else
                resourceFormat = self.db.profile.manaFormat
            end
        end
        local resource = UnitTextType(frame.unit)
        local maxResourceNumber = UnitMaxTextType(frame.unit)
        local resourceBar = _G[frame:GetName() .. textType .. "Bar"]
        local resourceText = _G[resourceBar:GetName() .. "Text"]
        resourceText:SetText(self:FormatResourceText(resourceFormat, resource, maxResourceNumber))
        local isMaxHealth = resource == maxResourceNumber
        if resourceBar:IsMouseOver() or self.db.profile.alwaysShowStatusText and not (self.db.profile.hideFullStatusTexts and isMaxHealth) then
            resourceText:Show()
        else
            resourceText:Hide()
        end
    end
end

function NicerFrames:UpdateHealthAndPower()
    for _, frame in pairs(frames) do
        local healthBar = _G[frame:GetName() .. "HealthBar"]
        local powerBar = _G[frame:GetName() .. "PowerBar"]
        local healthText = _G[healthBar:GetName() .. "Text"]
        local powerText = _G[powerBar:GetName() .. "Text"]

        local health = UnitHealth(frame.unit)
        local maxHealth = UnitHealthMax(frame.unit)
        healthBar:SetMinMaxValues(0, maxHealth)
        healthBar:SetValue(health)


        local power = UnitPower(frame.unit)
        local maxPower = UnitPowerMax(frame.unit)
        powerBar:SetMinMaxValues(0, maxPower)
        powerBar:SetValue(power)

        if healthText then
            healthText:SetText(self:FormatResourceText(self.db.profile.healthFormat, health, maxHealth))
        end

        if powerText then
            powerText:SetText(self:FormatResourceText(NicerFrames.db.profile.manaFormat, power, maxPower))
        end
        self:ToggleTextVisibility(frame)
    end
end

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
end

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

local function invertTextureCoords(texture)
    if not texture then return end
    local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = texture:GetTexCoord()
    texture:SetTexCoord(URx, ULx, URy, LLy)
    local newULx, newULy, newLLx, newLLy, newURx, newURy, newLRx, newLRy = texture:GetTexCoord()
end

function NicerFrames:LayoutPortrait(frame)
    local portraitFrame = _G[frame:GetName() .. "Portrait"]
    if not portraitFrame then return end
    local layout = self.frameLayouts[self.db.profile.unitFrameStyle] or self.frameLayouts["default"]
    layout = layout[frame.unit]

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
    if frame.unit == "target" then
        invertTextureCoords(portraitTexture)
    end
    -- if frame.unit == "pet" then
    --     portraitFrame:SetFrameLevel(10)
    -- end
end

function NicerFrames:LayoutNameBar(frame)
    local layout = self.frameLayouts[self.db.profile.unitFrameStyle] or self.frameLayouts["default"]
    layout = layout[frame.unit]
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
    local layout = self.frameLayouts[self.db.profile.unitFrameStyle] or self.frameLayouts["default"]
    layout = layout[frame.unit]
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
    else
        local color = layout.HealthBarBackground.color
        healthBarBg:SetTexture(1, 1, 1, 1)
        healthBarBg:SetVertexColor(0, 0, 0, 0.3)
    end
end

function NicerFrames:LayoutPowerBar(frame)
    local layout = self.frameLayouts[self.db.profile.unitFrameStyle] or self.frameLayouts["default"]
    layout = layout[frame.unit]
    local powerBar = _G[frame:GetName() .. "PowerBar"]
    if not powerBar then return end
    powerBar:SetStatusBarTexture(barTexture)

    local powerBarBg = _G[powerBar:GetName() .. "Background"]
    local powerType = UnitPowerType(frame.unit)
    local powerColor = PowerBarColor[powerType]
    if powerColor then
        powerBar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b)
        powerBarBg:SetVertexColor(0, 0, 0, 0.3)
    end
end

function NicerFrames:LayoutPortraitBorder(frame)
    local layout = self.frameLayouts[self.db.profile.unitFrameStyle] or self.frameLayouts["default"]
    layout = layout[frame.unit]
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

function NicerFrames:LayoutTextureFrame(frame)
    local textureFrame = _G[frame:GetName() .. "TextureFrame"]
    if not textureFrame then return end
    local layout = self.frameLayouts[self.db.profile.unitFrameStyle] or self.frameLayouts["default"]
    layout = layout[frame.unit]

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

function NicerFrames:LayoutDebugBackground(frame, layout)
    local debugBackground = select(2, frame:GetRegions())
    if debugBackground and self.db.profile.debugMode then
        debugBackground:Show()
    else
        debugBackground:Hide()
    end
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
    self:LayoutPowerBar(frame)
    self:LayoutHealthBar(frame)
    self:LayoutPortraitBorder(frame)
    self:LayoutDebugBackground(frame)
    self:UpdatePlayerFrameBorder()
    if frame.unit == "player" then
        self:LayoutIcons(frame)
    end
end

function NicerFrames:LayoutFrameSize(frame)
    local layout = self.frameLayouts[self.db.profile.unitFrameStyle] or self.frameLayouts["default"]
    layout = layout[frame.unit]
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
            local relativeTo = value.relativeTo or frame:GetParent()
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

    local layout = self.frameLayouts[self.db.profile.unitFrameStyle] or self.frameLayouts["default"]
    layout = layout[frame2.unit]

    for childFrameName, childFrameProps in pairs(layout) do
        local childFrame = _G[frame2:GetName() .. childFrameName]
        if childFrame then
            if childFrameProps.hidden == nil then childFrameProps.hidden = "asdf" end
            for property, propertyData in pairs(childFrameProps) do
                local frameProperty = frame2.unit .. "." .. childFrameName .. "." .. property
                local databaseProperty = keyPathExistsInTable(self.db.profile.frameSettings, frameProperty)
                if databaseProperty then
                    propertyData = self:tableMerge(propertyData, databaseProperty)
                end
                if setters[property] then
                    setters[property](childFrame, propertyData)
                end
            end
        end
    end
end

function NicerFrames:TableToString(tbl, indent)
    if not tbl then return "nil" end
    if type(tbl) ~= "table" then return tostring(tbl) end

    indent = indent or 0
    local spaces = string.rep("    ", indent)
    local output = "{\n"

    local keys = {}
    for k in pairs(tbl) do
        table.insert(keys, k)
    end
    table.sort(keys, function(a, b)
        return tostring(a) < tostring(b)
    end)

    for i, key in ipairs(keys) do
        local value = tbl[key]
        local valueStr

        local keyStr = type(key) == "number" and "[" .. key .. "]" or "\"" .. tostring(key) .. "\""

        if type(value) == "table" then
            valueStr = self:TableToString(value, indent + 1)
        elseif type(value) == "string" then
            valueStr = "\"" .. value .. "\""
        else
            valueStr = tostring(value)
        end

        output = output .. spaces .. "    " .. keyStr .. ": " .. valueStr

        if i < #keys then
            output = output .. ","
        end
        output = output .. "\n"
    end

    output = output .. spaces .. "}"
    return output
end

function NicerFrames:PrintAsJson(value)
    if type(value) == "table" then
        self:Print(self:TableToString(value))
    else
        self:Print(tostring(value))
    end
end

function NicerFrames:tableMerge(table1, table2)
    if type(table2) == "boolean" or type(table2) == "string" or type(table2) == "number" then
        return table2
    else
        for key, value in pairs(table2) do
            table1[key] = value
        end
        return table1
    end
end

function NicerFrames:LayoutIcons(frame)
    if frame == nil then return end

    local layout = self.frameLayouts[self.db.profile.unitFrameStyle] or self.frameLayouts["default"]
    layout = layout[frame.unit]
    local restIcon = _G[frame:GetName() .. "TextureFrameRestIcon"]
    local combatIcon = _G[frame:GetName() .. "TextureFrameCombatIcon"]
    local levelText = _G[frame:GetName() .. "TextureFrameLevelText"]
    local leaderIcon = _G[frame:GetName() .. "TextureFrameLeaderIcon"]
    local masterLootIcon = _G[frame:GetName() .. "TextureFrameMasterIcon"]
    local status2 = _G[frame:GetName() .. "TextureFrameStatusTexture"]
    local restGlow = _G[frame:GetName() .. "TextureFrameRestGlow"]

    if IsResting() then
        restIcon:Show()
        levelText:Hide()
        combatIcon:Hide()
        status2:Show()
        restGlow:Show()
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

    local isPlayerLeader = IsPartyLeader()
    if self.db.profile.debugMode then
        isPlayerLeader = true
    end
    if isPlayerLeader then
        if HasLFGRestrictions() then
            leaderIcon:Hide();
            -- PlayerGuideIcon:Show();
        else
            leaderIcon:Show()
            -- PlayerGuideIcon:Hide();
        end
    else
        leaderIcon:Hide();
        -- PlayerGuideIcon:Hide();
    end

    local _, lootMaster = GetLootMethod();
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
        masterLootIcon:Hide();
    end

    local factionGroup, factionName = UnitFactionGroup("player");
    local PvPIcon = _G[frame:GetName() .. "TextureFramePVPIcon"]
    if (UnitIsPVPFreeForAll("player")) then
        PvPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
        PvPIcon:Show()
    elseif factionGroup and not UnitIsPVP("player") then
        PvPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-" .. factionGroup);
        PvPIcon:Show()
    else
        PvPIcon:Hide()
    end

    local groupIndicatorParent = _G[frame:GetName() .. "GroupIndicatorParent"]
    if self.db.profile.debugMode then
        PlayerFrameCustomGroupIndicatorParentGroupIndicatorText:SetText(GROUP .. " " .. "8")
        groupIndicatorParent:SetWidth(PlayerFrameCustomGroupIndicatorParentGroupIndicatorText:GetWidth() + 40);
        groupIndicatorParent:Show()
    else
        groupIndicatorParent:Hide()
    end

    local index = GetRaidTargetIndex("target");
    local raidTargetIcon = TargetFrameCustomTextureFrameRaidTargetIcon
    if index and frame.unit == "target" then
        SetRaidTargetIconTexture(raidTargetIcon, index)
        raidTargetIcon:Show()
    else
        raidTargetIcon:Hide()
    end
end

function NicerFrames:UpdateTextureFrameColor()
    for _, frame in pairs(frames) do
        local textureFrame = _G[frame:GetName() .. "TextureFrameTexture"]
        if textureFrame then
            local color = NicerFrames.db.profile.textureFrameColor
            textureFrame:SetVertexColor(color.r, color.g, color.b, color.a)
        end
    end
end

function NicerFrames:CustomReadableNumber(num, format, useFullValues)
    if not num then
        return 0
    elseif num >= 1000000000 then -- billion
        return string.format(format["gt1B"], num / (useFullValues or 1000000000))
    elseif num >= 100000000 then  -- hundred million
        return string.format(format["gt100M"], num / (useFullValues or 1000000))
    elseif num >= 10000000 then   -- ten million
        return string.format(format["gt10M"], num / (useFullValues or 1000000))
    elseif num >= 1000000 then    -- million
        return string.format(format["gt1M"], num / (useFullValues or 1000000))
    elseif num >= 100000 then     -- hundred thousand
        return string.format(format["gt100T"], num / (useFullValues or 1000))
    elseif num >= 1000 then       -- thousand
        return string.format(format["gt1T"], num / (useFullValues or 1000))
    end
    return num -- hundreds
end

local numberFormat = {
    ["gt1B"] = "%.1fB",   -- 1.2B
    ["gt100M"] = "%.0fM", -- 123M
    ["gt10M"] = "%.1fM",  -- 12.3M
    ["gt1M"] = "%.2fM",   -- 1.23M
    ["gt100T"] = "%.1fK", -- 123.4K
    ["gt1T"] = "%.1fK",   -- 12.3K
}

function NicerFrames:FormatResourceText(targetFormat, current, max)
    if not current or not max then return "" end

    local percent = max > 0 and floor((current / max) * 100) or 0
    local text = targetFormat
    text = text:gsub("!CURR", self:CustomReadableNumber(current, numberFormat))
    text = text:gsub("!MAX", self:CustomReadableNumber(max, numberFormat))
    text = text:gsub("!PERC", percent)

    return text
end

function NicerFrames:UpdateFrame()
    local playerFrame = _G["PlayerFrameCustom"]
    local targetFrame = _G["TargetFrameCustom"]
    local petFrame = _G["PetFrameCustom"]
    local targetOfTarget = _G["TargetOfTargetFrameCustom"]

    local petExists = UnitExists("pet")
    if playerFrame then self:Layout(playerFrame, self.db.profile.unitFrameStyle) end
    if targetFrame then self:Layout(targetFrame, "default") end
    if petFrame and petExists then self:Layout(petFrame, "default") end
    if targetOfTarget then self:Layout(targetOfTarget, self.db.profile.unitFrameStyle) end
    NicerFrames:UpdateValues()
end

function NicerFrames:CreateDropDown()
    dropDown = CreateFrame("Frame", "PlayerFrameCustomDropDown", PlayerFrameCustom, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(dropDown, function(self2)
        if UnitIsUnit("player", "player") then
            UnitPopup_ShowMenu(self2, "SELF", "player");
        end
    end, "MENU")
end

function NicerFrames:SaveFramePosition(frame)
    local scale = frame:GetScale() or 1
    local left = frame:GetLeft() * scale
    local top = frame:GetTop() * scale

    local xOfs = left
    local yOfs = -(UIParent:GetHeight() - top)

    self.db.profile[frame.unit .. "X"] = xOfs
    self.db.profile[frame.unit .. "Y"] = yOfs

    if self.db.profile.centerFrames and frame.unit == "player" then
        self:MirrorPlayerPosition(PlayerFrameCustom, TargetFrameCustom)
    end
end

function NicerFrames:LayoutParentFrame(frame)
    if frame.isMoving then return end
    local layout = self.frameLayouts[self.db.profile.unitFrameStyle] or self.frameLayouts["default"]
    layout = layout[frame.unit]
    local xOffOld = self.db.profile[frame.unit .. "X"] or layout.position.x
    local yOffOld = self.db.profile[frame.unit .. "Y"] or layout.position.y
    if not xOffOld then return end

    local scale = frame:GetScale() or 1

    local xOffs = xOffOld / scale
    local yOffs = yOffOld / scale

    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xOffs, yOffs)
end

function NicerFrames:MirrorPlayerPosition(playerFrame, targetFrame)
    local screenWidth = UIParent:GetWidth()
    local frameWidth = 185

    local playerScale = playerFrame:GetScale() or 1
    local targetScale = targetFrame:GetScale() or 1

    local playerLeft = (playerFrame:GetLeft() * playerScale)
    local playerTop = (playerFrame:GetTop() * playerScale)

    local playerFrameWidth = frameWidth * playerScale

    local targetLeft = screenWidth - playerLeft - playerFrameWidth

    local xOfs = targetLeft
    local yOfs = -(UIParent:GetHeight() - playerTop)

    self.db.profile[targetFrame.unit .. "X"] = xOfs
    self.db.profile[targetFrame.unit .. "Y"] = yOfs

    targetFrame:ClearAllPoints()
    targetFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xOfs / targetScale, yOfs / targetScale)
end

function PlayerFrameCustom_OnClick(self, button)
    if self.unit == "player" then
        if button == "RightButton" then
            ToggleDropDownMenu(1, nil, PlayerFrameDropDown, "cursor")
        end
    elseif self.unit == "target" then
        if button == "RightButton" then
            ToggleDropDownMenu(1, nil, TargetFrameDropDown, "cursor")
        end
    elseif self.unit == "pet" then
        if button == "RightButton" then
            ToggleDropDownMenu(1, nil, PetFrameDropDown, "cursor")
        end
    end
end

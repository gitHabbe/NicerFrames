local dropDown
local UnitIsConnected = UnitIsConnected
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local floor = floor
local UnitHealth = UnitHealth
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local CreateFrame = CreateFrame
local UIDropDownMenu_Initialize = UIDropDownMenu_Initialize
local UnitIsUnit = UnitIsUnit
local UnitPopup_ShowMenu = UnitPopup_ShowMenu
local UIParent = UIParent
local ToggleDropDownMenu = ToggleDropDownMenu
local PlayerFrameDropDown = PlayerFrameDropDown
local TargetFrameDropDown = TargetFrameDropDown
local PetFrameDropDown = PetFrameDropDown
local frames = {}

function NicerFrames:ToggleTextVisibility(frame)
    local textTypes = { "Health", "Power" }
    for _, textType in ipairs(textTypes) do
        local UnitTextType, UnitTextTypeMax, resourceFormat
        if textType == "Health" then
            UnitTextType = UnitHealth
            UnitTextTypeMax = UnitHealthMax
            resourceFormat = self.db.profile.healthFormat
        elseif textType == "Power" then
            UnitTextType = UnitPower
            UnitTextTypeMax = UnitPowerMax
            local powerType = UnitPowerType(frame.unit)
            if powerType == 1 or powerType == 2 or powerType == 3 or powerType == 6 then
                resourceFormat = self.db.profile.energyFormat
            else
                resourceFormat = self.db.profile.manaFormat
            end
        end
        local resourceValue = UnitTextType(frame.unit)
        local maxResourceValue = UnitTextTypeMax(frame.unit)
        local resourceBar = _G[frame:GetName() .. textType .. "Bar"]
        local resourceText = _G[resourceBar:GetName() .. "Text"]
        resourceText:SetText(self:FormatResourceText(resourceFormat, resourceValue, maxResourceValue))
        local isMaxResource = resourceValue == maxResourceValue
        if resourceBar:IsMouseOver() or self.db.profile.alwaysShowStatusText and not (self.db.profile.hideFullStatusTexts and isMaxResource) then
            resourceText:Show()
        else
            resourceText:Hide()
        end
        if textType == "Health" and resourceValue <= 0 and UnitIsConnected(frame.unit) then
            resourceText:SetText("DEAD")
        end
    end
    if frame.unit == "player" then
        local resourceBar = _G["PlayerFrameCustomDruidBarStatus"]
        local resourceText = _G["PlayerFrameCustomDruidBarStatusText"]
        local resourceType = UnitPowerMax(frame.unit, 0)
        local maxResourceType = UnitPower(frame.unit, 0)
        local isMaxResource = resourceType == maxResourceType
        if resourceBar.mouseOverlay:IsMouseOver() or self.db.profile.alwaysShowStatusText and not (self.db.profile.hideFullStatusTexts and isMaxResource) then
            resourceText:Show()
        else
            resourceText:Hide()
        end
    end
end

function NicerFrames:UpdateTextureFrameColor()
    if #frames < 1 then
        frames = {
            PlayerFrameCustom = PlayerFrameCustom,
            TargetFrameCustom = TargetFrameCustom,
            PetFrameCustom = PetFrameCustom,
            TargetOfTargetFrameCustom = TargetOfTargetFrameCustom,
        }
    end
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
function NicerFrames:CreateDropDown()
    dropDown = CreateFrame("Frame", "PlayerFrameCustomDropDown", PlayerFrameCustom, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(dropDown, function(self2)
        if UnitIsUnit("player", "player") then
            UnitPopup_ShowMenu(self2, "SELF", "player")
        end
    end, "MENU")
end

function NicerFrames:SaveFramePosition(frame)
    local layout = self:GetFrameLayout(frame)
    local parentFrame
    if frame.unit == "targettarget" or frame.unit == "pet" then
        parentFrame = _G[layout.position.relativeTo]
    end

    local scale = frame:GetScale() or 1

    local oldRelativeTo = parentFrame or UIParent
    local relativeToScale = oldRelativeTo:GetScale() or 1

    local left = frame:GetLeft() * scale
    local top = frame:GetTop() * scale

    if parentFrame then
        local parentLeft = parentFrame:GetLeft() * relativeToScale
        local parentTop = parentFrame:GetTop() * relativeToScale

        local xOfs = left - parentLeft
        local yOfs = top - parentTop

        self.db.profile[frame.unit .. "X"] = xOfs
        self.db.profile[frame.unit .. "Y"] = yOfs
        self.db.profile[frame.unit .. "RelativeTo"] = parentFrame:GetName()
    else
        local xOfs = left
        local yOfs = -(UIParent:GetHeight() - top)

        self.db.profile[frame.unit .. "X"] = xOfs
        self.db.profile[frame.unit .. "Y"] = yOfs
    end

    if self.db.profile.centerFrames and frame.unit == "player" then
        self:MirrorPlayerPosition(PlayerFrameCustom, TargetFrameCustom)
    end
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

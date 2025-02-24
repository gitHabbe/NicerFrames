local frameLayouts = {}
NicerFrames.frameLayouts = {}
NicerFrames.frameLayouts["default"] = {}
NicerFrames.frameLayouts["default"]["player"] = {
    attributes = {
        movable = true,
        enableMouse = true,
        inherits = "SecureUnitButtonTemplate"
    },
    -- Main frame
    size = { 185, 50 },
    position = {
        point = "TOPLEFT",
        relativeTo = "UIParent",
        relativePoint = "TOPLEFT",
        x = -19,
        y = -4,
    },
    -- Background texture
    Background = {
        size = { 119, 18 },
        position = { point = "TOP", x = 28, y = -1 },
        color = { 1, 0, 0, 0.5 }
    },
    -- Portrait
    Portrait = {
        size = { 60, 60 },
        position = { point = "TOPLEFT", x = -3, y = 8 },
        strata = "LOW",
    },
    PortraitTexture = {
        size = { 60, 60 },
        position = { point = "TOPLEFT", x = 1, y = -1 },
        coords = { 0, 1, 0, 1 }
    },
    ReadyCheck = {
        size = { 40, 40 },
        strata = "LOW",
        frameLevel = 3,
        position = {
            point = "CENTER",
            x = 0,
            y = 0,
        },
    },
    -- Name bar
    NameBar = {
        size = { 119, 16 },
        position = { point = "TOPLEFT", x = 61, y = -1 },
    },
    NameBarTexture = {
        path = "Interface\\TargetingFrame\\UI-StatusBar",
        color = { 1, 0, 0, 1 }
    },
    -- Health bar
    HealthBar = {
        strata = "MEDIUM",
        size = { 119, 12 },
        position = { point = "TOPLEFT", x = 61, y = -18 },
        barColor = { 0, 1, 0 },
    },
    HealthBarTexture = {
        path = "Interface\\TargetingFrame\\UI-StatusBar"
    },
    HealthBarBackground = {
        color = { 0, 0, 0, 0.5 },
        position = {
            point = "TOPLEFT",
            relativeTo = "PlayerFrameCustomHealthBar",
            relativePoint = "TOPLEFT"
        },
        position2 = {
            point = "BOTTOMRIGHT",
            relativeTo = "PlayerFrameCustomHealthBar",
            relativePoint = "BOTTOMRIGHT"
        },
    },
    HealthBarNameText = {
        text = {
            size = 9,
            font = "GameFontNormalSmall",
            color = { 0.99999780301005, 0.81960606575012, 0, 0.99999779462814 },
        },
        position = {
            x = 0,
            y = 13,
            point = "TOP",
            relativePoint = "TOP"
        }
    },
    HealthBarText = {
        text = {
            inherits = "TextStatusBarText",
            size = 9,
        },
        position = {
            point = "CENTER",
            relativePoint = "TOP",
            x = 0,
            y = -6
        }
    },
    -- Power bar
    PowerBar = {
        size = { 119, 12 },
        position = {
            point = "TOPLEFT", x = 61, y = -29 },
    },
    PowerBarTexture = {
        path = "Interface\\TargetingFrame\\UI-StatusBar"
    },
    PowerBarBackground = {
        color = { 0, 0, 0, 0.5 }
    },
    PowerBarText = {
        text = {
            size = 9,
            inherts = "TextStatusBarText",
        },
        position = {
            point = "CENTER",
            relativePoint = "TOP",
            x = 0,
            y = -6
        }
    },
    -- Texture Frame
    TextureFrame = {
        size = { 185, 50 },
        position = { point = "CENTER", x = 0, y = 0 },
        options = {
            rare = "Interface\\TargetingFrame\\UI-TargetingFrame-Rare",
            elite = "Interface\\TargetingFrame\\UI-TargetingFrame-Elite",
            rareElite = "Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite",
        }
    },
    TextureFrameTexture = {
        path = "Interface\\TargetingFrame\\UI-TargetingFrame",
        coords = { 1, 0, 0, 1 },
        position = { point = "TOPLEFT", x = -47, y = 23 },
    },
    -- Portrait border texture
    TextureFramePortraitBorderTexture = {
        path = "Interface\\AddOns\\NicerFrames\\Textures\\UnitFrames\\Class-Circle-Cutout",
        size = { 63, 63 },
        coords = { 1, 0, 0, 1 },
        position = { point = "TOPLEFT", x = -5, y = 10 },
        color = { 1, 1, 0 }
    },
    -- Level Text
    TextureFrameLevelText = {
        font = "GameFontNormalSmall",
        position = { point = "CENTER", x = -86, y = -19 }
    },
    -- Master Looter Icon
    TextureFrameMasterIcon = {
        path = "Interface\\GroupFrame\\UI-Group-MasterLooter",
        size = { 13, 13 },
        position = {
            x = 10,
            y = 14,
            point = "TOPLEFT",
            relativePoint = "TOPLEFT"
        }
    },
    -- Leader Icon
    TextureFrameLeaderIcon = {
        path = "Interface\\GroupFrame\\UI-Group-LeaderIcon",
        size = { 16, 16 },
        position = {
            x = -2,
            y = 15,
            point = "TOPLEFT",
            relativePoint = "TOPLEFT"
        }
    },
    -- Rest Icon
    TextureFrameRestIcon = {
        path = "Interface\\CharacterFrame\\UI-StateIcon",
        size = { 32, 32 },
        coords = { 0, 0.5, 0, 0.421875 },
        position = {
            x = -11,
            y = -26,
            point = "TOPLEFT",
            relativePoint = "TOPLEFT"
        },
    },
    -- Combat Icon
    TextureFrameCombatIcon = {
        path = "Interface\\CharacterFrame\\UI-StateIcon",
        size = { 24, 24 },
        coords = { 0.5, 1.0, 0, 0.5 },
        position = {
            x = -5,
            y = -31,
            point = "TOPLEFT",
            relativePoint = "TOPLEFT"
        },
    },
    -- Hit Indicator
    TextureFrameHitIndicator = {
        position = {
            x = -64,
            y = 4,
            point = "CENTER",
            -- relativeTo = "$parent",
            relativePoint = "CENTER"
        },
    },
    -- PVP Icon
    TextureFramePVPIcon = {
        path = "Interface\\TargetingFrame\\UI-PVP-FFA",
        size = { 50, 50 },
        position = {
            x = -22,
            y = -3,
            point = "TOPLEFT",
            relativePoint = "TOPLEFT"
        }
    },
    TextureFrameStatusTexture = {
        path = "Interface\\CharacterFrame\\UI-Player-Status",
        size = { 193, 68 },
        coords = { 0, 0.74609375, 0, 0.53125 },
        color = { 1, 1, 0 },
        position = {
            point = "TOPLEFT",
            x = -12,
            y = 15
        },
    },
    TextureFrameRestGlow = {
        path = "Interface\\CharacterFrame\\UI-StateIcon",
        size = { 32, 32 },
        coords = { 0, 0.5, 0.5, 1.0 },
        color = { 1, 1, 0 },
        position = {
            point = "TOPLEFT",
            x = -11,
            y = -29,
        },
    },
    GroupIndicatorParent = {
        scale = 0.8,
        size = { 10, 16 },
        position = {
            point = "TOPLEFT",
            x = 50,
            y = 18
        },
    },
    GroupIndicatorParentGroupIndicatorText = {
        inherits = "GameFontHighlightSmall",
        size = { 42, 40 },
        text = {
            size = 8
        },
        position = {
            point = "CENTER",
            x = 1,
            y = -2,
        },
        alpha = 0.7
    },
    GroupIndicatorParentGroupIndicatorLeft = {
        path = "Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator",
        size = { 24, 16 },
        position = {
            point = "TOPLEFT"
        },
        coords = { 0, 0.1675, 0, 1 },
        alpha = 0.3
    },
    GroupIndicatorParentGroupIndicatorRight = {
        path = "Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator",
        size = { 24, 16 },
        position = {
            point = "TOPRIGHT"
        },
        coords = { 0.53125, 0.71875, 0, 1 },
        alpha = 0.3
    },
    GroupIndicatorParentGroupIndicatorMiddle = {
        path = "Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator",
        size = { 0, 16 },
        position = {
            point = "LEFT",
            relativeTo = "PlayerFrameCustomGroupIndicatorParentGroupIndicatorLeft",
            relativePoint = "RIGHT"
        },
        position2 = {
            point = "RIGHT",
            relativeTo = "PlayerFrameCustomGroupIndicatorParentGroupIndicatorRight",
            relativePoint = "LEFT"
        },
        coords = { 0.1875, 0.53125, 0, 1 },
        alpha = 0.3
    },
}

NicerFrames.frameLayouts["default"]["player"]["DebugBackground"] = {
    color = { 1, 0, 0, 1 },
    size = {
        NicerFrames.frameLayouts["default"]["player"]["size"][1],
        NicerFrames.frameLayouts["default"]["player"]["size"][2],
    },
    position = {
        x = 0,
        y = 0,
        point = "TOPLEFT",
        relativePoint = "TOPLEFT"
    }
}

local playerDefault = NicerFrames.frameLayouts["default"]["player"]

NicerFrames.frameLayouts["default"]["target"] = {
    attributes = {
        movable = true,
        enableMouse = true,
        inherits = "SecureUnitButtonTemplate"
    },
    -- Main frame
    size = { 185, 50 },
    position = {
        point = "TOPLEFT",
        relativeTo = "UIParent",
        relativePoint = "TOPLEFT",
        x = -19,
        y = -4
    },

    -- Background texture (black bar behind name)
    Background = {
        size = { 120, 18 },
        position = { point = "TOP", x = -30, y = -1 },
        color = { 0, 1, 0, 0 }
    },
    -- Portrait
    Portrait = {
        size = { 60, 60 },
        position = { point = "TOPLEFT", x = 124, y = 8 },
        strata = "LOW",
    },
    PortraitTexture = {
        size = { 60, 60 },
        position = { point = "TOPLEFT", x = 1, y = -1 },
        coords = { 0, 1, 0, 1 },
    },
    ReadyCheck = {
        size = { 40, 40 },
        strata = "LOW",
        frameLevel = 3,
        position = {
            point = "CENTER",
            x = 0,
            y = 0,
        },
    },
    -- Name bar
    NameBar = {
        size = { 119, 20 },
        position = { point = "TOPLEFT", x = 3, y = 1 },
    },
    NameBarTexture = {
        path = "Interface\\TargetingFrame\\UI-StatusBar",
        color = { 0, 0, 0, 0.5 }
    },
    -- Health bar
    HealthBar = {
        size = { 119, 12 },
        position = { point = "TOPLEFT", x = 3, y = -18 },
        barColor = { 0, 1, 0 },
    },
    HealthBarTexture = {
        path = "Interface\\TargetingFrame\\UI-StatusBar",
    },
    HealthBarBackground = {
        color = { 0, 0, 0, 0.5 }
    },
    HealthBarText = {
        font = "GameFontNormal",
        text = {
            size = 9,
            font = "TextStatusBarText",
        },
        position = { point = "CENTER", x = 0, y = 0 }
    },
    -- Name text
    HealthBarNameText = {
        font = "GameFontNormalSmall",
        position = { point = "TOP", x = 0, y = 13 },
        text = {
            size = 9,
            font = "TextStatusBarText",
            color = { 0.99999780301005, 0.81960606575012, 0, 0.99999779462814 },
        },
    },
    -- Power bar
    PowerBar = {
        size = { 119, 12 },
        position = { point = "TOPLEFT", x = 3, y = -29 },
    },
    PowerBarTexture = {
        path = "Interface\\TargetingFrame\\UI-StatusBar"
    },
    PowerBarBackground = {
        color = { 0, 0, 0, 0.5 }
    },
    PowerBarText = {
        font = "GameFontNormal",
        text = {
            size = 9,
            font = "TextStatusBarText",
        },
        position = { point = "CENTER", x = 0, y = 0 }
    },
    -- Frame texture (the main frame artwork)
    TextureFrame = {
        size = { 185, 50 },
        position = { point = "CENTER", x = 0, y = 0 }
    },
    TextureFrameTexture = {
        path = "Interface\\TargetingFrame\\UI-TargetingFrame",
        coords = { 0, 1, 0, 1 },
        position = { point = "TOPLEFT", x = -28, y = 23 }
    },
    -- Circle texture
    TextureFramePortraitBorderTexture = {
        path = "Interface\\AddOns\\NicerFrames\\Textures\\UnitFrames\\Class-Circle-Cutout",
        size = { 63, 63 },
        coords = { 0, 1, 0, 1 },
        position = { point = "TOPLEFT", x = 124, y = 10 },
        color = { 1.00, 0.96, 0.41 }
    },
    -- Level text
    TextureFrameLevelText = {
        font = "GameFontNormalSmall",
        position = { point = "CENTER", x = 83, y = -19 }
    },
    -- Master Looter Icon
    TextureFrameMasterLooterIcon = {
        path = "Interface\\GroupFrame\\UI-Group-MasterLooter",
        size = { 13, 13 },
        position = {
            x = 10,
            y = 14,
            point = "TOPLEFT",
            relativePoint = "TOPLEFT"
        }
    },
    -- Leader Icon
    TextureFrameLeaderIcon = {
        path = "Interface\\GroupFrame\\UI-Group-LeaderIcon",
        size = { 16, 16 },
        position = {
            x = -2,
            y = 15,
            point = "TOPLEFT",
            relativePoint = "TOPLEFT"
        }
    },
    -- CombatIcon
    TextureFrameCombatIcon = {
        path = "Interface\\CharacterFrame\\UI-StateIcon",
        size = { 24, 24 },
        coords = { 0.5, 1.0, 0, 0.5 },
        position = {
            x = -5,
            y = -32,
            point = "TOPLEFT",
            relativePoint = "TOPLEFT"
        },
    },
    -- Hit Indicator
    TextureFrameHitIndicator = {
        position = {
            x = 61,
            y = 4,
            point = "CENTER",
            relativePoint = "CENTER"
        },
    },
    -- PVPIcon
    TextureFramePVPIcon = {
        path = "Interface\\TargetingFrame\\UI-PVP-FFA",
        size = { 50, 50 },
        position = {
            x = -22,
            y = -3,
            point = "TOPLEFT",
            relativePoint = "TOPLEFT"
        }
    },
    TextureFrameRaidTargetIcon = {
        path = "Interface\\TargetingFrame\\UI-RaidTargetingIcons",
        size = { 30, 30 },
        position = {
            x = 62,
            y = 30,
            point = "TOP",
            relativePoint = "TOP"
        }
    },
}

local targetDefault = NicerFrames.frameLayouts["default"]["target"]

NicerFrames.frameLayouts["default"]["pet"] = {
    -- Main frame
    size = { 114, 30 },
    position = { point = "TOPLEFT", relativeTo = "UIParent", "BOTTOMLEFT", x = -19, y = -4 },
    -- Background texture (black bar behind name)
    Background = {
        hidden = true,
        size = { 77, 18 },
        position = { point = "TOP", x = 18, y = -1 },
        color = { 0, 0, 0, 0.9 }
    },
    -- Portrait
    Portrait = {
        strata = "MEDIUM",
        frameLevel = 10,
        size = { 16, 16 },
        position = { point = "TOPLEFT", x = 2, y = 9 },
    },
    PortraitTexture = {
        size = { 34, 34 },
        position = { point = "TOPLEFT", x = 0, y = 0 },
        coords = { 0, 1, 0, 1 },
    },
    -- Name bar
    NameBar = {
        size = { 119, 16 },
        position = { point = "TOPLEFT", x = 48, y = -1 },
        texture = {
            color = { r = 0, g = 0, b = 0, a = 0.5 }
        }
    },

    -- Health bar
    HealthBar = {
        frameLevel = 1,
        size = { 69, 7 },
        barColor = { 0, 1, 0 },
        position = { x = 42, y = -6, point = "TOPLEFT" },
    },
    HealthBarTexture = {
        path = "Interface\\TargetingFrame\\UI-StatusBar",
        -- barColor = { r = 0, g = 1, b = 0 },
        -- color = { r = 0, g = 1, b = 0 },
    },
    HealthBarBackground = {
        color = { 0.33, 0.59, 0.33, 0.2 }
    },
    HealthBarText = {
        text = {
            font = "GameFontNormal",
            size = 7,
        },
        position = { x = 0, y = 0, point = "CENTER" }
    },
    HealthBarNameText = {
        font = "GameFontNormalSmall",
        text = {
            size = 9,
            font = "TextStatusBarText",
            color = { 0.99999780301005, 0.81960606575012, 0, 0.99999779462814 },
        },
        position = {
            x = -4,
            y = 11,
            point = "TOP",
            relativePoint = "TOP"
        }
    },
    -- Power bar
    PowerBar = {
        size = { 69, 7 },
        position = { point = "TOPLEFT", x = 42, y = -14 },
    },
    PowerBarTexture = {
        path = "Interface\\TargetingFrame\\UI-StatusBar"
    },
    PowerBarBackground = {
        color = { 0, 0, 1, 0.2 }
    },
    PowerBarText = {
        text = {
            size = 7,
            font = "GameFontNormal",
        },
        position = { x = 0, y = 0, point = "CENTER" }
    },
    -- Texture frame
    TextureFrame = {
        strata = "MEDIUM",
        frameLevel = 10,
        size = { 114, 30 },
        position = { point = "CENTER", x = 0, y = 0 }
    },
    TextureFrameTexture = {
        path = "Interface\\TargetingFrame\\UI-SmallTargetingFrame",
        coords = { 0, 1, 0, 1 },
        position = { point = "TOPLEFT", x = -4, y = 15 },
    },
    TextureFramePortraitBorderTexture = {
        hidden = true,
    },
    -- Name text
    TextureFrameNameText = {
        font = "GameFontNormalSmall",
        position = { x = 20, y = 5, point = "TOP" }
    },
    -- Level text
    TextureFrameLevelText = {
        font = "GameFontNormalSmall",
        position = { x = -86, y = -19, point = "CENTER" }
    },
    TextureFrameRaidTargetIcon = {
        path = "Interface\\TargetingFrame\\UI-RaidTargetingIcons",
        size = { 26, 26 },
        position = {
            x = -73,
            y = -14,
            point = "TOP",
            -- relativeTo = "$parent",
            relativePoint = "TOP"
        }
    },
}

local defaultPet = NicerFrames.frameLayouts["default"]["pet"]

NicerFrames.frameLayouts["default"]["targettarget"] = {
    attributes = {
        movable = true,
        enableMouse = true,
        inherits = "SecureUnitButtonTemplate"
    },
    size = { 93, 45 },
    position = {
        point = "BOTTOMRIGHT",
        relativeTo = "TargetFrameCustom",
        relativePoint = "BOTTOMRIGHT",
        x = -35,
        y = -10,
    },
    Background = {
        size = { 46, 15 },
        position = { x = 42, y = 13, point = "BOTTOMLEFT" },
        color = { 0, 0, 0, 0.5 },
        hidden = true,
    },
    Portrait = {
        strata = "MEDIUM",
        frameLevel = 5,
        size = { 40, 40 },
        position = { point = "TOPLEFT", x = 6, y = -8 },
    },
    PortraitTexture = {
        size = { 36, 36 },
        position = { point = "TOPLEFT", x = -2, y = 3 },
        coords = { 0, 1, 0, 1 },
    },
    HealthBar = {
        frameLevel = 7,
        size = { 46, 6 },
        position = { x = 44, y = -15, point = "TOPLEFT" },
        barColor = { 0, 1, 0 },
    },
    HealthBarTexture = {
        path = "Interface\\TargetingFrame\\UI-StatusBar"
    },
    HealthBarBackground = {
        color = { 0, 0, 0, 0.5 }
    },
    HealthBarText = {
        text = {
            size = 9,
            font = "GameFontNormalSmall",
        },
        position = { x = 0, y = 0, point = "CENTER" }
    },
    PowerBar = {
        frameLevel = 7,
        size = { 46, 6 },
        position = { x = 44, y = -23, point = "TOPLEFT" },
        barColor = { 0, 0, 1 },
    },
    PowerBarTexture = {
        path = "Interface\\TargetingFrame\\UI-StatusBar"
    },
    PowerBarBackground = {
        color = { 0, 0, 0, 0.5 }
    },
    PowerBarText = {
        text = {
            size = 9,
            font = "GameFontNormalSmall",
        },
        position = { x = 0, y = 0, point = "CENTER" }
    },
    TextureFrame = {
        strata = "MEDIUM",
        frameLevel = 10,
        size = { 93, 45 },
        position = { point = "CENTER", x = 0, y = 0 }
    },
    TextureFrameTexture = {
        path = "Interface\\TargetingFrame\\UI-TargetofTargetFrame",
        size = { 93, 45 },
        coords = { 0.015625, 0.7265625, 0, 0.703125 },
        position = { point = "TOPLEFT", x = 0, y = 0 }
    },
    TextureFramePortraitBorderTexture = {
        path = "Interface\\AddOns\\NicerFrames\\Textures\\UnitFrames\\Class-Circle",
        size = { 41, 41 },
        coords = { 0, 1, 0, 1 },
        position = { point = "TOPLEFT", x = 2, y = -3 },
        color = { 1.00, 0.96, 0.41 }
    },
    TextureFrameNameText = {
        font = "GameFontNormalSmall",
        position = { point = "TOP", x = 0, y = 15 }
    },
}
defaultPet.NameBar.hidden = true

local function updateLayoutValues(original, new)
    for k, v in pairs(new) do
        if type(v) == "table" and type(original[k]) == "table" then
            updateLayoutValues(original[k], v)
        else
            original[k] = v
        end
    end
end
local function deepcopy(orig)
    if type(orig) ~= 'table' then return orig end
    local copy = {}
    for k, v in pairs(orig) do
        if type(v) == 'table' then
            copy[k] = deepcopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

local function createThickLayout(layoutType, unitType)
    local defaultLayout = NicerFrames.frameLayouts["default"][unitType]
    NicerFrames.frameLayouts[layoutType][unitType] = deepcopy(defaultLayout)
    return NicerFrames.frameLayouts[layoutType][unitType]
end

local function PrintTable(tbl, indent)
    indent = indent or ''
    for k, v in pairs(tbl) do
        if type(v) == 'table' then
            print(indent .. tostring(k) .. ' = {')
            PrintTable(v, indent .. '  ')
            print(indent .. '}')
        else
            print(indent .. tostring(k) .. ' = ' .. tostring(v))
        end
    end
end

NicerFrames.frameLayouts["Thick"] = {}
local thickPlayer = createThickLayout("Thick", "player")
thickPlayer.TextureFrame = {
    size = { 260, 124 },
    position = { point = "CENTER", x = -11, y = -17 }
}
thickPlayer.TextureFrameTexture = {
    coords = { 1, 0, 0, 1 },
    path = "Interface\\AddOns\\NicerFrames\\Textures\\UnitFrames\\UI-TargetingFrame-Light",
}
updateLayoutValues(thickPlayer.HealthBar, {
    size = { 119, 26 },
    barColor = { 0, 1, 0 },
    position = { x = 61, y = -2, point = "TOPLEFT" },
})
updateLayoutValues(thickPlayer.HealthBarText, {
    text = {
        outline = "NONE",
        -- font = "GameFontNormal",
        size = 9,
        position = { x = 0, y = -5, point = "CENTER" }
    }
})
updateLayoutValues(thickPlayer.PortraitTexture, {
    coords = { 1, 0, 0, 1 },
})

thickPlayer.TextureFrameStatusTexture = {
    path = "Interface\\AddOns\\NicerFrames\\Textures\\UnitFrames\\ui-targetingframe-flash",
    size = { 247, 96 },
    coords = { 1, 0.06, 0, 0.19 },
    color = { 1, 1, 0 },
    position = {
        point = "TOPLEFT",
        x = -2,
        y = 1
    },
}

local function adjust(table, propertyName, value)
    if type(value) == 'table' then
        table[propertyName] = value
    else
        table[propertyName] = (table[propertyName] or 0) + value
    end
end

local elements = {
    "TextureFramePortraitBorderTexture",
    "TextureFrameRestIcon",
    "TextureFrameRestGlow",
    "TextureFramePVPIcon",
    "TextureFrameMasterIcon",
    "TextureFrameLeaderIcon",
}

for _, element in ipairs(elements) do
    adjust(thickPlayer[element].position, "y", -22)
    adjust(thickPlayer[element].position, "x", 48)
end
adjust(thickPlayer.GroupIndicatorParent.position, "x", 8)
adjust(thickPlayer.TextureFrameHitIndicator.position, "y", 15)
adjust(thickPlayer.TextureFrameHitIndicator.position, "x", 10)
adjust(thickPlayer.TextureFrameLevelText.position, "y", 17)
adjust(thickPlayer.TextureFrameLevelText.position, "x", 10)
NicerFrames.frameLayouts["Thick"]["player"].GroupIndicatorParent.scale = 0.7
NicerFrames.frameLayouts["Thick"]["player"] = thickPlayer

local thickTarget = createThickLayout("Thick", "target")
thickTarget.HealthBar = {
    size = { 119, 26 },
    barColor = { 0, 1, 0 },
    position = { x = 3, y = -2, point = "TOPLEFT" },
}
updateLayoutValues(thickTarget.HealthBarText, {
    text = {
        font = "GameFontNormal",
        size = 9,
        position = { x = 0, y = -5, point = "CENTER" }
    }
})
thickTarget.TextureFrame = {
    size = { 260, 124 },
    position = { point = "CENTER", x = 9, y = -17 }
}
thickTarget.TextureFrameTexture = {
    coords = { 0, 1, 0, 1 },
    path = "Interface\\AddOns\\NicerFrames\\Textures\\UnitFrames\\UI-TargetingFrame-Light",
}
updateLayoutValues(thickTarget.PortraitTexture, {
    coords = { 1, 0, 0, 1 },
})
thickTarget.NameBarTexture.hidden = true
adjust(thickTarget.TextureFramePortraitBorderTexture.position, "x", 30)
adjust(thickTarget.TextureFramePortraitBorderTexture.position, "y", -22)
adjust(thickTarget.TextureFrameLevelText.position, "x", -6)
adjust(thickTarget.TextureFrameLevelText.position, "y", 16)
NicerFrames.frameLayouts["Thick"]["target"] = thickTarget

local thickPet = createThickLayout("Thick", "pet")
thickPet.PortraitTexture = {
    size = { 33, 34 },
    position = { point = "TOPLEFT", x = 3, y = -9 }
}
thickPet.HealthBar = {
    frameLevel = 7,
    size = { 69, 16 },
    barColor = { 0, 1, 0 },
    position = { x = 42, y = 2, point = "TOPLEFT" },
}
thickPet.TextureFrameTexture = {
    size = { 153, 74 },
    path = "Interface\\AddOns\\NicerFrames\\Textures\\UnitFrames\\NoLevel-Thick-TargetingFrame",
    coords = { 1, 0, 0, 1 },
    position = { point = "TOPLEFT", x = -23, y = 9 },
}
updateLayoutValues(thickPet.PortraitTexture, {
    coords = { 1, 0, 0, 1 },
})
thickPet.Background.hidden = true
adjust(thickPet.HealthBar.position, "y", -7)
adjust(thickPet.PowerBar.position, "y", -7)
adjust(thickPet.HealthBarText.text, "size", -1)
adjust(thickPet.PowerBarText.text, "size", -1)
adjust(thickPet.HealthBarNameText.text, "size", -3)
adjust(thickPet.HealthBarNameText.position, "y", -3)
adjust(thickPet.PowerBar, "frameLevel", 7)
NicerFrames.frameLayouts["Thick"]["pet"] = thickPet

local targettargetThick = createThickLayout("Thick", "targettarget")
targettargetThick.PortraitTexture = {
    size = { 29, 29 },
    position = { point = "TOPLEFT", x = -4, y = 1 },
    coords = { 1, 0, 0, 1 }
}
targettargetThick.TextureFrameTexture = {
    size = { 126, 63 },
    path = "Interface\\AddOns\\NicerFrames\\Textures\\UnitFrames\\NoLevel-Thick-TargetingFrame",
    coords = { 1, 0, 0, 1 },
    position = { point = "TOPLEFT", x = -20, y = 0 },
}
targettargetThick.TextureFramePortraitBorderTexture = {
    path = "Interface\\AddOns\\NicerFrames\\Textures\\UnitFrames\\Class-Circle",
    size = { 32, 32 },
    coords = { 0, 1, 0, 1 },
    position = { point = "TOPLEFT", x = 1, y = -6 },
    color = { 1.00, 0.96, 0.41 }
}
adjust(targettargetThick.HealthBar.position, "x", -11)
adjust(targettargetThick.HealthBar.position, "y", 3)
adjust(targettargetThick.HealthBar, "size", { 58, 14 })
adjust(targettargetThick.PowerBar.position, "x", -11)
adjust(targettargetThick.PowerBar.position, "y", -2)
adjust(targettargetThick.PowerBar, "size", { 58, 8 })
adjust(targettargetThick.HealthBarText.text, "size", -2)
adjust(targettargetThick.PowerBarText.text, "size", -2)
adjust(targettargetThick.PowerBarText.position, "y", 1)
NicerFrames.frameLayouts["Thick"]["targettarget"] = targettargetThick

NicerFrames.frameLayouts["ArenaLive"] = {}
local arenaLivePlayer = createThickLayout("ArenaLive", "player")
arenaLivePlayer.TextureFrame = {
    size = { 158, 49 },
    position = { point = "CENTER", x = -16, y = -2 }
}
arenaLivePlayer.TextureFrameTexture = {
    path = "Interface\\AddOns\\NicerFrames\\Textures\\UnitFrames\\PetFrame",
    coords = { 0.1953125, 0.8125, 0.0625, 0.984375 }
}
arenaLivePlayer.HealthBar = {
    size = { 96, 28 },
    barColor = { 0, 1, 0 },
    position = { x = 52, y = -5, point = "TOPLEFT" },
}
arenaLivePlayer.PowerBar = {
    size = { 96, 12 },
    barColor = { 0, 1, 0 },
    position = { x = 52, y = -34, point = "TOPLEFT" },
}
arenaLivePlayer.PortraitTexture = {
    size = { 42, 42 },
    position = { point = "TOPLEFT", x = 9, y = -12 },
    coords = { 0.11, 0.89, 0.11, 0.89 }
}
arenaLivePlayer.TextureFramePortraitBorderTexture = {
    path = "Interface\\AddOns\\NicerFrames\\Textures\\UnitFrames\\TargetingFrame-SquareBox",
    size = { 47, 37 },
    coords = { 1, 0, 0, 1 },
    position = { point = "TOPLEFT", x = 5, y = -4 },
    color = { 1, 1, 0 }
}
arenaLivePlayer.TextureFrameStatusTexture = {
    path = "Interface\\AddOns\\NicerFrames\\Textures\\UnitFrames\\PetFrameFlash",
    size = { 158, 49 },
    coords = { 0.1953125, 0.8125, 0.0625, 0.984375 },
    color = { 1, 1, 0 },
    position = {
        point = "TOPLEFT",
        x = 0,
        y = 0
    },
}
updateLayoutValues(arenaLivePlayer.GroupIndicatorParentGroupIndicatorText, {
    text = {
        size = 9,
    },
})
updateLayoutValues(arenaLivePlayer.GroupIndicatorParent, {
    position = {
        y = 10
    },
})
arenaLivePlayer.Background.hidden = true
arenaLivePlayer.NameBar.hidden = true

arenaLivePlayer.GroupIndicatorParent.scale = 0.7
adjust(arenaLivePlayer.GroupIndicatorParent.position, "x", -30)
adjust(arenaLivePlayer.TextureFrameLevelText.position, "x", 12)
adjust(arenaLivePlayer.TextureFramePVPIcon.position, "x", 12)
adjust(arenaLivePlayer.TextureFramePVPIcon.position, "y", -5)
adjust(arenaLivePlayer.TextureFramePVPIcon, "size", { 36, 36 })
adjust(arenaLivePlayer.TextureFrameLeaderIcon.position, "y", -8)
adjust(arenaLivePlayer.TextureFrameMasterIcon.position, "y", -8)
adjust(arenaLivePlayer.TextureFrameHitIndicator.position, "x", 13)
NicerFrames.frameLayouts["ArenaLive"]["player"] = arenaLivePlayer




local arenaLiveTarget = createThickLayout("ArenaLive", "target")
arenaLiveTarget.TextureFrame = {
    size = { 158, 49 },
    position = { point = "CENTER", x = 16, y = -2 }
}
arenaLiveTarget.TextureFrameTexture = {
    path = "Interface\\AddOns\\NicerFrames\\Textures\\UnitFrames\\PetFrame",
    coords = { 0.8125, 0.1953125, 0.0625, 0.984375 }
}
arenaLiveTarget.PortraitTexture = {
    size = { 43, 43 },
    position = { point = "TOPLEFT", x = 13, y = -12 },
    coords = { 0.89, 0.11, 0.11, 0.89 }
}
arenaLiveTarget.HealthBar = {
    size = { 96, 28 },
    barColor = { 0, 1, 0 },
    position = { x = 37, y = -6, point = "TOPLEFT" },
}
arenaLiveTarget.PowerBar = {
    size = { 96, 12 },
    barColor = { 0, 1, 0 },
    position = { x = 37, y = -33, point = "TOPLEFT" },
}
arenaLiveTarget.TextureFramePortraitBorderTexture = {
    path = "Interface\\AddOns\\NicerFrames\\Textures\\UnitFrames\\TargetingFrame-SquareBox",
    size = { 47, 37 },
    coords = { 1, 0, 0, 1 },
    position = { point = "TOPLEFT", x = 106, y = -4 },
    color = { 1, 1, 0 }
}
arenaLiveTarget.Background.hidden = true
arenaLiveTarget.NameBarTexture.hidden = true
arenaLiveTarget.NameBar.hidden = true
adjust(arenaLiveTarget.TextureFrameLevelText.position, "x", -10)
adjust(arenaLiveTarget.TextureFrameHitIndicator.position, "x", -8)
NicerFrames.frameLayouts["ArenaLive"]["target"] = arenaLiveTarget







local arenaLivePet = createThickLayout("ArenaLive", "pet")
arenaLivePet.TextureFrame = {
    size = { 90, 26 },
    position = { point = "CENTER", x = -13, y = -1 },
}
arenaLivePet.TextureFrameTexture = {
    path = "Interface\\AddOns\\NicerFrames\\Textures\\UnitFrames\\PetFrame",
    coords = { 0.1953125, 0.8125, 0.0625, 0.984375 },
}
arenaLivePet.PortraitTexture = {
    size = { 25, 20 },
    position = { point = "TOPLEFT", x = 1, y = -14 },
    coords = { 0.89, 0.11, 0.11, 0.89 }
}
updateLayoutValues(arenaLivePet.HealthBarNameText, {
    text = {
        size = 6
    }
})
arenaLivePet.HealthBar = {
    size = { 55, 14 },
    barColor = { 0, 1, 0 },
    position = { x = 30, y = -5, point = "TOPLEFT" },
}
arenaLivePet.PowerBar = {
    size = { 55, 6 },
    barColor = { 0, 1, 0 },
    position = { x = 30, y = -19, point = "TOPLEFT" },
}
arenaLivePet.Background.hidden = true
NicerFrames.frameLayouts["ArenaLive"]["pet"] = arenaLivePet






local arenaLiveTargetTarget = createThickLayout("ArenaLive", "targettarget")
arenaLiveTargetTarget.TextureFrame = {
    size = { 90, 26 },
    position = { point = "CENTER", x = -3, y = -1 }
}
arenaLiveTargetTarget.TextureFrameTexture = {
    path = "Interface\\AddOns\\NicerFrames\\Textures\\UnitFrames\\PetFrame",
    coords = { 0.1953125, 0.8125, 0.0625, 0.984375 }
}
arenaLiveTargetTarget.PortraitTexture = {
    size = { 24, 20 },
    position = { point = "TOPLEFT", x = -3, y = -5 },
    coords = { 0.89, 0.11, 0.11, 0.89 }
}
arenaLiveTargetTarget.HealthBar = {
    size = { 55, 14 },
    barColor = { 0, 1, 0 },
    position = { x = 29, y = -12, point = "TOPLEFT" },
}
arenaLiveTargetTarget.PowerBar = {
    size = { 55, 6 },
    barColor = { 0, 1, 0 },
    position = { x = 29, y = -27, point = "TOPLEFT" },
}
arenaLiveTargetTarget.TextureFramePortraitBorderTexture = {
    path = "Interface\\AddOns\\NicerFrames\\Textures\\UnitFrames\\TargetingFrame-SquareBox",
    size = { 28, 20 },
    coords = { 1, 0, 0, 1 },
    position = { point = "TOPLEFT", x = 3, y = -2 },
    color = { 1, 1, 0 }
}
arenaLiveTargetTarget.Background.hidden = true
NicerFrames.frameLayouts["ArenaLive"]["targettarget"] = arenaLiveTargetTarget

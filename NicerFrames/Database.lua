local db
local AddonName = "NicerFrames"
local LSM = LibStub("LibSharedMedia-3.0")
local defaults = {}

local function autoOrder()
    local order = 0
    return function()
        order = order + 1
        return order
    end
end
local getOrder = autoOrder()

Options = {
    name = AddonName,
    handler = NicerFrames,
    type = 'group',
    args = {},
}

Options2 = {
    name = AddonName,
    handler = NicerFrames,
    type = 'group',
    args = {},
}

local function profileOption(params)
    local options = {
        get = function(info)
            local key = info.arg or info[#info]
            if type(key) == "table" then
                local value = NicerFrames.db.profile
                for _, k in ipairs(key) do
                    if type(value) ~= "table" then return nil end
                    value = value[k]
                end
                return value
            else
                return NicerFrames.db.profile[key]
            end
        end,
        set = function(info, value)
            local key = info.arg or info[#info]
            if type(key) == "table" then
                NicerFrames.db.profile[key[1]][key[2]] = value
            else
                NicerFrames.db.profile[key] = value
                DebugNicerFrames:Print("Setting profile key: " .. key .. " to: " .. tostring(value))
            end
            if params.onChange then params.onChange(NicerFrames.db.profile) end
            if params.reload then NicerFrames:ReloadInterface() end
            if params.refresh then NicerFrames:RefreshConfig() end
        end,
    }

    for k, v in pairs(params) do
        if not (k == "reload" or k == "refresh" or k == "updatePosition" or k == "onChange") then
            options[k] = v
        end
    end
    if not params.order then options.order = getOrder() end

    return options
end

local function profileColorOption(params)
    local options = {
        get = function(info)
            local key = info.arg or info[#info]
            return NicerFrames.db.profile[key].r, NicerFrames.db.profile[key].g, NicerFrames.db.profile[key].b,
                NicerFrames.db.profile[key].a
        end,
        set = function(info, r, g, b, a)
            local key = info.arg or info[#info]
            NicerFrames.db.profile[key].r, NicerFrames.db.profile[key].g, NicerFrames.db.profile[key].b, NicerFrames.db.profile[key].a =
                r, g, b, a
            if params.reload then NicerFrames:ReloadInterface() end
            if params.refresh then NicerFrames:UpdateTextureFrameColor() end
        end,
    }

    for k, v in pairs(params) do
        if not (k == "reload" or k == "refresh" or k == "updatePosition") then
            options[k] = v
        end
    end

    if not params.order then
        options.order = getOrder()
    end

    return options
end

local function markedProfileOption(params)
    local options = {
        get = function(info)
            local key = info.arg or info[#info]
            local frame = NicerFrames.db.profile.marked.frame
            local type = NicerFrames.db.profile.marked.type

            NicerFrames.db.profile.frameSettings = NicerFrames.db.profile.frameSettings or {}
            NicerFrames.db.profile.frameSettings[frame] = NicerFrames.db.profile.frameSettings[frame] or {}
            NicerFrames.db.profile.frameSettings[frame][type] = NicerFrames.db.profile.frameSettings[frame][type] or {}

            if key[1] == key[2] then
                return NicerFrames.db.profile.frameSettings[frame][type][key[1]]
            else
                NicerFrames.db.profile.frameSettings[frame][type][key[1]] =
                    NicerFrames.db.profile.frameSettings[frame][type][key[1]] or {}
                return NicerFrames.db.profile.frameSettings[frame][type][key[1]][key[2]]
            end
        end,
        set = function(info, value)
            local key = info.arg or info[#info]
            local frame = NicerFrames.db.profile.marked.frame
            local type = NicerFrames.db.profile.marked.type
            print(string.format("%s%s%s", frame, type, key[2]))
            NicerFrames.db.profile.frameSettings = NicerFrames.db.profile.frameSettings or {}
            NicerFrames.db.profile.frameSettings[frame] = NicerFrames.db.profile.frameSettings[frame] or {}
            NicerFrames.db.profile.frameSettings[frame][type] = NicerFrames.db.profile.frameSettings[frame][type] or {}

            if key[1] == key[2] then
                NicerFrames.db.profile.frameSettings[frame][type][key[1]] = value
            else
                NicerFrames.db.profile.frameSettings[frame][type][key[1]] =
                    NicerFrames.db.profile.frameSettings[frame][type][key[1]] or {}
                NicerFrames.db.profile.frameSettings[frame][type][key[1]][key[2]] = value
            end

            DebugNicerFrames:Print(string.format("Setting %s-%s %s to: %s",
                frame, type, key[1] == key[2] and key[1] or key[2], tostring(value)))
            if params.reload then NicerFrames:ReloadInterface() end
            if params.refresh then NicerFrames:RefreshConfig() end
        end,
    }

    for k, v in pairs(params) do
        if not (k == "reload" or k == "refresh" or k == "updatePosition") then
            options[k] = v
        end
    end

    if not params.order then
        options.order = getOrder()
    end
    return options
end

function NicerFrames:InitDatabase()
    if self.isClassic or self.isClassic60 then
        self.db = LibStub("AceDB-3.0"):New("NicerFrames_DB", defaults, true)
    elseif self.isTBC or self.isWotlk then
        self.db = LibStub("AceDB-3.0"):New("NicerFrames_DB", defaults, "Default")
    end

    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
    Options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
end

function NicerFrames:OnProfileChanged(event, database, newProfileKey)
    self.db = database
    db = self.db.profile

    for _, v in self:IterateModules() do
        if (v.OnProfileChanged) then
            v:OnProfileChanged(database)
        end
    end
end

defaults["profile"] = {
    unitFrameStyle = "Default",
    barTexture = "Blizzard",
    fontFamily = "Friz Quadrata TT",
    frameBorder = "Normal",
    customPlayerName = "",
    playerX = 0,
    playerY = 0,
    targetX = 0,
    targetY = 0,
    petX = 0,
    petY = 0,
    portraitBorder = false,
    nameColor = false,
    healthClassColor = false,
    textureFrameColor = {
        r = 1,
        g = 1,
        b = 1,
        a = 1
    },
    healthFormat = "!CURR/ !MAX (!PERC%)",
    manaFormat = "!CURR / !MAX (!PERC%)",
    energyFormat = "!CURR / !MAX",
    playerNameBar = {
        classColor = false,
        customColor = false
    },
    portraitIconStyle = "Default",
    playerFrameScale = 1,
    targetFrameScale = 1,
    petFrameScale = 1,
    targettargetFrameScale = 1,
    marked = {
        frame = "player",
        type = "HealthBarNameText",
        property = "Position"
    },
    frameSettings = {},
    alwaysShowStatusText = false,
    hideFullStatusTexts = false,
    centerFrames = false,
}

Options["args"] = {}
Options["args"]["General"] = {
    type = 'group',
    name = "General Settings",
    args = {},
}

Options["args"]["General"]["args"] = {
    unitFrameStyle = profileOption({
        type = "select",
        name = "Style",
        desc = "Set the frames texture",
        values = {
            Default = "Default",
            Thick = "Thick",
            ArenaLive = "ArenaLive",
        },
        onChange = function(dbu)
            if dbu.unitFrameStyle == "ArenaLive" then
                if dbu.portraitIconStyle == "Cartoon2" or dbu.portraitIconStyle == "NormalIcons" then
                    dbu.portraitIconStyle = "Default"
                end
            end
        end,
        refresh = true,
        reload = true,
    }),
    portraitBorder = profileOption({
        type = "toggle",
        name = "Portrait border",
        desc = "Border around target portrait to determine class or status",
        refresh = true,
    }),
    centerFrames = profileOption({
        type = "toggle",
        name = "Center frames",
        desc = "When moving Player frame, automatically place Target frame mirrored on the other side of the screen",
        refresh = true,
    }),
    frameBorder = profileOption({
        type = "select",
        name = "Frame border",
        values = function()
            if NicerFrames.db.profile.unitFrameStyle == "Default" then
                return {
                    Normal = "Normal",
                    Rare = "Rare",
                    Elite = "Elite",
                    RareElite = "RareElite",
                }
            end
            return { Normal = "Normal" }
        end,
        refresh = true
    }),
    customPlayerName = profileOption({
        type = "input",
        name = "Custom player name",
    }),
    colorHeader = {
        type = "header",
        order = getOrder(),
        name = "Color"
    },
    nameColor = profileOption({
        type = "toggle",
        name = "Name color",
        desc = "Color name according to class",
        refresh = true,
    }),
    healthClassColor = profileOption({
        type = "toggle",
        name = "Healthbar class color",
        desc = "Color healthbar according to class",
        refresh = true,
    }),
    textureFrameColor = profileColorOption({
        type = "color",
        name = "Frame color",
        desc = "Set the color and opacity of the frame",
        hasAlpha = true,
        refresh = true,
    }),
    playerNameBar = profileOption({
        type = "toggle",
        name = "Class color namebar",
        disabled = function()
            return NicerFrames.db.profile.unitFrameStyle == "ArenaLive"
        end,
        refresh = true,
        arg = { "playerNameBar", "classColor" }
    }),
    portraitIconStyle = profileOption({
        type = "select",
        name = "Class color namebar",
        values = function()
            local unitFrameStyleList = { Default = "Default", Cartoon = "Cartoon", NormalIcons = "Normal Icons" }
            if NicerFrames.db.profile.unitFrameStyle ~= "ArenaLive" then
                unitFrameStyleList["Cartoon2"] = "Cartoon2"
            end
            return unitFrameStyleList
        end,
        refresh = true,
    }),
    textFormatHeader = {
        type = "header",
        order = getOrder(),
        name = "Text format"
    },
    healthFormat = profileOption({
        type = "input",
        name = "Health format",
        desc = "Use !CURR, !MAX, and !PERC as placeholders",
        width = "full",
        refresh = true,
    }),
    manaFormat = profileOption({
        type = "input",
        name = "Mana format",
        desc = "Use !CURR, !MAX, and !PERC as placeholders",
        width = "full",
        refresh = true,
    }),
    energyFormat = profileOption({
        type = "input",
        name = "Energy/Rage/Focus/Runic format",
        desc = "Use !CURR, !MAX, and !PERC as placeholders",
        width = "full",
        refresh = true,
    }),
    scaleHeader = {
        type = "header",
        order = getOrder(),
        name = "Frame scale"
    },
    playerFrameScale = profileOption({
        type = "range",
        name = "Player scale",
        min = 0.2,
        max = 4,
        step = 0.05,
        refresh = true,
    }),
    targetFrameScale = profileOption({
        type = "range",
        name = "Target scale",
        min = 0.2,
        max = 4,
        step = 0.05,
        refresh = true,
    }),
    petFrameScale = profileOption({
        type = "range",
        name = "Pet scale",
        min = 0.2,
        max = 4,
        step = 0.05,
        refresh = true,
    }),
    targettargetFrameScale = profileOption({
        type = "range",
        name = "TargetOfTarget scale",
        min = 0.2,
        max = 4,
        step = 0.05,
        refresh = true,
    }),
    alwaysShowStatusText = profileOption({
        type = "toggle",
        name = "Show HP & Mana text",
        onChange = function(dbu)
            if not dbu.alwaysShowStatusText and dbu.hideFullStatusTexts then
                dbu.hideFullStatusTexts = false
            end
        end,
        refresh = true,
    }),
    hideFullStatusTexts = profileOption({
        type = "toggle",
        name = "Hide HP & Mana when max",
        disabled = function()
            return not NicerFrames.db.profile.alwaysShowStatusText
        end,
        refresh = true,
    }),
    fontFamily = profileOption({
        type = "select",
        dialogControl = "LSM30_Font",
        name = "Font Family",
        desc = "Set the font for frame text",
        values = LSM:HashTable("font"),
        refresh = true,
    }),
    barTexture = profileOption({
        type = "select",
        dialogControl = "LSM30_Statusbar",
        name = "Texture",
        desc = "Set the frames bar Texture",
        values = LSM:HashTable("statusbar"),
        refresh = true,
    }),
}

Options["args"]["Frame specific"] = {
    type = "group",
    name = "Position & Size",
    order = 6,
    childGroups = "tab",
    args = {}
}

Options["args"]["Frame specific"]["args"] = {
    frame = profileOption({
        type = "select",
        name = "Select frame",
        values = {
            player = "Player",
            target = "Target",
            pet = "Pet",
            targettarget = "Target of Target",
        },
        arg = { "marked", "frame" }
    }),
    type = profileOption({
        type = "select",
        name = "Select property",
        values = {
            HealthBarNameText = "Name Text",
            HealthBarText = "Health Text",
            PowerBarText = "Power Text",
        },
        arg = { "marked", "type" }
    }),
    resetSpecficFrame = {
        type = "execute",
        name = "Reset values",
        order = getOrder(),
        desc = "Reset current frames position & styling",
        func = function()
            local frameType = NicerFrames.db.profile.marked.frame
            local textType = NicerFrames.db.profile.marked.type
            if not NicerFrames.db.profile.frameSettings then return end
            if not NicerFrames.db.profile.frameSettings[frameType] then return end
            if not NicerFrames.db.profile.frameSettings[frameType][textType] then return end
            NicerFrames.db.profile.frameSettings[frameType] = {}
            NicerFrames:RefreshConfig()
        end,
    },
    positionGroup = {
        type = "group",
        name = "Position",
        childGroups = "tab",
        order = 1,
        args = {
            position = markedProfileOption({
                type = "select",
                order = 10,
                name = "Select position",
                values = {
                    LEFT = "Left",
                    CENTER = "Center",
                    RIGHT = "Right",
                },
                arg = { "position", "point" },
                refresh = true
            }),
            xOffset = markedProfileOption({
                type = "range",
                min = -50,
                max = 50,
                step = 0.5,
                order = 25,
                name = "X Offset",
                arg = { "position", "x" },
                refresh = true
            }),
            yOffset = markedProfileOption({
                type = "range",
                min = -50,
                max = 50,
                step = 0.5,
                order = 30,
                name = "Y Offset",
                arg = { "position", "y" },
                refresh = true
            }),
        },
    },
    sizeGroup = {
        type = "group",
        name = "Size & style",
        childGroups = "tab",
        order = 2,
        args = {
            fontSize = markedProfileOption({
                type = "range",
                min = 1,
                max = 50,
                step = 1,
                order = 25,
                name = "Size",
                arg = { "text", "size" },
                refresh = true
            }),
            textFlag = markedProfileOption({
                type = "select",
                values = function()
                    return {
                        NONE = "None",
                        OUTLINE = "Outline",
                        THICKOUTLINE = "Big Outline",
                        MONOCHROME = "Monochrome"
                    }
                end,
                order = 35,
                name = "Outline",
                arg = { "text", "outline" },
                refresh = true
            }),
            hidden = markedProfileOption({
                type = "toggle",
                order = 40,
                name = "Hide",
                desc = "Require you to reload UI to show text again",
                disabled = function()
                    return NicerFrames.db.profile.marked.type ~= "HealthBarNameText"
                end,
                arg = { "hidden", "hidden" },
                refresh = true
            }),
        }
    },
}

Options["args"]["Debug"] = {
    type = "group",
    name = "Developer mode",
    order = 20,
    args = {}
}
Options["args"]["Debug"]["args"] = {
    debugMode = profileOption({
        type = "toggle",
        name = "Debug mode",
        order = 1
    }),
}

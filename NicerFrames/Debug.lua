local function colorize(text, color)
    return color .. text .. "|r"
end

DebugNicerFrames = {}

function DebugNicerFrames:Print(msg, header)
    if msg == nil then msg = "nil" end
    if type(msg) == "boolean" then msg = tostring(msg) end

    if NicerFrames.db.profile.debugMode then
        if header then
            print(
                colorize("NicerFrames", NORMAL_FONT_COLOR_CODE) ..
                colorize(" (" .. header .. ")", GRAY_FONT_COLOR_CODE) ..
                " - " .. msg
            )
        else
            print(
                colorize("NicerFrames", NORMAL_FONT_COLOR_CODE) ..
                " - " .. msg
            )
        end
    end
end

-- UI Round Start Handler
-- Place this in a shared location accessible by all gamemodes
RoundStartUI = RoundStartUI or {}

local fadeStartTime = 0
local fadeOutTime = 0
local displayDuration = 5
local currentConfig = nil

-- Role colors
RoundStartUI.Colors = {
    traitor = Color(200, 0, 10, 255),
    innocent = Color(255, 255, 255, 255),
    police = Color(75, 75, 255, 255),
    ct = Color(75, 75, 255, 255),
    default = Color(122, 122, 122, 255)
}

-- Initialize the round start UI
function RoundStartUI.Show(config)
    --[[
    config = {
        gamemode = "Homicide",
        roundType = "Regular Round",
        role = "Traitor",
        roleColor = Color(200, 0, 10),
        description = "You have a silenced USP with two magazines.",
        duration = 5, -- optional, defaults to 5
        sound = "snd_jack_hmcd_shining.mp3" -- optional
    }
    ]]
    
    currentConfig = config
    fadeStartTime = CurTime()
    fadeOutTime = CurTime() + (config.duration or displayDuration)
    
    if config.sound then
        surface.PlaySound(config.sound)
    end
    
    if config.fadeScreen then
        LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 220), 0.5, 4)
    end
end

-- Hide the UI
function RoundStartUI.Hide()
    currentConfig = nil
    fadeStartTime = 0
    fadeOutTime = 0
end

-- Check if UI should be visible
function RoundStartUI.IsVisible()
    return currentConfig and CurTime() < fadeOutTime
end

-- Draw the UI panels
function RoundStartUI.Draw()
    if not RoundStartUI.IsVisible() then return end
    if not currentConfig then return end
    
    local alpha = 255
    local timeLeft = fadeOutTime - CurTime()
    
    -- Fade out in the last second
    if timeLeft < 1 then
        alpha = math.Clamp(timeLeft * 255, 0, 255)
    end
    
    local scrW, scrH = ScrW(), ScrH()
    local panelWidth = scrW * 0.6
    local panelHeight = scrH * 0.08
    local panelSpacing = scrH * 0.02
    local topMargin = scrH * 0.1
    
    -- Top panel background
    local topPanelY = topMargin
    draw.RoundedBox(16, (scrW - panelWidth) / 2, topPanelY, panelWidth, panelHeight, Color(30, 30, 30, alpha * 0.9))
    draw.RoundedBox(14, (scrW - panelWidth) / 2 + 2, topPanelY + 2, panelWidth - 4, panelHeight - 4, Color(45, 45, 45, alpha * 0.8))
    
    -- Bottom panel background
    local bottomPanelY = topMargin + panelHeight + panelSpacing
    draw.RoundedBox(16, (scrW - panelWidth) / 2, bottomPanelY, panelWidth, panelHeight, Color(30, 30, 30, alpha * 0.9))
    draw.RoundedBox(14, (scrW - panelWidth) / 2 + 2, bottomPanelY + 2, panelWidth - 4, panelHeight - 4, Color(45, 45, 45, alpha * 0.8))
    
    -- Role color accent (thin line at top of panels)
    local accentColor = Color(currentConfig.roleColor.r, currentConfig.roleColor.g, currentConfig.roleColor.b, alpha)
    surface.SetDrawColor(accentColor)
    surface.DrawRect((scrW - panelWidth) / 2 + 10, topPanelY + 5, panelWidth - 20, 3)
    surface.DrawRect((scrW - panelWidth) / 2 + 10, bottomPanelY + 5, panelWidth - 20, 3)
    
    -- Top panel text
    local titleColor = Color(255, 255, 255, alpha)
    local roleColor = Color(currentConfig.roleColor.r, currentConfig.roleColor.g, currentConfig.roleColor.b, alpha)
    
    -- Gamemode title (left side)
    draw.SimpleText(currentConfig.gamemode, "HomigradRoundFont", scrW / 2 - panelWidth / 4, topPanelY + panelHeight / 2, titleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Round type (center)
    if currentConfig.roundType then
        draw.SimpleText(currentConfig.roundType, "HomigradFontBig", scrW / 2, topPanelY + panelHeight / 2, titleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Role (right side)
    draw.SimpleText("You are: " .. currentConfig.role, "HomigradRoundFont", scrW / 2 + panelWidth / 4, topPanelY + panelHeight / 2, roleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Bottom panel text (description)
    draw.SimpleText(currentConfig.description, "HomigradFontBig", scrW / 2, bottomPanelY + panelHeight / 2, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- Hook into HUDPaint
hook.Add("HUDPaint", "RoundStartUI_Draw", function()
    RoundStartUI.Draw()
end)

-- Helper function to get color by role name
function RoundStartUI.GetRoleColor(roleName)
    roleName = string.lower(roleName)
    if string.find(roleName, "traitor") then
        return RoundStartUI.Colors.traitor
    elseif string.find(roleName, "innocent") then
        return RoundStartUI.Colors.innocent
    elseif string.find(roleName, "police") or string.find(roleName, "ct") or string.find(roleName, "swat") then
        return RoundStartUI.Colors.police
    else
        return RoundStartUI.Colors.default
    end
end
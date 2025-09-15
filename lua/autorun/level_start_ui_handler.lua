-- UI Round Start Handler (Vignette + Centered Logo/Text)
-- Drop-in replacement for your previous panel-based handler.

if SERVER then return end

RoundStartUI = RoundStartUI or {}

-- ------- Configurable timings -------
RoundStartUI.fadeIn   = 0.35    -- seconds for vignette fade in
RoundStartUI.hold     = 4.30    -- visible time at full opacity (tweak freely)
RoundStartUI.fadeOut  = 0.35    -- seconds for vignette fade out
RoundStartUI.maxAlpha = 220     -- vignette darkness (0-255). 180-220 looks good.

-- ------- State -------
local startTime     = 0
local endTime       = 0
local currentConfig = nil
local headerMat     = nil
local headerTexW, headerTexH = 0, 0

-- Gradients for the vignette
local gradUp    = Material("vgui/gradient-u")
local gradDown  = Material("vgui/gradient-d")
local gradLeft  = Material("vgui/gradient-l")
local gradRight = Material("vgui/gradient-r")

-- Role colors (same idea as before)
RoundStartUI.Colors = RoundStartUI.Colors or {
    traitor  = Color(200,   0,  10, 255),
    innocent = Color(255, 255, 255, 255),
    police   = Color( 75,  75, 255, 255),
    ct       = Color( 75,  75, 255, 255),
    default  = Color(122, 122, 122, 255)
}

-- Helper: pick role color by name
function RoundStartUI.GetRoleColor(roleName)
    local role = string.lower(roleName or "")
    if string.find(role, "traitor") then return RoundStartUI.Colors.traitor end
    if string.find(role, "innocent") then return RoundStartUI.Colors.innocent end
    if string.find(role, "police") or string.find(role, "ct") or string.find(role, "swat") then
        return RoundStartUI.Colors.police
    end
    return RoundStartUI.Colors.default
end

-- Load a header image material (PNG recommended under materials/vgui/…)
local function loadHeaderMat(path)
    headerMat, headerTexW, headerTexH = nil, 0, 0
    if not path or path == "" then return end

    -- Tip: use PNG in materials/vgui/... and reference with "vgui/..." including extension.
    local mat = Material(path, "smooth mips")
    if not mat or mat:IsError() then return end

    -- Try to read texture size for aspect-correct scaling
    local tex = mat:GetTexture("$basetexture")
    if tex then
        headerTexW = tex:GetMappingWidth()  or 0
        headerTexH = tex:GetMappingHeight() or 0
    end
    headerMat = mat
end

-- Public API: show the intro
-- config = {
--   gamemode = "Homicide",
--   roundType = "Regular Round",
--   role = "Traitor",
--   roleColor = Color(...),           -- optional; falls back to GetRoleColor(role)
--   description = "Your intro text",  -- optional
--   duration = 5,                     -- optional; overrides hold time if set
--   sound = "path/to/sound.mp3",      -- optional
--   headerImage = "vgui/fmt/logo.png" -- optional PNG under materials/vgui/...
-- }
function RoundStartUI.Show(config)
    currentConfig = config or {}

    -- Timing
    startTime = CurTime()
    local hold = currentConfig.duration or RoundStartUI.hold
    endTime   = startTime + RoundStartUI.fadeIn + hold + RoundStartUI.fadeOut

    -- Audio
    if currentConfig.sound then
        surface.PlaySound(currentConfig.sound)
    end

    -- Optional ScreenFade if you were using it, but vignette handles visuals now.
    if currentConfig.fadeScreen then
        LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 0), 0, 0) -- no-op
    end
end

function RoundStartUI.Hide()
    currentConfig = nil
    startTime = 0
    endTime   = 0
end

function RoundStartUI.IsVisible()
    return currentConfig ~= nil and CurTime() < endTime
end

-- Smoothstep for pleasant easing
local function smooth01(t) return t * t * (3 - 2 * t) end

-- Draw vignette (four edges using gradients)
local function drawVignette(alpha)
    local w, h = ScrW(), ScrH()
    local edge = math.floor(math.min(w, h) * 0.22) -- thickness of vignette

    surface.SetDrawColor(0, 0, 0, alpha)

    -- Top / Bottom
    surface.SetMaterial(gradUp)
    surface.DrawTexturedRect(0, 0, w, edge)

    surface.SetMaterial(gradDown)
    surface.DrawTexturedRect(0, h - edge, w, edge)

    -- Left / Right
    surface.SetMaterial(gradLeft)
    surface.DrawTexturedRect(0, 0, edge, h)

    surface.SetMaterial(gradRight)
    surface.DrawTexturedRect(w - edge, 0, edge, h)
end

-- Centered text helper (with outline for readability)
local function centeredText(text, font, y, color, outline)
    local w = ScrW()
    draw.SimpleTextOutlined(text, font, w * 0.5, y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, outline or 2, Color(0,0,0, color.a))
end

-- Main draw
function RoundStartUI.Draw()
    if not RoundStartUI.IsVisible() or not currentConfig then return end

    local now     = CurTime()
    local elapsed = now - startTime
    local total   = endTime - startTime

    -- Calculate current alpha phase (0->1 fade in, 1 hold, 1->0 fade out)
    local a
    if elapsed < RoundStartUI.fadeIn then
        a = smooth01(math.Clamp(elapsed / RoundStartUI.fadeIn, 0, 1))
    elseif now > endTime - RoundStartUI.fadeOut then
        local t = math.Clamp((endTime - now) / RoundStartUI.fadeOut, 0, 1)
        a = smooth01(t)
    else
        a = 1
    end

    local vignetteAlpha = math.Clamp(math.floor(RoundStartUI.maxAlpha * a), 0, 255)

    -- Draw vignette
    drawVignette(vignetteAlpha)

    -- Derive colors
    local baseAlpha = math.Clamp(math.floor(255 * a), 0, 255)
    local titleCol  = Color(255, 255, 255, baseAlpha)
    local roleCol   = currentConfig.roleColor or RoundStartUI.GetRoleColor(currentConfig.role or "")
    roleCol = Color(roleCol.r, roleCol.g, roleCol.b, baseAlpha) -- apply alpha

    -- Layout
    local sw, sh  = ScrW(), ScrH()
    local y       = sh * 0.44   -- center-ish anchor
    local gap     = sh * 0.045  -- vertical spacing

    -- Text fallback if no image
    centeredText(tostring(currentConfig.gamemode or ""), "HomigradFontBig", y - gap, titleCol)

    -- Round type (neutral)
    if currentConfig.roundType and currentConfig.roundType ~= "" then
        centeredText("Round Type: "..tostring(currentConfig.roundType), "HomigradFontBig", y + gap * 0.2, titleCol)
        y = y + gap
    end

    -- Role line (color-coded)
    if currentConfig.role and currentConfig.role ~= "" then
        centeredText("Your Role: " .. tostring(currentConfig.role), "HomigradRoundFont", y + gap * 0.2, roleCol)
        y = y + gap
    end

    -- Description (neutral)
    if currentConfig.description and currentConfig.description ~= "" then
        centeredText(tostring(currentConfig.description), "HomigradFontBig", y + gap * 0.2, titleCol)
    end
end

hook.Add("HUDPaint", "RoundStartUI_Draw", function()
    RoundStartUI.Draw()
end)
    
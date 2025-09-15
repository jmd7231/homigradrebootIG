include("shared.lua")

surface.CreateFont("HomigradFont",{
	font = "Roboto",
	size = 18,
	weight = 1100,
	outline = false
})



surface.CreateFont("HomigradFontBig",{
	font = "Roboto",
	size = 25,
	weight = 1100,
	outline = false,
	shadow = true
})

surface.CreateFont("HomigradFontNotify",{
	font = "Roboto",
	size = ScreenScale(20),
	weight = 1100,
	outline = false
})

surface.CreateFont("HomigradFontBigger",{
	font = "Roboto",
	size = 24,
	weight = 1100,
	outline = false
})

surface.CreateFont("HomigradRoundFont",{
	font = "Roboto",
	size = ScreenScale(18),
	weight = 1100,
	outline = false
})

surface.CreateFont("HomigradFontLarge",{
	font = "Roboto",
	size = ScreenScale(30),
	weight = 1100,
	outline = false
})

surface.CreateFont("HomigradFontSmall",{
	font = "Roboto",
	size = ScreenScale(10),
	weight = 1100,
	outline = false
})

-- Harrisons puts ConVar in worst script, asked to leave
CreateClientConVar("hg_scopespeed","0.5",true,false,"Changes the speed of the sniper scope when zoomed in.",0,5)
CreateClientConVar("hg_usecustommodel","false",true,true,"Allows usage of custom models.")


-- For player models!!
local validUserGroup = {
	servermanager = true,
	owner = true,
	superadmin = true,
	admin = true,
	operator = true,
	tmod = true,
	sponsor = true,
	supporterplus = false,
	supporter = false,
	regular = false,
	user = false,
}

net.Receive("round_active",function(len)
	roundActive = net.ReadBool()
	roundTimeStart = net.ReadFloat()
	roundTime = net.ReadFloat()
end)

local view = {}

hook.Add("PreCalcView","spectate",function(lply,pos,ang,fov,znear,zfar)
	lply = LocalPlayer()
	if lply:Alive() or GetViewEntity() ~= lply then return end

	view.fov = CameraSetFOV

	local spec = lply:GetNWEntity("HeSpectateOn")
	if not IsValid(spec) then
		view.origin = lply:EyePos()
		view.angles = ang

		return view
	end

	spec = IsValid(spec:GetNWEntity("Ragdoll")) and spec:GetNWEntity("Ragdoll") or spec

	local dir = Vector(1,0,0)
	dir:Rotate(ang)
	local tr = {}

	local head = spec:LookupBone("ValveBiped.Bip01_Head1")
	tr.start = head and spec:GetBonePosition(head) or spec:EyePos()
	tr.endpos = tr.start - dir * 75
	tr.filter = {lply,spec,lply:GetVehicle()}

	view.origin = util.TraceLine(tr).HitPos
	view.angles = ang

	return view
end)

SpectateHideNick = SpectateHideNick or false

local keyOld,keyOld2
local lply
flashlight = flashlight or nil
flashlightOn = flashlightOn or false

local gradient_d = Material("vgui/gradient-d")

hook.Add("HUDPaint","spectate",function()
	local lply = LocalPlayer()
	
	local spec = lply:GetNWEntity("HeSpectateOn")

	if lply:Alive() then
		if IsValid(flashlight) then
			flashlight:Remove()
			flashlight = nil
		end
	end

	local result = lply:PlayerClassEvent("CanUseSpectateHUD")
	if result == false then return end



	if
		(((not lply:Alive() or lply:Team() == 1002 or spec and lply:GetObserverMode() != OBS_MODE_NONE) or lply:GetMoveType() == MOVETYPE_NOCLIP)
		and not lply:InVehicle()) or result or hook.Run("CanUseSpectateHUD")
	then
		local ent = spec

		if IsValid(ent) then
			surface.SetFont("HomigradFont")
			local tw = surface.GetTextSize(ent:GetName())
			draw.SimpleText(ent:GetName(),"HomigradFont",ScrW() / 2 - tw / 2,ScrH() - 100,TEXT_ALING_CENTER,TEXT_ALING_CENTER)
			tw = surface.GetTextSize("Health: " .. ent:Health())
			draw.SimpleText("Health: " .. ent:Health(),"HomigradFont",ScrW() / 2 - tw / 2,ScrH() - 75,TEXT_ALING_CENTER,TEXT_ALING_CENTER)

			local func = TableRound().HUDPaint_Spectate
			if func then func(ent) end
		end

		local key = lply:KeyDown(IN_WALK)
		if keyOld ~= key and key then
			SpectateHideNick = not SpectateHideNick

			--chat.AddText("Ники игроков: " .. tostring(not SpectateHideNick))
		end
		keyOld = key

		draw.SimpleText("Enable / Disable Names in Spectator with ALT","HomigradFont",15,ScrH() - 15,showRoundInfoColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_BOTTOM)

		local key = input.IsButtonDown(KEY_F)
		if not lply:Alive() and keyOld2 ~= key and key then
			flashlightOn = not flashlightOn

			if flashlightOn then
				if not IsValid(flashlight) then
					flashlight = ProjectedTexture()
					flashlight:SetTexture("effects/flashlight001")
					flashlight:SetFarZ(900)
					flashlight:SetFOV(70)
					flashlight:SetEnableShadows( false )
				end
			else
				if IsValid(flashlight) then
					flashlight:Remove()
					flashlight = nil
				end
			end
		end
		keyOld2 = key

		if flashlight then
			flashlight:SetPos(EyePos())
			flashlight:SetAngles(EyeAngles())
			flashlight:Update()
		end

		if not SpectateHideNick then
			local func = TableRound().HUDPaint_ESP
			if func then func() end

			for _, v in ipairs(player.GetAll()) do --ESP
				if !v:Alive() or v == ent then continue end

				local ent = IsValid(v:GetNWEntity("Ragdoll")) and v:GetNWEntity("Ragdoll") or v
				local screenPosition = ent:GetPos():ToScreen()
				local x, y = screenPosition.x, screenPosition.y
				local teamColor = v:GetPlayerColor():ToColor()
				local distance = lply:GetPos():Distance(v:GetPos())
				local factor = 1 - math.Clamp(distance / 1024, 0, 1)
				local size = math.max(10, 32 * factor)
				local alpha = math.max(255 * factor, 80)

				local text = v:Name()
				surface.SetFont("Trebuchet18")
				local tw, th = surface.GetTextSize(text)

				surface.SetDrawColor(teamColor.r, teamColor.g, teamColor.b, alpha * 0.5)
				surface.SetMaterial(gradient_d)
				surface.DrawTexturedRect(x - size / 2 - tw / 2, y - th / 2, size + tw, th)

				surface.SetTextColor(255, 255, 255, alpha)
				surface.SetTextPos(x - tw / 2, y - th / 2)
				surface.DrawText(text)

				local barWidth = math.Clamp((v:Health() / 150) * (size + tw), 0, size + tw)
				local healthcolor = v:Health() / 150 * 255

				surface.SetDrawColor(255, healthcolor, healthcolor, alpha)
				surface.DrawRect(x - barWidth / 2, y + th / 1.5, barWidth, ScreenScale(1))
			end
		end
	end
end)

hook.Add("HUDDrawTargetID","no",function() return false end)

local laserweps = {
	["weapon_xm1014"] = true,
	["weapon_p90"] = true,
	["weapon_m249"] = true,
	["weapon_p99"] = true,
	["weapon_hk_usp"] = true,
	["weapon_hk416"] = true,
	["weapon_p99"] = true,
	--["weapon_hk_usps"] = true,
	["weapon_m4a1"] = true,
	["weapon_ar15"] = true,
	["weapon_m3super"] = true,
	["weapon_mp7"] = true,
	["weapon_p220"] = true,
	["weapon_galil"] = true,
	["weapon_mateba"] = true,
	["weapon_beanbag"] = true,
	["weapon_glock"] = true,
--	["weapon_hg_crossbow"] = true
}
laserplayers = laserplayers or {}
local mat = Material("sprites/bluelaser1")
local mat2 = Material("Sprites/light_glow02_add_noz")
hook.Add("PostDrawOpaqueRenderables", "laser", function()
	for i,ply in pairs(laserplayers) do
		if not IsValid(ply) then laserplayers[i] = nil end
		ply.Laser = ply.Laser or false
		local wep = ply:GetActiveWeapon()
		wep = IsValid(wep) and wep or ply:GetNWEntity("ActiveWeapon")
		if IsValid(wep) and IsValid(ply) and ply.Laser and not ply:GetNWInt("unconscious") and laserweps[wep:GetClass()] then			
			if not IsValid(wep) then continue end
			
			local pos, ang = wep:GetTrace()
			
			local t = {}

			t.start = pos + ang:Right() * 0 + ang:Forward() * -5 + ang:Up() * -0.5
			
			t.endpos = t.start + ang:Forward() * 9000
			
			t.filter = {ply,wep,LocalPlayer(),ply:GetNWEntity("Ragdoll"),ply:GetNWEntity("ragdollWeapon")}
			t.mask = MASK_SOLID
			local tr = util.TraceLine(t)
			
			local angle = (tr.StartPos - tr.HitPos):Angle()
			
			cam.Start3D(EyePos(),EyeAngles())

			render.SetMaterial(mat)
			render.DrawBeam(tr.StartPos, tr.HitPos, 1, 0, 15.5, Color(255, 0, 0))
			
			local Size = math.random(3,4)
			render.SetMaterial(mat2)
			local tra = util.TraceLine({
				start = tr.HitPos - (tr.HitPos - EyePos()):GetNormalized(),
				endpos = EyePos(),
				filter = {LocalPlayer(),ply,wep,ply:GetNWEntity("Ragdoll"),ply:GetNWEntity("ragdollWeapon")},
				mask = MASK_SHOT
			})

			if not tra.Hit then
				render.DrawSprite(tr.HitPos, Size, Size,Color(255,0,0))
			end
			--render.DrawQuadEasy(tr.HitPos, (tr.StartPos - tr.HitPos):GetNormal(), Size, Size, Color(255,0,0), 0)

			cam.End3D()
		end
	end
end)

local function PlayerModelMenu()
	local newv = list.Get( "DesktopWindows" )[ "PlayerEditor" ]

	local Window = vgui.Create( "DFrame" )
	Window:SetSize( newv.width, newv.height )
	Window:SetTitle( newv.title )
	Window:Center()
	Window:MakePopup()

	newv.init( nil, Window )
end






-- =======================================
-- HG Subtitle System v2 (clientside)
-- Command: hg_subtitle "Your text", dark|red
-- Toggle : hg_displaysubtitle 1/0
-- Features:
--  - 3x font size (auto-scaled by resolution)
--  - Themes (dark/red). Red text ~matches background (low contrast).
--  - Multiple subtitles at once with smooth stacking (new at bottom, old rise up)
--  - Quick fade-in → hold → slow fade-out
-- =======================================

-- Core timings & layout
local HGSub = {
    FADE_IN     = 0.15,   -- seconds (quick)
    HOLD        = 3.25,   -- seconds
    FADE_OUT    = 1.20,   -- seconds (slower)
    BOTTOM_GAP  = 180,    -- px from bottom of screen
    PAD_X       = 24,     -- box horizontal padding
    PAD_Y       = 14,     -- box vertical padding
    WIDTH_FRAC  = 0.85,   -- max width vs screen width
    STACK_GAP   = 10,     -- vertical space between stacked subtitles
    RISE_SPEED  = 12,     -- higher = snappier vertical easing
    items       = {}      -- active subtitles (can overlap in time)
}

-- Toggle cvar
CreateClientConVar("hg_displaysubtitle", "1", true, false, "Show subtitles (1=true, 0=false)")

-- Themes (arg2). Add more as needed.
HGSub.themes = {
    -- Black/grey look
    dark = {
        bg        = Color(0,   0,   0,   220),
        text      = Color(220, 220, 220, 255),
        fontFace  = "Trebuchet MS"
    },
    -- Red look: text is nearly the same as bg (very low contrast by design)
    red = {
        bg        = Color(160, 20,  20,  230),
        text      = Color(255, 255,  255,  255), -- ~matches bg
        fontFace  = "Trebuchet MS"
    }
}

-- ====== Fonts (3x bigger, per-theme, cached) ======
-- Base size was ~28px → now 28 * 3 = 84 (and still scales with resolution)
local HGSub_FontCache = {}
local function HGSub_GetFontName(themeKey)
    local scale = math.Clamp(ScrH() / 1080, 0.75, 1)
    local size  = math.floor(84 * scale)  -- 3x
    local theme = HGSub.themes[themeKey] or HGSub.themes.dark
    local face  = theme.fontFace or "Trebuchet MS"
    local key   = string.format("HG_Subtitle_%s_%d", themeKey, size)

    if not HGSub_FontCache[key] then
        surface.CreateFont(key, {
            font      = face,
            size      = size,
            weight    = 900,
            antialias = true,
            extended  = true
        })
        HGSub_FontCache[key] = true
    end
    return key
end

hook.Add("OnScreenSizeChanged", "HGSub_RebuildFonts", function()
    -- Rebuild cache markers so fonts get recreated at the new size
    HGSub_FontCache = {}
end)

-- ====== Helpers ======
local function trimQuotes(s)
    if not s then return s end
    s = s:Trim()
    s = s:gsub('^"(.*)"$', "%1")
    s = s:gsub("^'(.*)'$", "%1")
    return s
end

local function parseArgs(argStr, args)
    if isstring(argStr) and argStr:find(",") then
        local a1, a2 = argStr:match("^%s*(.-)%s*,%s*(.-)%s*$")
        return trimQuotes(a1), trimQuotes(a2)
    else
        return trimQuotes(args[1]), trimQuotes(args[2])
    end
end

-- Measure using a specific font
local function textSize(fontName, s)
    surface.SetFont(fontName)
    return surface.GetTextSize(s or "")
end

-- Word-wrap to width with a specific font
local function wrapToWidth(fontName, text, maxW)
    surface.SetFont(fontName)
    local words = string.Explode(" ", text or "")
    local lines, line = {}, ""
    for i = 1, #words do
        local test = (line == "" and words[i]) or (line .. " " .. words[i])
        local w = surface.GetTextSize(test)
        if w > maxW and line ~= "" then
            table.insert(lines, line)
            line = words[i]
        else
            line = test
        end
    end
    if line ~= "" then table.insert(lines, line) end
    return lines
end

-- ====== Creation & command ======
local function addSubtitle(text, themeKey)
    local cv = GetConVar("hg_displaysubtitle")
    if cv and not cv:GetBool() then return end

    themeKey = (themeKey or "dark"):lower()
    local theme = HGSub.themes[themeKey] or HGSub.themes.dark
    local font  = HGSub_GetFontName(themeKey)
    local maxBoxW = math.floor(ScrW() * HGSub.WIDTH_FRAC)

    -- Precompute lines & box size for this item (font-specific)
    local textW = textSize(font, text)
    local lines
    if textW > (maxBoxW - HGSub.PAD_X * 2) then
        lines = wrapToWidth(font, text, maxBoxW - HGSub.PAD_X * 2)
    else
        lines = { text }
    end

    local maxLineW, _, lineH = 0, 0, select(2, textSize(font, "Ay"))
    for _, ln in ipairs(lines) do
        local w = textSize(font, ln)
        if w > maxLineW then maxLineW = w end
    end

    local boxW = math.min(maxBoxW, maxLineW + HGSub.PAD_X * 2)
    local boxH = (#lines * lineH) + HGSub.PAD_Y * 2

    -- Create the item
    local item = {
        text    = text,
        lines   = lines,
        theme   = theme,
        font    = font,
        boxW    = boxW,
        boxH    = boxH,
        t0      = RealTime(),   -- start time
        y       = nil,          -- animated y (set on first layout)
        targetY = nil           -- target y computed each frame by layout
    }
    table.insert(HGSub.items, item)
end

concommand.Add("hg_subtitle", function(_, _, args, argStr)
    local text, theme = parseArgs(argStr, args)
    if not text or text == "" then return end
    addSubtitle(text, theme)
end)

-- ====== Draw & animate ======
hook.Add("HUDPaint", "HGSub_Draw_v2", function()
    local cv = GetConVar("hg_displaysubtitle")
    if not (cv and cv:GetBool()) then return end
    if #HGSub.items == 0 then return end

    -- Remove expired, compute durations
    local now = RealTime()
    for i = #HGSub.items, 1, -1 do
        local it = HGSub.items[i]
        local dt = now - it.t0
        if dt >= (HGSub.FADE_IN + HGSub.HOLD + HGSub.FADE_OUT) then
            table.remove(HGSub.items, i)
        end
    end
    if #HGSub.items == 0 then return end

    -- Sort oldest → newest so newest ends up on the bottom row
    table.sort(HGSub.items, function(a,b) return a.t0 < b.t0 end)

    -- Compute target Y positions from bottom up
    local yCursor = ScrH() - HGSub.BOTTOM_GAP
    for i = #HGSub.items, 1, -1 do
        local it = HGSub.items[i]
        yCursor = yCursor - it.boxH
        it.targetY = yCursor
        yCursor = yCursor - HGSub.STACK_GAP
        -- Initialize y slightly below target (so it eases upward)
        if not it.y then it.y = it.targetY + 30 end
    end

    -- Draw each item (oldest first so newer overlays slightly)
    for _, it in ipairs(HGSub.items) do
        -- Vertical easing
        it.y = Lerp(FrameTime() * HGSub.RISE_SPEED, it.y, it.targetY)

        -- Alpha based on lifetime
        local dt = now - it.t0
        local a
        if dt < HGSub.FADE_IN then
            a = dt / HGSub.FADE_IN
        elseif dt < HGSub.FADE_IN + HGSub.HOLD then
            a = 1
        else
            local outT = dt - (HGSub.FADE_IN + HGSub.HOLD)
            a = 1 - math.Clamp(outT / HGSub.FADE_OUT, 0, 1)
        end

        local bg = it.theme.bg
        local fg = it.theme.text
        local bgA = math.Clamp(math.floor((bg.a or 255) * a), 0, 255)
        local fgA = math.Clamp(math.floor((fg.a or 255) * a), 0, 255)

        local x = math.floor((ScrW() - it.boxW) * 0.5)
        local y = math.floor(it.y)

        -- Box (sharp corners)
        surface.SetDrawColor(bg.r, bg.g, bg.b, bgA)
        surface.DrawRect(x, y, it.boxW, it.boxH)

        -- Optional subtle outline
        surface.SetDrawColor(255, 255, 255, math.floor(10 * a))
        surface.DrawOutlinedRect(x, y, it.boxW, it.boxH, 1)

        -- Text lines centered
        surface.SetFont(it.font)
        local _, lineH = surface.GetTextSize("Ay")
        local ty = y + HGSub.PAD_Y
        for _, ln in ipairs(it.lines) do
            local tw = surface.GetTextSize(ln)
            local tx = x + math.floor((it.boxW - tw) * 0.5)
            draw.SimpleText(ln, it.font, tx, ty, Color(fg.r, fg.g, fg.b, fgA), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            ty = ty + lineH
        end
    end
end)

-- =======================================
-- Examples you can try in console:
--   hg_subtitle "Hello there!", dark
--   hg_subtitle "WARNING: Enemy spotted!", red
--   hg_displaysubtitle 0   (hide all)
--   hg_displaysubtitle 1   (show again)
-- =======================================





-- === HG Context-Menu Panel v5.2 (vertical list, icons-left, white text, auto-close) ===

local hg_ContextUI, hg_Box, hg_List

-- ---- SCALE (2x everything) ----
local SCALE         = 2

-- Layout constants (base values × SCALE)
local BOX_PAD       = 16   * SCALE
local ROW_GAP       = 10   * SCALE
local BTN_HEIGHT    = 36   * SCALE
local BTN_HPAD      = 12   * SCALE
local BTN_MARGIN    = 8    * SCALE
local BTN_MIN_W     = 120  * SCALE
local BTN_RADIUS    = 10   * SCALE

-- Icon sizing/spacing
local ICON_SIZE     = math.floor(BTN_HEIGHT * 0.65)  -- icon height ~= 65% of the button
local ICON_GAP      = 10 * SCALE                     -- space between icon and text

-- We cap the box width to 90% of screen or 1400px (scaled)
local function BOX_MAX_W() return math.min(1400 * (SCALE/2), ScrW() * 0.9) end

-- Colors
local WHITE   = Color(255,255,255)
local BG_DARK = Color(0,0,0,180)
local BTN_BG      = Color(25,25,25,230)
local BTN_BG_HOV  = Color(50,50,50,245)
local BTN_BG_DOWN = Color(35,35,35,245)

-- Fonts (explicit sizes at 2x)
surface.CreateFont("HG_Header", {font="Roboto", size=48, weight=900})
surface.CreateFont("HG_Btn",    {font="Roboto", size=36, weight=800})

local function HG_TextW(font, s)
    surface.SetFont(font)
    local w = select(1, surface.GetTextSize(s or ""))
    return w
end

local function HG_CloseContext()
    if input.IsKeyDown(KEY_C) then RunConsoleCommand("-menu_context") end
    CloseDermaMenus()
    gui.EnableScreenClicker(false)
    if IsValid(hg_ContextUI) then hg_ContextUI:Remove() end
end

-- NEW: supports an optional icon (string path like "icon16/cog.png")
local function HG_AddBtn(parent, label, onclick, iconPath)
    local btn = vgui.Create("DButton", parent)
    btn:SetText("")               -- we draw the label (white) ourselves
    btn:SetCursor("hand")
    btn:SetTall(BTN_HEIGHT)

    local tw = HG_TextW("HG_Btn", label or "")
    local contentW = tw
    local iconMat

    if iconPath and iconPath ~= "" then
        iconMat = Material(iconPath, "noclamp smooth")
        contentW = ICON_SIZE + ICON_GAP + tw
    end

    btn:SetWide(math.max(BTN_MIN_W, BTN_HPAD * 2 + contentW))

    btn.Paint = function(self, w, h)
        local bg = self:IsDown() and BTN_BG_DOWN
               or (self:IsHovered() and BTN_BG_HOV or BTN_BG)
        draw.RoundedBox(BTN_RADIUS, 0, 0, w, h, bg)

        -- center the combined [icon + text] block
        local cx = (w - contentW) * 0.5
        local tx = cx
        if iconMat then
            local iy = math.floor((h - ICON_SIZE) * 0.5)
            surface.SetMaterial(iconMat)
            surface.SetDrawColor(255,255,255,255)
            surface.DrawTexturedRect(cx, iy, ICON_SIZE, ICON_SIZE)
            tx = cx + ICON_SIZE + ICON_GAP
        end

        draw.SimpleText(label, "HG_Btn", tx, h * 0.5, WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    btn.DoClick = function()
        if onclick then onclick() end
        surface.PlaySound("UI/buttonclickrelease.wav")
        HG_CloseContext()
    end
    return btn
end

local function HG_BuildContextUI()
    if IsValid(hg_ContextUI) then hg_ContextUI:Remove() end

    -- Top-level overlay (doesn't eat input itself)
    hg_ContextUI = vgui.Create("EditablePanel")
    hg_ContextUI:SetSize(ScrW(), ScrH())
    hg_ContextUI:SetPos(0, 0)
    hg_ContextUI:SetDrawOnTop(true)
    hg_ContextUI:SetMouseInputEnabled(false)
    hg_ContextUI:SetKeyboardInputEnabled(false)

    -- Centered box
    hg_Box = vgui.Create("EditablePanel", hg_ContextUI)
    hg_Box:SetMouseInputEnabled(true)
    hg_Box:SetKeyboardInputEnabled(false)
    hg_Box.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, BG_DARK)
    end

    -- Header (centered)
    local lblHeader = vgui.Create("DLabel", hg_Box)
    lblHeader:SetFont("HG_Header")
    lblHeader:SetTextColor(WHITE)
    lblHeader:SetText("Player Menu")
    lblHeader:SetContentAlignment(5) -- center

    -- Vertical list container
    hg_List = vgui.Create("EditablePanel", hg_Box)
    hg_List:SetMouseInputEnabled(true)

    -- Vertical layout: center each button horizontally, stack top→bottom
    function hg_List:PerformLayout()
        local maxW = 0
        for _, c in ipairs(self:GetChildren()) do
            maxW = math.max(maxW, c:GetWide())
        end
        maxW = math.min(maxW, BOX_MAX_W() - BOX_PAD * 2)

        local y = 0
        for _, c in ipairs(self:GetChildren()) do
            c:SetWide(maxW)                        -- uniform width
            c:SetPos((hg_Box:GetWide() - maxW) * 0.5, y)  -- centered
            c:SetTall(BTN_HEIGHT)
            y = y + BTN_HEIGHT + BTN_MARGIN
        end
        self:SetSize(hg_Box:GetWide(), y - BTN_MARGIN)
    end

    -- Overall box layout (center on screen)
    function hg_Box:PerformLayout()
        local w = math.min(BOX_MAX_W(), ScrW() * 0.9)
        self:SetWide(w / 4)

        local y = BOX_PAD

        lblHeader:SetWide(w / 4)
        lblHeader:SizeToContentsY()
        lblHeader:SetPos(0, y)
        y = y + lblHeader:GetTall() + (6 * SCALE)

        hg_List:SetPos(0, y)
        hg_List:SetWide(w)
        hg_List:InvalidateLayout(true)
        y = y + hg_List:GetTall() + BOX_PAD

        self:SetTall(y)
        self:SetPos((ScrW() - self:GetWide()) * 0.5, (ScrH() - self:GetTall()) * 0.5)
    end

    -- ----- BUTTONS (vertical + icons-left) -----
    -- New: Game Settings (runs hg_gamesettings)
    HG_AddBtn(hg_List, "Game Settings", function() RunConsoleCommand("hg_gamesettings") end, "icon16/cog.png")

    HG_AddBtn(hg_List, "Armor Menu", function()
        RunConsoleCommand("jmod_ez_inv")
    end, "icon16/shield.png")

    HG_AddBtn(hg_List, "Ammo Menu",  function()
        RunConsoleCommand("hg_ammomenu")
    end, "icon16/bullet_black.png")

    HG_AddBtn(hg_List, "Player Model", function()
        RunConsoleCommand("hg_appearance_menu")
    end, "icon16/user.png")

    local EZarmor = LocalPlayer().EZarmor
    if JMod and JMod.GetItemInSlot and JMod.GetItemInSlot(EZarmor, "eyes") then
        HG_AddBtn(hg_List, "Toggle Mask/Helmet Visor", function()
            RunConsoleCommand("jmod_ez_toggleeyes")
        end, "icon16/eye.png")
    end

    local lply = LocalPlayer()
    local wep  = IsValid(lply:GetActiveWeapon()) and lply:GetActiveWeapon() or lply:GetNWEntity("ActiveWeapon")
    if IsValid(wep) then
        if wep:GetClass() ~= "weapon_hands" then
            HG_AddBtn(hg_List, "Drop Weapon", function()
                LocalPlayer():ConCommand("say *drop")
            end, "icon16/arrow_down.png")
        end
        if wep.Clip1 and wep:Clip1() > 0 then
            HG_AddBtn(hg_List, "Unload Magazine", function()
                net.Start("Unload") net.WriteEntity(wep) net.SendToServer()
            end, "icon16/arrow_refresh.png")
        end
        if laserweps[wep:GetClass()] then
            HG_AddBtn(hg_List, "Laser On/Off", function()
                local on = not LocalPlayer().Laser
                LocalPlayer().Laser = on
                net.Start("lasertgg") net.WriteBool(on) net.SendToServer()
                LocalPlayer():EmitSound(on and "items/nvg_on.wav" or "items/nvg_off.wav")
            end, "icon16/lightbulb.png")
        end
    end

    -- Finalize & ensure focus
    hg_Box:InvalidateLayout(true)
    timer.Simple(0, function()
        if IsValid(hg_Box) then
            hg_Box:MakePopup()
            hg_Box:MoveToFront()
        end
    end)
end

hook.Add("OnContextMenuOpen",  "HG_ShowContextUI",  HG_BuildContextUI)
hook.Add("OnContextMenuClose", "HG_HideContextUI", function()
    if IsValid(hg_ContextUI) then hg_ContextUI:Remove() end
end)
hook.Add("OnScreenSizeChanged","HG_ContextUI_Resize", function()
    if IsValid(hg_ContextUI) and IsValid(hg_Box) then
        hg_ContextUI:SetSize(ScrW(), ScrH())
        hg_Box:InvalidateLayout(true)
    end
end)
-- === end v5.2 ===





net.Receive("lasertgg",function(len)
	local ply = net.ReadEntity()
	local boolen = net.ReadBool()
	if boolen then
		laserplayers[ply:EntIndex()] = ply
	else
		laserplayers[ply:EntIndex()] = nil
	end
	ply.Laser = boolen
end)

hook.Add("OnEntityCreated", "homigrad-colorragdolls", function(ent)
	if ent:IsRagdoll() then
		timer.Create("ragdollcolors-timer" .. tostring(ent), 0.1, 10, function()

			if IsValid(ent) then
				local owner = RagdollOwner(ent)

				local plr_clr
				if owner then
					plr_clr = owner:GetPlayerColor()
				end

				ent.playerColor = ent:GetNWVector("plycolor", plr_clr) or plr_clr
				
				ent.GetPlayerColor = function()
					return ent.playerColor
				end
				timer.Remove("ragdollcolors-timer" .. tostring(ent))
			end
		end)
	end
end)

local function GetClipForCurrentWeapon( ply )
	if ( !IsValid( ply ) ) then return -1 end

	local wep = ply:GetActiveWeapon()
	if ( !IsValid( wep ) ) then return -1 end

	return wep:Clip1(), wep:GetMaxClip1(), ply:GetAmmoCount( wep:GetPrimaryAmmoType() )
end

hook.Add("HUDShouldDraw","HideHUD_ammo",function(name)
    if name == "CHudAmmo" then return false end
end)

local clipcolor = color_white
local clipcolorlow = Color(247, 178, 40, 255)
local clipcolorempty = Color(247, 40, 40, 255)
local colorgray = Color(200, 200, 200)
local shadow = color_black

--[[hook.Add("HUDPaint","homigrad-fancyammo",function()
	--[[local ply = LocalPlayer()
	local clip, maxclip, ammo = GetClipForCurrentWeapon(ply)
	local clipstring = tostring(clip)
	local sw, sh = ScrW(), ScrH()
	if clip != -1 and maxclip > 0 then
		if oldclip != clip then
			randomx = math.random(0, 10)
			randomy = math.random(0, 10)
			timer.Simple(0.15, function()
				oldclip = clip
			end)
		else
			randomx = 0
			randomy = 0
		end

		if clip == 0 then
			clipcolor = clipcolorempty
		elseif maxclip / clip >= 6 or clip == 1 and maxclip != 1 then
			clipcolor = clipcolorlow
		else
			clipcolor = color_white
		end

		draw.SimpleText("/ " .. ammo, "HomigradFontSmall", sw * 0.9 + 2 + #clipstring * sw * 0.02, sh * 0.97 + 2, shadow)
		draw.SimpleText("/ " .. ammo, "HomigradFontSmall", sw * 0.9 + #clipstring * sw * 0.02, sh * 0.97, colorgray)

		draw.SimpleText(clip, "HomigradFontLarge", sw * 0.89 + 5 + randomx, sh * 0.92 + 5 + randomy, shadow)
		draw.SimpleText(clip, "HomigradFontLarge", sw * 0.89 + randomx, sh * 0.92 + randomy, clipcolor)
	end
end)
]]
net.Receive("remove_jmod_effects",function(len)
	LocalPlayer().EZvisionBlur = 0
	LocalPlayer().EZflashbanged = 0
end)

local meta = FindMetaTable("Player")

function meta:HasGodMode() return self:GetNWBool("HasGodMode") end

concommand.Add("hg_getentity",function()
	local ent = LocalPlayer():GetEyeTrace().Entity
	print(ent)
	if not IsValid(ent) then return end
	print(ent:GetModel())
	print(ent:GetClass())
end)

gameevent.Listen("player_spawn")
hook.Add("player_spawn","gg",function(data)
	--[[local ply = Player(data.userid)

	if ply.SetHull then
		ply:SetHull(ply:GetNWVector("HullMin"),ply:GetNWVector("Hull"))
		ply:SetHullDuck(ply:GetNWVector("HullMin"),ply:GetNWVector("HullDuck"))
	end

	hook.Run("Player Spawn",ply)--]]
end)

hook.Add("DrawDeathNotice","no",function() return false end)

function GM:MouthMoveAnimation( ply )
	local ent = IsValid(ply:GetNWEntity("Ragdoll")) and ply:GetNWEntity("Ragdoll") or ply
	
	local flexes = {
		ent:GetFlexIDByName( "jaw_drop" ),
		ent:GetFlexIDByName( "left_part" ),
		ent:GetFlexIDByName( "right_part" ),
		ent:GetFlexIDByName( "left_mouth_drop" ),
		ent:GetFlexIDByName( "right_mouth_drop" )
	}
	
	local weight = ply:IsSpeaking() and math.Clamp( ply:VoiceVolume() * 6, 0, 6 ) or 0

	for k, v in ipairs( flexes ) do
		ent:SetFlexWeight( v, weight * 4 )
	end

end
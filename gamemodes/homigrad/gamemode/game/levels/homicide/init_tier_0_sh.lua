table.insert(LevelList,"homicide")
homicide = homicide or {}
homicide.Name = "Homicide"

homicide.red = {"Innocent",Color(255,255,255),
    models = tdm.models
}

homicide.teamEncoder = {
    [1] = "red"
}

homicide.RoundRandomDefalut = 6

-- near the top, add a shared constant:
homicide.PREP_TIME = homicide.PREP_TIME or 5


local playsound = false
if SERVER then
    util.AddNetworkString("roundType")
    util.AddNetworkString("homicide_support_arrival")
else
    net.Receive("roundType",function(len)
        homicide.roundType = net.ReadInt(5)
        playsound = true
    end)

    net.Receive("homicide_self_role", function()
        local role = net.ReadString()
        local lply = LocalPlayer()
        if not IsValid(lply) then return end
        lply.roleT = role == "traitor"
        lply.roleCT = role == "ct"
        homicide.roleReady = true
    end)

    local supportArrivalTime = 0

    net.Receive("homicide_support_arrival", function()
        supportArrivalTime = net.ReadFloat()
    end)

    hook.Add("HUDPaint", "DrawSupportArrivalTime", function()
        local lply = LocalPlayer()
        if supportArrivalTime > 0 and not lply:Alive() then
            local timeLeft = math.max(0, supportArrivalTime - CurTime())
            draw.DrawText("You will arrive as support in " .. math.ceil(timeLeft) .. " seconds", "HomigradFontBig", 10, ScrH() - 50, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
        end
    end)

    local traitorLoadoutFrame
    local traitorLoadoutChosen = false

    local function CloseTraitorLoadoutMenu()
        if IsValid(traitorLoadoutFrame) then
            traitorLoadoutFrame:Remove()
        end
    end

    local function SendTraitorLoadout(choice)
        if traitorLoadoutChosen then return end
        traitorLoadoutChosen = true
        net.Start("homicide_traitor_loadout")
        net.WriteString(choice)
        net.SendToServer()
        CloseTraitorLoadoutMenu()
    end

    local function OpenTraitorLoadoutMenu()
        if traitorLoadoutChosen or IsValid(traitorLoadoutFrame) then return end

        local frame = vgui.Create("DFrame")
        traitorLoadoutFrame = frame
        frame:SetTitle("")
        frame:SetSize(720, 360)
        frame:Center()
        frame:MakePopup()
        frame:ShowCloseButton(false)
        frame:SetDraggable(false)

        function frame:Paint(w, h)
            draw.RoundedBox(12, 0, 0, w, h, Color(10, 10, 10, 235))
            draw.RoundedBox(12, 6, 6, w - 12, h - 12, Color(0, 0, 0, 170))
            surface.SetDrawColor(140, 0, 0, 220)
            surface.DrawOutlinedRect(0, 0, w, h, 4)
            draw.SimpleText("STATE OF EMERGENCY", "HomigradRoundFont", w / 2, 48, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Traitor Options", "HomigradFontBig", w / 2, 92, Color(200, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Choose your traitor loadout:", "HomigradFont", w / 2, 132, Color(230, 230, 230, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local btnWidth = 260
        local btnHeight = 70
        local btnY = 210

        local btnVest = vgui.Create("DButton", frame)
        btnVest:SetText("")
        btnVest:SetSize(btnWidth, btnHeight)
        btnVest:SetPos(70, btnY)
        btnVest.Paint = function(self, w, h)
            local bg = self:IsHovered() and Color(160, 0, 0, 245) or Color(110, 0, 0, 235)
            draw.RoundedBox(10, 0, 0, w, h, bg)
            draw.RoundedBox(10, 6, 6, w - 12, h - 12, Color(0, 0, 0, 120))
            draw.SimpleText("Jihadhi Joe", "HomigradFontBig", w / 2, h / 2 - 6, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Suicide Vest", "HomigradFont", w / 2, h / 2 + 20, Color(255, 220, 220, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        btnVest.DoClick = function()
            SendTraitorLoadout("jihadhi_joe")
        end

        local btnBomb = vgui.Create("DButton", frame)
        btnBomb:SetText("")
        btnBomb:SetSize(btnWidth, btnHeight)
        btnBomb:SetPos(390, btnY)
        btnBomb.Paint = function(self, w, h)
            local bg = self:IsHovered() and Color(60, 60, 60, 245) or Color(35, 35, 35, 235)
            draw.RoundedBox(10, 0, 0, w, h, bg)
            draw.RoundedBox(10, 6, 6, w - 12, h - 12, Color(0, 0, 0, 120))
            draw.SimpleText("Prop Bomb", "HomigradFontBig", w / 2, h / 2 - 6, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Hide in Prop", "HomigradFont", w / 2, h / 2 + 20, Color(220, 220, 220, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        btnBomb.DoClick = function()
            SendTraitorLoadout("prop_bomb")
        end
    end

    hook.Add("HUDPaint", "Homicide_TraitorLoadoutMenu", function()
        local lply = LocalPlayer()
        if not IsValid(lply) or not lply:Alive() then return end
        if not homicide.roleReady or not lply.roleT then return end
        if homicide.roundType ~= 1 then return end
        if traitorLoadoutChosen then return end
        OpenTraitorLoadoutMenu()
    end)

    hook.Add("Homicide_ResetTraitorLoadout", "Homicide_ResetTraitorLoadout", function()
        traitorLoadoutChosen = false
        CloseTraitorLoadoutMenu()
    end)
end

local homicide_setmode = CreateConVar("homicide_setmode","",FCVAR_LUA_SERVER,"")
CreateClientConVar("homicide_get",0,true,true,"show traitors and stuff while you're spectating", 0, 1)

function homicide.IsMapBig()
    local mins,maxs = game.GetWorld():GetModelBounds()
    local skybox = 0
    for i,ent in pairs(ents.FindByClass("sky_camera")) do
        skybox = 0
    end
    return (mins:Distance(maxs) - skybox) > 5000
end

function homicide.StartRound(data)
    team.SetColor(1,homicide.red[2])
    game.CleanUpMap(false)

    if SERVER then
        local roundType = homicide_setmode:GetInt() == math.random(1,4) or (homicide.IsMapBig() and 1) or false
        homicide.roundType = math.random(1,5)
        net.Start("roundType")
        net.WriteInt(homicide.roundType,5)
        net.Broadcast()
    end

    if CLIENT then
        for i,ply in player.Iterator() do
            ply.roleT = false
            ply.roleCT = false
            ply.countKick = 0
        end
        hook.Run("Homicide_ResetTraitorLoadout")
        homicide.roleReady = false
        roundTimeLoot = data.roundTimeLoot
        return
    end

    return homicide.StartRoundSV()
end

if SERVER then return end

local red,blue = Color(200,0,10),Color(75,75,255)
local gray = Color(122,122,122,255)
local white = Color(255,255,255,255)

function homicide.GetTeamName(ply)
    if ply.roleT then return "Traitor",red end
    if ply.roleCT then return "Innocent",blue end
    local teamID = ply:Team()
    if teamID == 1 then
        return "Innocent",white
    end
    if teamID == 3 then
        return "Police",blue
    end
end

local black = Color(0,0,0,255)

net.Receive("homicide_roleget",function()
    for i,ply in pairs(player.GetAll()) do ply.roleT = nil ply.roleCT = nil end
    local role = net.ReadTable()
    for i,ply in pairs(role[1]) do ply.roleT = true end
    for i,ply in pairs(role[2]) do ply.roleCT = true end
end)

function homicide.HUDPaint_Spectate(spec)
    --local name,color = homicide.GetTeamName(spec)
    --draw.SimpleText(name,"HomigradFontBig",ScrW() / 2,ScrH() - 150,color,TEXT_ALIGN_CENTER)
end

function homicide.Scoreboard_Status(ply)
    local lply = LocalPlayer()
    if not lply:Alive() or lply:Team() == 1002 then return true end
    return "Unknown",ScoreboardSpec
end

-- Round type and sound configurations
local roundTypes = {"Standard"}
local roundSound = {"music/homicide.mp3"}

local DescCT = {
    [1] = "You are armed with equipment to find the traitors.",
}

local DescTraitor = {
    [1] = "You have a silenced USP with two magazines.",
    [2] = "You have a silenced USP with two magazines.",
    [3] = "You have a crossbow with a handful of bolts.",
    [4] = "You have a Mateba with a few extra rounds.",
    [5] = "You have a Scout or Barrett with extra ammo.",
}

local DescInnocent = "Work together to find the traitors among you."

-- Initialize round UI display flag
local roundUIShown = false

function homicide.HUDPaint_RoundLeft(white2)
    local roundType = homicide.roundType or 2
    local lply = LocalPlayer()
    local name,color = homicide.GetTeamName(lply)
    
    -- Count down the *prep* window instead of a fixed 5s intro
    local prepLeft = (roundTimeStart + (homicide.PREP_TIME or 20)) - CurTime()

    -- While we're still in prep, *do not* show the role intro UI.
    -- Also reset the "shown once" flag so a new round can display the UI later.
    if prepLeft > 0 then
        roundUIShown = false
    else
        -- Prep is over: now (and only now) show the role intro once.
        if playsound and not roundUIShown and lply:Alive() and homicide.roleReady then
            playsound = false
            roundUIShown = true

            -- Determine description based on role, exactly like before
            local description = DescInnocent
            if lply.roleT then
                description = DescTraitor[roundType] or "You have a silenced USP with two magazines."
            elseif lply.roleCT then
                description = DescCT[roundType] or "..."
            end

            RoundStartUI.Show({
                gamemode = "Homicide",
                roundType = roundTypes[roundType],
                role = name,
                roleColor = color,
                description = description,
                duration = 5,                -- keep your preferred duration
                sound = roundSound[homicide.roundType],
                fadeScreen = true,
                headerImage = "vgui/fmt/homicide.png"
            })
        end
    end

    
    -- Buddy system display (unchanged)
    local lply_pos = lply:GetPos()
    for i,ply in player.Iterator() do
        local color = ply.roleT and red or ply.roleCT and blue
        if not color or ply == lply or not ply:Alive() then continue end
        
        local pos = ply:GetPos() + ply:OBBCenter()
        local dis = lply_pos:Distance(pos)
        if dis > 1024 then continue end
        
        local pos = pos:ToScreen()
        if not pos.visible then continue end
        
        color.a = 255 * (1 - dis / 1024)
        draw.SimpleText("Buddy: "..ply:Nick(),"HomigradFontBig",pos.x,pos.y,color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
end

function homicide.VBWHide(ply,wep)
    if (not ply:IsRagdoll() and ply:Team() == 1002) then return end
    return (wep.IsPistolHoldType and wep:IsPistolHoldType())
end

function homicide.Scoreboard_DrawLast(ply)
    if LocalPlayer():Team() ~= 1002 and LocalPlayer():Alive() then return false end
end

homicide.SupportCenter = true

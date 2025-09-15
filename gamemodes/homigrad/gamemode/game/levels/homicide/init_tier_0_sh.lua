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

local playsound = false
if SERVER then
    util.AddNetworkString("roundType")
    util.AddNetworkString("homicide_support_arrival")
else
    net.Receive("roundType",function(len)
        homicide.roundType = net.ReadInt(5)
        playsound = true
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
local roundTypes = {"Shotgun", "Regular Round", "No Fire-Arms", "Wild West","Hitman"}
local roundSound = {"snd_jack_hmcd_disaster.mp3","snd_jack_hmcd_shining.mp3","snd_jack_hmcd_panic.mp3","snd_jack_hmcd_wildwest.mp3","snd_jack_hmcd_disaster.mp3"}

local DescCT = {
    [1] = "You have been given a shotgun. Be careful, the traitor will be likely to target you.",
    [2] = "You have been given a M9 Beretta with one magazine.",
    [3] = "You have been given a Taser & Baton to take care of the traitor.",
    [4] = "You & the traitor have been given identical revolvers.",
    [5] = "You have been given a shotgun. Be careful, the traitor will be likely to target you."
}

local DescTraitor = {
    [1] = "You have a silenced USP with two magazines.",
    [2] = "You have a silenced USP with two magazines.",
    [3] = "You have a Crossbow. It is hidden from your character.",
    [4] = "You have been given a revolver to take everyone else out.",
    [5] = "You have a sniper rifle. It is hidden from your character."
}

local DescInnocent = "Find the Traitor(s), and kill them to win!"

-- Initialize round UI display flag
local roundUIShown = false

function homicide.HUDPaint_RoundLeft(white2)
    local roundType = homicide.roundType or 2
    local lply = LocalPlayer()
    local name,color = homicide.GetTeamName(lply)
    
    local startRound = roundTimeStart + 5 - CurTime()
    
    -- Show round start UI
    if startRound > 0 and lply:Alive() then
        if playsound and not roundUIShown then
            playsound = false
            roundUIShown = true
            
            -- Determine description based on role
            local description = DescInnocent
            if lply.roleT then
                description = DescTraitor[roundType] or "You have a silenced USP with two magazines."
            elseif lply.roleCT then
                description = DescCT[roundType] or "..."
            end
            
            -- Show the new UI
            RoundStartUI.Show({
                gamemode = "Homicide",
                roundType = roundTypes[roundType],
                role = name,
                roleColor = color,
                description = description,
                duration = 5,
                sound = roundSound[homicide.roundType],
                fadeScreen = true
            })
        end
        return
    else
        -- Reset the flag when round UI is no longer needed
        if startRound <= 0 then
            roundUIShown = false
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